// Icaro for upgrade, updates in code. based on tfs 1.4 
// Special Credits: Pota, Ruby
// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_COMBAT_H_B02CE79230FC43708699EE91FCC8F7CC
#define FS_COMBAT_H_B02CE79230FC43708699EE91FCC8F7CC

#include "thing.h"
#include "condition.h"
#include "map.h"
#include "baseevents.h"

class Condition;
class Creature;
class Item;

struct Position;

//for luascript callback
class ValueCallback final : public CallBack
{
	public:
		explicit ValueCallback(formulaType_t type): type(type) {}
		void getMinMaxValues(Player* player, CombatDamage& damage) const;

	private:
		formulaType_t type;
};

class TileCallback final : public CallBack
{
	public:
		void onTileCombat(Creature* creature, Tile* tile) const;

};

class TargetCallback final : public CallBack
{
	public:
		void onTargetCombat(Creature* creature, Creature* target) const;

};

struct CombatParams {
	std::forward_list<std::unique_ptr<const Condition>> conditionList;

	std::unique_ptr<ValueCallback> valueCallback;
	std::unique_ptr<TileCallback> tileCallback;
	std::unique_ptr<TargetCallback> targetCallback;

	uint16_t itemId = 0;

	ConditionType_t dispelType = CONDITION_NONE;
	CombatType_t combatType = COMBAT_NONE;
	CombatOrigin origin = ORIGIN_SPELL;

	uint16_t impactEffect = CONST_ME_NONE; //pota
	uint8_t distanceEffect = CONST_ANI_NONE;

	bool blockedByArmor = false;
	bool blockedByShield = false;
	bool targetCasterOrTopMost = false;
	bool aggressive = true;
	bool useCharges = false;
	std::string spellName;
};

class MatrixArea
{
	public:
		MatrixArea(uint32_t rows, uint32_t cols): centerX(0), centerY(0), rows(rows), cols(cols) {
			data_ = new bool*[rows];

			for (uint32_t row = 0; row < rows; ++row) {
				data_[row] = new bool[cols];

				for (uint32_t col = 0; col < cols; ++col) {
					data_[row][col] = 0;
				}
			}
		}

		MatrixArea(const MatrixArea& rhs) {
			centerX = rhs.centerX;
			centerY = rhs.centerY;
			rows = rhs.rows;
			cols = rhs.cols;

			data_ = new bool*[rows];

			for (uint32_t row = 0; row < rows; ++row) {
				data_[row] = new bool[cols];

				for (uint32_t col = 0; col < cols; ++col) {
					data_[row][col] = rhs.data_[row][col];
				}
			}
		}

		~MatrixArea() {
			for (uint32_t row = 0; row < rows; ++row) {
				delete[] data_[row];
			}

			delete[] data_;
		}

		// non-assignable
		MatrixArea& operator=(const MatrixArea&) = delete;

		void setValue(uint32_t row, uint32_t col, bool value) const {
			data_[row][col] = value;
		}
		bool getValue(uint32_t row, uint32_t col) const {
			return data_[row][col];
		}

		void setCenter(uint32_t y, uint32_t x) {
			centerX = x;
			centerY = y;
		}
		void getCenter(uint32_t& y, uint32_t& x) const {
			x = centerX;
			y = centerY;
		}

		uint32_t getRows() const {
			return rows;
		}
		uint32_t getCols() const {
			return cols;
		}

		const bool* operator[](uint32_t i) const {
			return data_[i];
		}
		bool* operator[](uint32_t i) {
			return data_[i];
		}

	private:
		uint32_t centerX;
		uint32_t centerY;

		uint32_t rows;
		uint32_t cols;
		bool** data_;
};

class AreaCombat
{
	public:
		AreaCombat() = default;

		AreaCombat(const AreaCombat& rhs);
		~AreaCombat() {
			clear();
		}

		// non-assignable
		AreaCombat& operator=(const AreaCombat&) = delete;

		void getList(const Position& centerPos, const Position& targetPos, std::forward_list<Tile*>& list) const;

		void setupArea(const std::list<uint32_t>& list, uint32_t rows);
		void setupArea(int32_t length, int32_t spread);
		void setupArea(int32_t radius);
		void setupExtArea(const std::list<uint32_t>& list, uint32_t rows);
		void clear();

	private:
		enum MatrixOperation_t {
			MATRIXOPERATION_COPY,
			MATRIXOPERATION_MIRROR,
			MATRIXOPERATION_FLIP,
			MATRIXOPERATION_ROTATE90,
			MATRIXOPERATION_ROTATE180,
			MATRIXOPERATION_ROTATE270,
		};

		MatrixArea* createArea(const std::list<uint32_t>& list, uint32_t rows);
		static void copyArea(const MatrixArea* input, MatrixArea* output, MatrixOperation_t op);

