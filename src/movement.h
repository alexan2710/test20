// Icaro for upgrade, updates in code. based on tfs 1.4 
// Special Credits: Pota, Ruby
// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_MOVEMENT_H_5E0D2626D4634ACA83AC6509518E5F49
#define FS_MOVEMENT_H_5E0D2626D4634ACA83AC6509518E5F49

#include "baseevents.h"
#include "item.h"
#include "luascript.h"
#include "vocation.h"

extern Vocations g_vocations;

enum MoveEvent_t {
	MOVE_EVENT_STEP_IN,
	MOVE_EVENT_STEP_OUT,
	MOVE_EVENT_EQUIP,
	MOVE_EVENT_DEEQUIP,
	MOVE_EVENT_ADD_ITEM,
	MOVE_EVENT_REMOVE_ITEM,
	MOVE_EVENT_ADD_ITEM_ITEMTILE,
	MOVE_EVENT_REMOVE_ITEM_ITEMTILE,

	MOVE_EVENT_LAST,
	MOVE_EVENT_NONE
};

class MoveEvent;
using MoveEvent_ptr = std::unique_ptr<MoveEvent>;

struct MoveEventList {
	std::list<MoveEvent> moveEvent[MOVE_EVENT_LAST];
};

using VocEquipMap = std::map<uint16_t, bool>;

class MoveEvents final : public BaseEvents
{
	public:
		MoveEvents();
		~MoveEvents();

		// non-copyable
		MoveEvents(const MoveEvents&) = delete;
		MoveEvents& operator=(const MoveEvents&) = delete;

		uint32_t onCreatureMove(Creature* creature, const Tile* tile, MoveEvent_t eventType);
		uint32_t onPlayerEquip(Player* player, Item* item, slots_t slot, bool isCheck);
		uint32_t onPlayerDeEquip(Player* player, Item* item, slots_t slot);
		uint32_t onItemMove(Item* item, Tile* tile, bool isAdd);

		MoveEvent* getEvent(Item* item, MoveEvent_t eventType);

		bool registerLuaEvent(MoveEvent* event);
		bool registerLuaFunction(MoveEvent* event);

		void clear(bool fromLua) override final;

		void clearItemIdRange(MoveEvent* event) { itemIdRange.erase(event); }
		const std::vector<uint32_t>& getItemIdRange(MoveEvent* event) const { return itemIdRange.at(event); }
		void addItemId(MoveEvent* event, uint32_t id) { itemIdRange[event].emplace_back(id); }

		void clearActionIdRange(MoveEvent* event) { actionIdRange.erase(event); }
		const std::vector<uint32_t>& getActionIdRange(MoveEvent* event) const { return actionIdRange.at(event); }
		void addActionId(MoveEvent* event, uint32_t id) { actionIdRange[event].emplace_back(id); }

		void clearUniqueIdRange(MoveEvent* event) { uniqueIdRange.erase(event); }
		const std::vector<uint32_t>& getUniqueIdRange(MoveEvent* event) const { return uniqueIdRange.at(event); }
		void addUniqueId(MoveEvent* event, uint32_t id) { uniqueIdRange[event].emplace_back(id); }

		void clearPosList(MoveEvent* event) { posList.erase(event); }
		const std::vector<Position>& getPosList(MoveEvent* event) const { return posList.at(event); }
		void addPosList(MoveEvent* event, Position pos) { posList[event].emplace_back(pos); }

		bool isValid(std::map<MoveEvent*, std::vector<uint32_t>> map, MoveEvent* event)
		{
			return map.find(event) != map.end();
		}
		bool isValidPos(std::map<MoveEvent*, std::vector<Position>> map, MoveEvent* event)
		{
			return map.find(event) != map.end();
		}

	private:
		using MoveListMap = std::map<int32_t, MoveEventList>;
		// void clearMap(MoveListMap& map);

		using MovePosListMap = std::map<Position, MoveEventList>;
		// void clear() override;
		void clearMap(MoveListMap& map, bool fromLua);
		void clearPosMap(MovePosListMap& map, bool fromLua);
		LuaScriptInterface& getScriptInterface() override;
		std::string getScriptBaseName() const override;
		Event_ptr getEvent(const std::string& nodeName) override;
		bool registerEvent(Event_ptr event, const pugi::xml_node& node) override;

		void addEvent(MoveEvent moveEvent, int32_t id, MoveListMap& map);

		void addEvent(MoveEvent moveEvent, const Position& pos, MovePosListMap& map);
		MoveEvent* getEvent(const Tile* tile, MoveEvent_t eventType);

