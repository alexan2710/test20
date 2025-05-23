// Icaro for upgrade, updates in code. based on tfs 1.4 
// Special Credits: Pota, Ruby
// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "protocol.h"
#include "outputmessage.h"
#include "rsa.h"
#include "xtea.h"

extern RSA g_RSA;


Protocol::~Protocol()
{
	if (compression) {
		deflateEnd(&zstream);
	}
}

void Protocol::onSendMessage(const OutputMessage_ptr& msg) const
{
	if (!rawMessages) {
		bool compressed = false;
		if (compression && msg->getLength() > 64) {
			compress(*msg);
			compressed = true;
		}
		msg->writeMessageLength();

		if (encryptionEnabled) {
			XTEA_encrypt(*msg);
			msg->addCryptoHeader(checksumEnabled, compressed);
		}
	}
}

void Protocol::onRecvMessage(NetworkMessage& msg)
{
	if (encryptionEnabled && !XTEA_decrypt(msg)) {
		return;
	}

	parsePacket(msg);
}

OutputMessage_ptr Protocol::getOutputBuffer(int32_t size)
{
	//dispatcher thread
	if (!outputBuffer) {
		outputBuffer = OutputMessagePool::getOutputMessage();
	} else if ((outputBuffer->getLength() + size) > NetworkMessage::MAX_PROTOCOL_BODY_LENGTH) {
		send(outputBuffer);
		outputBuffer = OutputMessagePool::getOutputMessage();
	}
	return outputBuffer;
}

void Protocol::XTEA_encrypt(OutputMessage& msg) const
{

	// The message must be a multiple of 8
	size_t paddingBytes = msg.getLength() % 8u;
	if (paddingBytes != 0) {
		msg.addPaddingBytes(8 - paddingBytes);
	}

	uint8_t* buffer = msg.getOutputBuffer();
	xtea::encrypt(buffer, msg.getLength(), key);
	
}

bool Protocol::XTEA_decrypt(NetworkMessage& msg) const
{
	if (((msg.getLength() - 6) & 7) != 0) {
		return false;
	}

	uint8_t* buffer = msg.getBuffer() + msg.getBufferPosition();
	xtea::decrypt(buffer, msg.getLength() - 6, key);
	
	
	uint16_t innerLength = msg.get<uint16_t>();
	if (innerLength + 8 > msg.getLength()) {
		return false;
	}

	msg.setLength(innerLength);
	return true;
}

bool Protocol::RSA_decrypt(NetworkMessage& msg)
{
	if ((msg.getLength() - msg.getBufferPosition()) < 128) {
		return false;
	}

	g_RSA.decrypt(reinterpret_cast<char*>(msg.getBuffer()) + msg.getBufferPosition()); //does not break strict aliasing
	return msg.getByte() == 0;
}

uint32_t Protocol::getIP() const
{
	if (auto connection = getConnection()) {
		return connection->getIP();
	}

	return 0;
}

void Protocol::enableCompression()
{
	if (compression)
		return;
	if (deflateInit2(&zstream, 6, Z_DEFLATED, -15, 8, Z_DEFAULT_STRATEGY) != Z_OK) {
		std::cerr << "ZLIB initialization error: " << (zstream.msg ? zstream.msg : "unknown") << std::endl;
	}
	compression = true;
}

void Protocol::compress(OutputMessage& msg) const
{
	static thread_local std::vector<uint8_t> buffer(NETWORKMESSAGE_MAXSIZE);
	zstream.next_in = msg.getOutputBuffer();
	zstream.avail_in = msg.getLength();
	zstream.next_out = buffer.data();
	zstream.avail_out = buffer.size();
	if (deflate(&zstream, Z_SYNC_FLUSH) != Z_OK) {
		std::cerr << "ZLIB deflate error: " << (zstream.msg ? zstream.msg : "unknown") << std::endl;
		return;
	}
	int finalSize = buffer.size() - zstream.avail_out - 4;
	if (finalSize < 0) {
		std::cerr << "Packet compression error: " << (zstream.msg ? zstream.msg : "unknown") << std::endl;
		return;
	}

	msg.reset();
	msg.addBytes((const char*)buffer.data(), finalSize);
}