		MatrixArea* getArea(const Position& centerPos, const Position& targetPos) const {
			int32_t dx = Position::getOffsetX(targetPos, centerPos);
			int32_t dy = Position::getOffsetY(targetPos, centerPos);

			Direction dir;
			if (dx < 0) {
				dir = DIRECTION_WEST;
			} else if (dx > 0) {
				dir = DIRECTION_EAST;
			} else if (dy < 0) {
				dir = DIRECTION_NORTH;
			} else {
				dir = DIRECTION_SOUTH;
			}

			if (hasExtArea) {
				if (dx < 0 && dy < 0) {
					dir = DIRECTION_NORTHWEST;
				} else if (dx > 0 && dy < 0) {
					dir = DIRECTION_NORTHEAST;
				} else if (dx < 0 && dy > 0) {
					dir = DIRECTION_SOUTHWEST;
				} else if (dx > 0 && dy > 0) {
					dir = DIRECTION_SOUTHEAST;
				}
			}

			auto it = areas.find(dir);
			if (it == areas.end()) {
				return nullptr;
			}
			return it->second;
		}

		std::map<Direction, MatrixArea*> areas;
		bool hasExtArea = false;
};

class Combat
{
	public:
		Combat() = default;

		// non-copyable
		Combat(const Combat&) = delete;
		Combat& operator=(const Combat&) = delete;

		static void getCombatArea(const Position& centerPos, const Position& targetPos, const AreaCombat* area, std::forward_list<Tile*>& list);
		static bool isInPvpZone(const Creature* attacker, const Creature* target);
		static bool isProtected(const Player* attacker, const Player* target);
		static bool isPlayerCombat(const Creature* target);
		static CombatType_t ConditionToDamageType(ConditionType_t type);
		static ConditionType_t DamageToConditionType(CombatType_t type);
		static ReturnValue canTargetCreature(Player* attacker, Creature* target);
		static ReturnValue canDoCombat(Creature* caster, Tile* tile, bool aggressive);
		static ReturnValue canDoCombat(Creature* attacker, Creature* target);
		static void postCombatEffects(Creature* caster, const Position& pos, const CombatParams& params);

		static void addDistanceEffect(Creature* caster, const Position& fromPos, const Position& toPos, uint8_t effect);

		void doCombat(Creature* caster, Creature* target) const;
		void doCombat(Creature* caster, const Position& position) const;

		static void doTargetCombat(Creature* caster, Creature* target, CombatDamage& damage, const CombatParams& params);
		static void doAreaCombat(Creature* caster, const Position& position, const AreaCombat* area, CombatDamage& damage, const CombatParams& params);

		static void doAreaCombatTemp(Creature* caster, const Position& position, const AreaCombat* area, CombatDamage& damage, const CombatParams& params);

		bool setCallback(CallBackParam_t key);
		CallBack* getCallback(CallBackParam_t key);

		bool setParam(CombatParam_t param, uint32_t value);
		bool setStringParam(CombatParam_t param, std::string value);
		void setArea(AreaCombat* area) {
			this->area.reset(area);
		}
		bool hasArea() const {
			return area != nullptr;
		}
		
		void addCondition(const Condition* condition) {
			params.conditionList.emplace_front(condition);
		}

		size_t getConditionsSize() const {
		    return std::distance(params.conditionList.begin(), params.conditionList.end());
		}

		void clearConditions() {
		    params.conditionList.clear();
		}

		void setPlayerCombatValues(formulaType_t formulaType, double mina, double minb, double maxa, double maxb);
		void postCombatEffects(Creature* caster, const Position& pos) const {
			postCombatEffects(caster, pos, params);
		}

		void setOrigin(CombatOrigin origin) {
			params.origin = origin;
			if (origin == ORIGIN_MELEE) {
				params.spellName = "melee";
			}
		}

	private:
		static void combatTileEffects(const SpectatorVec& spectators, Creature* caster, Tile* tile, const CombatParams& params);
		CombatDamage getCombatDamage(Creature* creature, Creature* target) const;

		//configureable
		CombatParams params;

		//formula variables
		formulaType_t formulaType = COMBAT_FORMULA_UNDEFINED;
		double mina = 0.0;
		double minb = 0.0;
		double maxa = 0.0;
		double maxb = 0.0;

		std::unique_ptr<AreaCombat> area;
};

class MagicField final : public Item
{
	public:
		explicit MagicField(uint16_t type) : Item(type), createTime(OTSYS_TIME()) {}

		MagicField* getMagicField() override {
			return this;
		}
		const MagicField* getMagicField() const override {
			return this;
		}

		bool isReplaceable() const {
			return Item::items[getID()].replaceable;
		}
		CombatType_t getCombatType() const {
			const ItemType& it = items[getID()];
			return it.combatType;
		}
		void onStepInField(Creature* creature);

	private:
		int64_t createTime;
};

#endif