		MoveEvent* getEvent(Item* item, MoveEvent_t eventType, slots_t slot);

		MoveListMap uniqueIdMap;
		MoveListMap actionIdMap;
		MoveListMap itemIdMap;
		MovePosListMap positionMap;

		std::map<MoveEvent*, std::vector<uint32_t>> itemIdRange;
		std::map<MoveEvent*, std::vector<uint32_t>> actionIdRange;
		std::map<MoveEvent*, std::vector<uint32_t>> uniqueIdRange;
		std::map<MoveEvent*, std::vector<Position>> posList;

		LuaScriptInterface scriptInterface;
};

using StepFunction = std::function<uint32_t(Creature* creature, Item* item, const Position& pos)>;
using MoveFunction = std::function<uint32_t(Item* item, Item* tileItem, const Position& pos)>;
using EquipFunction = std::function<uint32_t(MoveEvent* moveEvent, Player* player, Item* item, slots_t slot, bool boolean)>;

class MoveEvent final : public Event
{
	public:
		explicit MoveEvent(LuaScriptInterface* interface);
		// explicit MoveEvent(const MoveEvent* copy);

		MoveEvent_t getEventType() const;
		void setEventType(MoveEvent_t type);

		bool configureEvent(const pugi::xml_node& node) override;
		bool loadFunction(const pugi::xml_attribute& attr, bool isScripted) override;

		uint32_t fireStepEvent(Creature* creature, Item* item, const Position& pos);
		uint32_t fireAddRemItem(Item* item, Item* tileItem, const Position& pos);
		uint32_t fireEquip(Player* player, Item* item, slots_t slot, bool boolean);

		uint32_t getSlot() const {
			return slot;
		}

		//scripting
		bool executeStep(Creature* creature, Item* item, const Position& pos);
		bool executeEquip(Player* player, Item* item, slots_t slot, bool isCheck);
		bool executeAddRemItem(Item* item, Item* tileItem, const Position& pos);
		//

		//onEquip information
		uint32_t getReqLevel() const {
			return reqLevel;
		}
		uint32_t getReqMagLv() const {
			return reqMagLevel;
		}
		bool isPremium() const {
			return premium;
		}
		const std::string& getVocationString() const {
			return vocationString;
		}

		void setVocationString(const std::string& str) {
			vocationString = str;
		}

		uint32_t getWieldInfo() const {
			return wieldInfo;
		}
		const VocEquipMap& getVocEquipMap() const {
			return vocEquipMap;
		}

		void addVocEquipMap(std::string vocName) {
			int32_t vocationId = g_vocations.getVocationId(vocName);
			if (vocationId != -1) {
				vocEquipMap[vocationId] = true;
			}
		}

		bool getTileItem() const {
			return tileItem;
		}

		void setTileItem(bool b) {
			tileItem = b;
		}

		void setSlot(uint32_t s) {
			slot = s;
		}

		uint32_t getRequiredLevel() {
			return reqLevel;
		}
		
		void setRequiredLevel(uint32_t level) {
			reqLevel = level;
		}

		uint32_t getRequiredMagLevel() {
			return reqMagLevel;
		}

		void setRequiredMagLevel(uint32_t level) {
			reqMagLevel = level;
		}

		bool needPremium() {
			return premium;
		}

		void setNeedPremium(bool b) {
			premium = b;
		}
		
		uint32_t getWieldInfo() {
			return wieldInfo;
		}

		void setWieldInfo(WieldInfo_t info) {
			wieldInfo |= info;
		}

		static uint32_t StepInField(Creature* creature, Item* item, const Position& pos);
		static uint32_t StepOutField(Creature* creature, Item* item, const Position& pos);

		static uint32_t AddItemField(Item* item, Item* tileItem, const Position& pos);
		static uint32_t RemoveItemField(Item* item, Item* tileItem, const Position& pos);

		static uint32_t EquipItem(MoveEvent* moveEvent, Player* player, Item* item, slots_t slot, bool isCheck);
		static uint32_t DeEquipItem(MoveEvent* moveEvent, Player* player, Item* item, slots_t slot, bool boolean);


		MoveEvent_t eventType = MOVE_EVENT_NONE;
		
		StepFunction stepFunction;
		MoveFunction moveFunction;
		EquipFunction equipFunction;

	private:

		std::string getScriptEventName() const override;

		uint32_t slot = SLOTP_WHEREEVER;

		uint32_t reqLevel = 0;
		uint32_t reqMagLevel = 0;
		bool premium = false;
		std::string vocationString;
		uint32_t wieldInfo = 0;
		VocEquipMap vocEquipMap;
		
		bool tileItem = false;
};

#endif
