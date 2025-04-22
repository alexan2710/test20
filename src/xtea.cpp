// Icaro for upgrade, updates in code. based on tfs 1.4 
// Special Credits: Pota, Ruby
// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "xtea.h"

#include <array>
#include <assert.h>

namespace xtea {

namespace {

constexpr uint32_t delta = 0x9E3779B9;

template<typename Round>
void apply_rounds(uint8_t* data, size_t length, Round round)
{
    for (auto j = 0u; j < length; j += 8) {
        uint32_t left = data[j+0] | data[j+1] << 8u | data[j+2] << 16u | data[j+3] << 24u,
                right = data[j+4] | data[j+5] << 8u | data[j+6] << 16u | data[j+7] << 24u;

        round(left, right);

        data[j] = static_cast<uint8_t>(left);
        data[j+1] = static_cast<uint8_t>(left >> 8u);
        data[j+2] = static_cast<uint8_t>(left >> 16u);
        data[j+3] = static_cast<uint8_t>(left >> 24u);
        data[j+4] = static_cast<uint8_t>(right);
        data[j+5] = static_cast<uint8_t>(right >> 8u);
        data[j+6] = static_cast<uint8_t>(right >> 16u);
        data[j+7] = static_cast<uint8_t>(right >> 24u);
    }
}

}

void encrypt(uint8_t* data, size_t length, const key& k)
{
    for (uint32_t i = 0, sum = 0, next_sum = sum + delta; i < 32; ++i, sum = next_sum, next_sum += delta) {
        apply_rounds(data, length, [&](uint32_t& left, uint32_t& right) {
            left += ((right << 4 ^ right >> 5) + right) ^ (sum + k[sum & 3]);
            right += ((left << 4 ^ left >> 5) + left) ^ (next_sum + k[(next_sum >> 11) & 3]);
        });
    };
}

void decrypt(uint8_t* data, size_t length, const key& k)
{
    for (uint32_t i = 0, sum = delta << 5, next_sum = sum - delta; i < 32; ++i, sum = next_sum, next_sum -= delta) {
        apply_rounds(data, length, [&](uint32_t& left, uint32_t& right) {
            right -= ((left << 4 ^ left >> 5) + left) ^ (sum + k[(sum >> 11) & 3]);
            left -= ((right << 4 ^ right >> 5) + right) ^ (next_sum + k[next_sum & 3]);
        });
    };
}

} // namespace xtea