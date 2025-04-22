// Icaro for upgrade, updates in code. based on tfs 1.4 
// Special Credits: Pota, Ruby
// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "configmanager.h"
#include "databasemanager.h"
#include "luascript.h"

extern ConfigManager g_config;

bool DatabaseManager::optimizeTables()
{
	Database& db = Database::getInstance();
	std::ostringstream query;

	query << "SELECT `TABLE_NAME` FROM `information_schema`.`TABLES` WHERE `TABLE_SCHEMA` = " << db.escapeString(g_config.getString(ConfigManager::MYSQL_DB)) << " AND `DATA_FREE` > 0";
	DBResult_ptr result = db.storeQuery(query.str());
	// DBResult_ptr result = db.storeQuery(query.str());
	if (!result) {
		return false;
	}

	do {
		std::string tableName = result->getString("TABLE_NAME");
		std::cout << "> Optimizing table " << tableName << "..." << std::flush;

		query.str(std::string());
		query << "OPTIMIZE TABLE `" << tableName << '`';

		if (db.executeQuery(query.str())) {
			std::cout << " [success]" << std::endl;
		} else {
			std::cout << " [failed]" << std::endl;
		}
	} while (result->next());
	return true;
}

void DatabaseManager::updateDatabase()
{
	lua_State* L = luaL_newstate();
	if (!L) {
		return;
	}

	luaL_openlibs(L);

#ifndef LUAJIT_VERSION
	//bit operations for Lua, based on bitlib project release 24
	//bit.bnot, bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift
	luaL_register(L, "bit", LuaScriptInterface::luaBitReg);
#endif

	//db table
	luaL_register(L, "db", LuaScriptInterface::luaDatabaseTable);

	//result table
	luaL_register(L, "result", LuaScriptInterface::luaResultTable);

	int32_t version = getDatabaseVersion();
	do {
		std::ostringstream ss;
		ss << "data/migrations/" << version << ".lua";
		if (luaL_dofile(L, ss.str().c_str()) != 0) {
			std::cout << "[Error - DatabaseManager::updateDatabase - Version: " << version << "] " << lua_tostring(L, -1) << std::endl;
			break;
		}

		if (!LuaScriptInterface::reserveScriptEnv()) {
			break;
		}

		lua_getglobal(L, "onUpdateDatabase");
		if (lua_pcall(L, 0, 1, 0) != 0) {
			LuaScriptInterface::resetScriptEnv();
			std::cout << "[Error - DatabaseManager::updateDatabase - Version: " << version << "] " << lua_tostring(L, -1) << std::endl;
			break;
		}

		if (!LuaScriptInterface::getBoolean(L, -1, false)) {
			LuaScriptInterface::resetScriptEnv();
			break;
		}

		version++;
		std::cout << "> Database has been updated to version " << version << '.' << std::endl;
		registerDatabaseConfig("db_version", version);

		LuaScriptInterface::resetScriptEnv();
	} while (true);
	lua_close(L);
}

bool DatabaseManager::tableExists(const std::string& tableName)
{
	Database& db = Database::getInstance();

	std::ostringstream query;
	query << "SELECT `TABLE_NAME` FROM `information_schema`.`tables` WHERE `TABLE_SCHEMA` = " << db.escapeString(g_config.getString(ConfigManager::MYSQL_DB)) << " AND `TABLE_NAME` = " << db.escapeString(tableName) << " LIMIT 1";
	return db.storeQuery(query.str()).get() != nullptr;
	// return db->storeQuery(query.str()).get() != nullptr;
}

bool DatabaseManager::isDatabaseSetup()
{
	Database& db = Database::getInstance();
	std::ostringstream query;
	query << "SELECT `TABLE_NAME` FROM `information_schema`.`tables` WHERE `TABLE_SCHEMA` = " << db.escapeString(g_config.getString(ConfigManager::MYSQL_DB));
	return db.storeQuery(query.str()).get() != nullptr;

}

int32_t DatabaseManager::getDatabaseVersion()
{
	if (!tableExists("server_config")) {
		Database& db = Database::getInstance();
		db.executeQuery("CREATE TABLE `server_config` (`config` VARCHAR(50) NOT NULL, `value` VARCHAR(256) NOT NULL DEFAULT '', UNIQUE(`config`)) ENGINE = InnoDB");
		db.executeQuery("INSERT INTO `server_config` VALUES ('db_version', 0)");
		return 0;
	}

	int32_t version = 0;
	if (getDatabaseConfig("db_version", version)) {
		return version;
	}
	return -1;
}

bool DatabaseManager::getDatabaseConfig(const std::string& config, int32_t& value)
{
	Database& db = Database::getInstance();
	std::ostringstream query;
	query << "SELECT `value` FROM `server_config` WHERE `config` = " << db.escapeString(config);

	DBResult_ptr result = db.storeQuery(query.str());
	if (!result) {
		return false;
	}

	value = result->getNumber<int32_t>("value");
	return true;
}

void DatabaseManager::registerDatabaseConfig(const std::string& config, int32_t value)
{
	Database& db = Database::getInstance();
	std::ostringstream query;

	int32_t tmp;

	if (!getDatabaseConfig(config, tmp)) {
		query << "INSERT INTO `server_config` VALUES (" << db.escapeString(config) << ", '" << value << "')";
	} else {
		query << "UPDATE `server_config` SET `value` = '" << value << "' WHERE `config` = " << db.escapeString(config);
	}

	db.executeQuery(query.str());
}
