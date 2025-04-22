// Icaro for upgrade, updates in code. based on tfs 1.4 
// Special Credits: Pota, Ruby
// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "vocation.h"

#include "pugicast.h"
#include "tools.h"

bool Vocations::loadFromXml()
{
	pugi::xml_document doc;
	pugi::xml_parse_result result = doc.load_file("data/XML/vocations.xml");
	if (!result) {
		printXMLError("Error - Vocations::loadFromXml", "data/XML/vocations.xml", result);
		return false;
	}

	for (auto vocationNode : doc.child("vocations").children()) {
		pugi::xml_attribute attr;
		if (!(attr = vocationNode.attribute("id"))) {
			std::cout << "[Warning - Vocations::loadFromXml] Missing vocation id" << std::endl;
			continue;
		}

		uint16_t id = pugi::cast<uint16_t>(attr.value());

		auto res = vocationsMap.emplace(std::piecewise_construct,
				std::forward_as_tuple(id), std::forward_as_tuple(id));
		Vocation& voc = res.first->second;

		if ((attr = vocationNode.attribute("name"))) {
			voc.name = attr.as_string();
		}

		if ((attr = vocationNode.attribute("clientid"))) {
			voc.clientId = pugi::cast<uint16_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("description"))) {
			voc.description = attr.as_string();
		}

		if ((attr = vocationNode.attribute("gaincap"))) {
			voc.gainCap = pugi::cast<uint32_t>(attr.value()) * 100;
		}

		if ((attr = vocationNode.attribute("gainhp"))) {
			voc.gainHP = pugi::cast<uint32_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("gainmana"))) {
			voc.gainMana = pugi::cast<uint32_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("gainhpticks"))) {
			voc.gainHealthTicks = pugi::cast<uint32_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("gainhpamount"))) {
			voc.gainHealthAmount = pugi::cast<uint32_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("gainmanaticks"))) {
			voc.gainManaTicks = pugi::cast<uint32_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("gainmanaamount"))) {
			voc.gainManaAmount = pugi::cast<uint32_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("manamultiplier"))) {
			voc.manaMultiplier = pugi::cast<float>(attr.value());
		}

		if ((attr = vocationNode.attribute("attackspeed"))) {
			voc.attackSpeed = pugi::cast<uint32_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("basespeed"))) {
			voc.baseSpeed = pugi::cast<uint32_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("soulmax"))) {
			voc.soulMax = pugi::cast<uint16_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("gainsoulticks"))) {
			voc.gainSoulTicks = pugi::cast<uint16_t>(attr.value());
		}

		if ((attr = vocationNode.attribute("fromvoc"))) {
			voc.fromVocation = pugi::cast<uint32_t>(attr.value());
		}

		for (auto childNode : vocationNode.children()) {
			if (strcasecmp(childNode.name(), "skill") == 0) {
				pugi::xml_attribute skillIdAttribute = childNode.attribute("id");
				if (skillIdAttribute) {
					uint16_t skill_id = pugi::cast<uint16_t>(skillIdAttribute.value());
					if (skill_id <= SKILL_LAST) {
						voc.skillMultipliers[skill_id] = pugi::cast<double>(childNode.attribute("multiplier").value());
					} else {
						std::cout << "[Notice - Vocations::loadFromXml] No valid skill id: " << skill_id << " for vocation: " << voc.id << std::endl;
					}
				} else {
					std::cout << "[Notice - Vocations::loadFromXml] Missing skill id for vocation: " << voc.id << std::endl;
				}
			} else if (strcasecmp(childNode.name(), "formula") == 0) {
				pugi::xml_attribute meleeDamageAttribute = childNode.attribute("meleeDamage");
				if (meleeDamageAttribute) {
					voc.meleeDamageMultiplier = pugi::cast<float>(meleeDamageAttribute.value());
				}

				pugi::xml_attribute distDamageAttribute = childNode.attribute("distDamage");
				if (distDamageAttribute) {
					voc.distDamageMultiplier = pugi::cast<float>(distDamageAttribute.value());
				}

				pugi::xml_attribute defenseAttribute = childNode.attribute("defense");
				if (defenseAttribute) {
					voc.defenseMultiplier = pugi::cast<float>(defenseAttribute.value());
				}

				pugi::xml_attribute armorAttribute = childNode.attribute("armor");
				if (armorAttribute) {
					voc.armorMultiplier = pugi::cast<float>(armorAttribute.value());
				}
			}
		}
	}
	return true;
}

Vocation* Vocations::getVocation(uint16_t id)
{
	auto it = vocationsMap.find(id);
	if (it == vocationsMap.end()) {
		std::cout << "[Warning - Vocations::getVocation] Vocation " << id << " not found." << std::endl;
		return nullptr;
	}
	return &it->second;
}

int32_t Vocations::getVocationId(const std::string& name) const
{
	auto it = std::find_if(vocationsMap.begin(), vocationsMap.end(), [&name](decltype(vocationsMap)::value_type it) {
		return it.second.name == name;
	});
	return it != vocationsMap.end() ? it->first : -1;
}

uint16_t Vocations::getPromotedVocation(uint16_t id) const
{
	auto it = std::find_if(vocationsMap.begin(), vocationsMap.end(), [id](decltype(vocationsMap)::value_type it) {
		return it.second.fromVocation == id && it.first != id;
	});
	return it != vocationsMap.end() ? it->first : VOCATION_NONE;
}

static const uint32_t skillBase[SKILL_LAST + 1] = {50, 50, 50, 50, 30, 100, 20};

uint64_t Vocation::getReqSkillTries(uint8_t skill, uint16_t level)
{
	if (skill > SKILL_LAST) {
		return 0;
	}

	return skillBase[skill] * std::pow(skillMultipliers[skill], level - 11);
}

uint64_t Vocation::getReqMana(uint32_t magLevel)
{
	return 1600 * std::pow(manaMultiplier, magLevel - 1);
}
