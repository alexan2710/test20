-- Advanced NPC System by Jiddo

if Modules == nil then
	-- default words for greeting and ungreeting the npc. Should be a table containing all such words.
	FOCUS_GREETWORDS = {"hi", "hello"}
	FOCUS_FAREWELLWORDS = {"bye", "farewell"}

	-- The words for requesting trade window.
	SHOP_TRADEREQUEST = {"trade"}

	-- The word for accepting/declining an offer. CAN ONLY CONTAIN ONE FIELD! Should be a table with a single string value.
	SHOP_YESWORD = {"yes"}
	SHOP_NOWORD = {"no"}

	-- Pattern used to get the amount of an item a player wants to buy/sell.
	PATTERN_COUNT = "%d+"

	-- Constants used to separate buying from selling.
	SHOPMODULE_SELL_ITEM = 1
	SHOPMODULE_BUY_ITEM = 2
	SHOPMODULE_BUY_ITEM_CONTAINER = 3

	-- Constants used for shop mode. Notice: addBuyableItemContainer is working on all modes
	SHOPMODULE_MODE_TALK = 1 -- Old system used before client version 8.2: sell/buy item name
	SHOPMODULE_MODE_TRADE = 2 -- Trade window system introduced in client version 8.2
	SHOPMODULE_MODE_BOTH = 3 -- Both working at one time

	-- Used shop mode
	SHOPMODULE_MODE = SHOPMODULE_MODE_BOTH

	Modules = {
		parseableModules = {}
	}

	StdModule = {}

	-- These callback function must be called with parameters.npcHandler = npcHandler in the parameters table or they will not work correctly.
	-- Notice: The members of StdModule have not yet been tested. If you find any bugs, please report them to me.
	-- Usage:
		-- keywordHandler:addKeyword({"offer"}, StdModule.say, {npcHandler = npcHandler, text = "I sell many powerful melee weapons."})
	function StdModule.say(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.say called without any npcHandler instance.")
		end

		if parameters.onlyFocus == true and parameters.onlyUnfocus == true then
			error("StdModule.say conflicting parameters 'onlyFocus' and 'onlyUnfocus' both true")
		end

		local onlyFocus = (parameters.onlyFocus == nil and parameters.onlyUnfocus == nil or parameters.onlyFocus == true)
		if not npcHandler:isFocused(cid) and onlyFocus then
			return false
		end

		if npcHandler:isFocused(cid) and parameters.onlyUnfocus == true then
			return false
		end

		local player = Player(cid)
		local cost, costMessage = parameters.cost, '%d gold coins'
		if cost and cost > 0 then
			if parameters.discount then
				cost = cost - StdModule.travelDiscount(player, parameters.discount)
			end

			costMessage = cost > 0 and string.format(costMessage, cost) or 'free'
		else
			costMessage = 'free'
		end

		local parseInfo = {[TAG_PLAYERNAME] = player:getName(), [TAG_TIME] = getTibianTime(), [TAG_BLESSCOST] = getBlessingsCost(player:getLevel()), [TAG_PVPBLESSCOST] = getPvpBlessingCost(player:getLevel()), [TAG_TRAVELCOST] = costMessage}
		if parameters.text then
			npcHandler:say(npcHandler:parseMessage(parameters.text, parseInfo), cid, parameters.publicize and true)
		end

		if parameters.ungreet then
			npcHandler:resetNpc(cid)
			npcHandler:releaseFocus(cid)
		elseif parameters.reset then
			npcHandler:resetNpc(cid)
		elseif parameters.moveup then
			npcHandler.keywordHandler:moveUp(cid, parameters.moveup)
		end

		return true
	end

	--Usage:
		-- local node1 = keywordHandler:addKeyword({"promot"}, StdModule.say, {npcHandler = npcHandler, text = "I can promote you for 20000 gold coins. Do you want me to promote you?"})
		-- 		node1:addChildKeyword({"yes"}, StdModule.promotePlayer, {npcHandler = npcHandler, cost = 20000, level = 20}, text = "Congratulations! You are now promoted.")
		-- 		node1:addChildKeyword({"no"}, StdModule.say, {npcHandler = npcHandler, text = "Allright then. Come back when you are ready."}, reset = true)
	function StdModule.promotePlayer(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.promotePlayer called without any npcHandler instance.")
		end
		if not npcHandler:isFocused(cid) then
			return false
		end

		local player = Player(cid)
		if player:isPremium() then
			if player:getStorageValue(PlayerStorageKeys.promotion) == 1 then
				npcHandler:say("You are already promoted!", cid)
			elseif player:getLevel() < parameters.level then
				npcHandler:say("I am sorry, but I can only promote you once you have reached level " .. parameters.level .. ".", cid)
			elseif not player:removeTotalMoney(parameters.cost) then
				npcHandler:say("You do not have enough money!", cid)
			else
				player:setStorageValue(PlayerStorageKeys.promotion, 1)
				player:setVocation(player:getVocation():getPromotion())
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				npcHandler:say(parameters.text or "Congratulations! You are now promoted.", cid)
			end
		else
			npcHandler:say("You need a premium account in order to get promoted.", cid)
		end
		npcHandler:resetNpc(cid)
		return true
	end

	function StdModule.learnSpell(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.learnSpell called without any npcHandler instance.")
		end

		if not npcHandler:isFocused(cid) then
			return false
		end

		local player = Player(cid)
		if player:hasLearnedSpell(parameters.spellName) then
			npcHandler:say("You already know how to cast this spell.", cid)
		elseif player:getLevel() < parameters.level then
			npcHandler:say("You have to be level " .. parameters.level .. " to learn this spell.", cid)
		elseif not player:removeTotalMoney(parameters.price) then
			npcHandler:say("Return when you have enough gold.", cid)
		else
			npcHandler:say("Here you are. Look in your spellbook for the pronunciation of this spell.", cid)
			player:learnSpell(parameters.spellName)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		end

		npcHandler:resetNpc(cid)
		return true
	end

	function StdModule.bless(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.bless called without any npcHandler instance.")
		end

		if not npcHandler:isFocused(cid) then
			return false
		end

		local player = Player(cid)
		local parseInfo = {[TAG_BLESSCOST] = getBlessingsCost(player:getLevel()), [TAG_PVPBLESSCOST] = getPvpBlessingCost(player:getLevel())}
		if player:hasBlessing(parameters.bless) then
			npcHandler:say("You already possess this blessing.", cid)
		elseif parameters.bless == 4 and player:getStorageValue(Storage.KawillBlessing) ~= 1 then
			npcHandler:say("You need the blessing of the great geomancer first.", cid)
		elseif parameters.bless == 6 and player:getBlessings() == 0 and not player:getItemById(2173, true) then
			npcHandler:say("You don't have any of the other blessings nor an amulet of loss, so it wouldn't make sense to bestow this protection on you now. Remember that it can only protect you from the loss of those!", cid)
		elseif not player:removeTotalMoney(type(parameters.cost) == "string" and npcHandler:parseMessage(parameters.cost, parseInfo) or parameters.cost) then
			npcHandler:say("Oh. You do not have enough money.", cid)
		else
			npcHandler:say(parameters.text or "You have been blessed by one of the five gods!", cid)
			if parameters.bless == 4 then
				player:setStorageValue(Storage.KawillBlessing, 0)
			end
			player:addBlessing(parameters.bless)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		end

		npcHandler:resetNpc(cid)
		return true
	end

	function StdModule.travel(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if npcHandler == nil then
			error("StdModule.travel called without any npcHandler instance.")
		end

		if not npcHandler:isFocused(cid) then
			return false
		end

		local player = Player(cid)
		local cost = parameters.cost
		if cost and cost > 0 then
			if parameters.discount then
				cost = cost - StdModule.travelDiscount(player, parameters.discount)

				if cost < 0 then
					cost = 0
				end
			end
		else
			cost = 0
		end

		if parameters.premium and not player:isPremium() then
			npcHandler:say("Desculpe, mas voce precisa ser vip!", cid)
		elseif parameters.level and player:getLevel() < parameters.level then
			npcHandler:say("Voce precisa atingir o level " .. parameters.level .. " antes.", cid)
		elseif player:isPzLocked() then
			npcHandler:say("First get rid of those blood stains! You are not going to ruin my vehicle!", cid)
		elseif not player:removeTotalMoney(cost) then
			npcHandler:say("Voce nao possui dinheiro suficiente.", cid)
		else
			npcHandler:releaseFocus(cid)
			npcHandler:say(parameters.text or "Boa viagem!", cid)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

			local destination = parameters.destination
			if type(destination) == 'function' then
				destination = destination(player)
			end

			player:teleportTo(destination)
			destination:sendMagicEffect(CONST_ME_TELEPORT)
		end

		npcHandler:resetNpc(cid)
		return true
	end

	FocusModule = {
		npcHandler = nil,
		greetWords = nil,
		farewellWords = nil,
		greetCallback = nil,
		farewellCallback = nil
	}

	-- Creates a new instance of FocusModule without an associated NpcHandler.
	function FocusModule:new()
		local obj = {}
		setmetatable(obj, self)
		self.__index = self
		return obj
	end

	-- Inits the module and associates handler to it.
	function FocusModule:init(handler)
		self.npcHandler = handler

		local greetWords = self.greetWords or FOCUS_GREETWORDS
		for _, word in pairs(greetWords) do
			local obj = {}
			obj[#obj + 1] = word
			obj.callback = self.greetCallback or FocusModule.messageMatcherDefault
			handler.keywordHandler:addKeyword(obj, FocusModule.onGreet, {module = self})
		end

		local farewellWords = self.farewellWords or FOCUS_FAREWELLWORDS
		for _, word in pairs(farewellWords) do
			local obj = {}
			obj[#obj + 1] = word
			obj.callback = self.farewellCallback or FocusModule.messageMatcherDefault
			handler.keywordHandler:addKeyword(obj, FocusModule.onFarewell, {module = self})
		end

		return true
	end

	-- Set custom greeting messages
	function FocusModule:addGreetMessage(message)
		if not self.greetWords then
			self.greetWords = {}
		end


		if type(message) == 'string' then
			table.insert(self.greetWords, message)
		else
			for i = 1, #message do
				table.insert(self.greetWords, message[i])
			end
		end
	end

	-- Set custom farewell messages
	function FocusModule:addFarewellMessage(message)
		if not self.farewellWords then
			self.farewellWords = {}
		end

		if type(message) == 'string' then
			table.insert(self.farewellWords, message)
		else
			for i = 1, #message do
				table.insert(self.farewellWords, message[i])
			end
		end
	end

	-- Set custom greeting callback
	function FocusModule:setGreetCallback(callback)
		self.greetCallback = callback
	end

	-- Set custom farewell callback
	function FocusModule:setFarewellCallback(callback)
		self.farewellCallback = callback
	end

	-- Greeting callback function.
	function FocusModule.onGreet(cid, message, keywords, parameters)
		parameters.module.npcHandler:onGreet(cid, message)
		return true
	end

	-- UnGreeting callback function.
	function FocusModule.onFarewell(cid, message, keywords, parameters)
		if parameters.module.npcHandler:isFocused(cid) then
			parameters.module.npcHandler:onFarewell(cid)
			return true
		else
			return false
		end
	end

	-- Custom message matching callback function for greeting messages.
	function FocusModule.messageMatcherDefault(keywords, message)
		for _, word in pairs(keywords) do
			if type(word) == "string" then
				if string.find(message, word) and not string.find(message, "[%w+]" .. word) and not string.find(message, word .. "[%w+]") then
					return true
				end
			end
		end
		return false
	end

	function FocusModule.messageMatcherStart(keywords, message)
		for _, word in pairs(keywords) do
			if type(word) == "string" then
				if string.starts(message, word) then
					return true
				end
			end
		end
		return false
	end

	KeywordModule = {
		npcHandler = nil
	}
	-- Add it to the parseable module list.
	Modules.parseableModules["module_keywords"] = KeywordModule

	function KeywordModule:new()
		local obj = {}
		setmetatable(obj, self)
		self.__index = self
		return obj
	end

	function KeywordModule:init(handler)
		self.npcHandler = handler
		return true
	end

	-- Parses all known parameters.
	function KeywordModule:parseParameters()
		local ret = NpcSystem.getParameter("keywords")
		if ret then
			self:parseKeywords(ret)
		end
	end

	function KeywordModule:parseKeywords(data)
		local n = 1
		for keys in string.gmatch(data, "[^;]+") do
			local i = 1

			local keywords = {}
			for temp in string.gmatch(keys, "[^,]+") do
				keywords[#keywords + 1] = temp
				i = i + 1
			end

			if i ~= 1 then
				local reply = NpcSystem.getParameter("keyword_reply" .. n)
				if reply then
					self:addKeyword(keywords, reply)
				else
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Parameter '" .. "keyword_reply" .. n .. "' missing. Skipping...")
				end
			else
				print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "No keywords found for keyword set #" .. n .. ". Skipping...")
			end

			n = n+1
		end
	end

	function KeywordModule:addKeyword(keywords, reply)
		self.npcHandler.keywordHandler:addKeyword(keywords, StdModule.say, {npcHandler = self.npcHandler, text = reply, reset = true})
	end

	TravelModule = {
		npcHandler = nil,
		destinations = nil,
		yesNode = nil,
		noNode = nil,
	}
	-- Add it to the parseable module list.
	Modules.parseableModules["module_travel"] = TravelModule

	function TravelModule:new()
		local obj = {}
		setmetatable(obj, self)
		self.__index = self
		return obj
	end

	function TravelModule:init(handler)
		self.npcHandler = handler
		self.yesNode = KeywordNode:new(SHOP_YESWORD, TravelModule.onConfirm, {module = self})
		self.noNode = KeywordNode:new(SHOP_NOWORD, TravelModule.onDecline, {module = self})
		self.destinations = {}
		return true
	end

	-- Parses all known parameters.
	function TravelModule:parseParameters()
		local ret = NpcSystem.getParameter("travel_destinations")
		if ret then
			self:parseDestinations(ret)

			self.npcHandler.keywordHandler:addKeyword({"destination"}, TravelModule.listDestinations, {module = self})
			self.npcHandler.keywordHandler:addKeyword({"where"}, TravelModule.listDestinations, {module = self})
			self.npcHandler.keywordHandler:addKeyword({"travel"}, TravelModule.listDestinations, {module = self})

		end
	end

	function TravelModule:parseDestinations(data)
		for destination in string.gmatch(data, "[^;]+") do
			local i = 1

			local name = nil
			local x = nil
			local y = nil
			local z = nil
			local cost = nil
			local premium = false

			for temp in string.gmatch(destination, "[^,]+") do
				if i == 1 then
					name = temp
				elseif i == 2 then
					x = tonumber(temp)
				elseif i == 3 then
					y = tonumber(temp)
				elseif i == 4 then
					z = tonumber(temp)
				elseif i == 5 then
					cost = tonumber(temp)
				elseif i == 6 then
					premium = temp == "true"
				else
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Unknown parameter found in travel destination parameter.", temp, destination)
				end
				i = i + 1
			end

			if(name and x and y and z and cost) then
				self:addDestination(name, {x=x, y=y, z=z}, cost, premium)
			else
				print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Parameter(s) missing for travel destination:", name, x, y, z, cost, premium)
			end
		end
	end

	function TravelModule:addDestination(name, position, price, premium)
		self.destinations[#self.destinations + 1] = name

		local parameters = {
			cost = price,
			destination = position,
			premium = premium,
			module = self
		}
		local keywords = {}
		keywords[#keywords + 1] = name

		local keywords2 = {}
		keywords2[#keywords2 + 1] = "bring me to " .. name
		local node = self.npcHandler.keywordHandler:addKeyword(keywords, TravelModule.travel, parameters)
		self.npcHandler.keywordHandler:addKeyword(keywords2, TravelModule.bringMeTo, parameters)
		node:addChildKeywordNode(self.yesNode)
		node:addChildKeywordNode(self.noNode)

		if npcs_loaded_travel[getNpcCid()] == nil then
			npcs_loaded_travel[getNpcCid()] = getNpcCid()
			self.npcHandler.keywordHandler:addKeyword({'yes'}, TravelModule.onConfirm, {module = self})
			self.npcHandler.keywordHandler:addKeyword({'no'}, TravelModule.onDecline, {module = self})
		end
	end

	function TravelModule.travel(cid, message, keywords, parameters, node)
		local module = parameters.module
		if(not module.npcHandler:isFocused(cid)) then
			return false
		end

		local npcHandler = module.npcHandler

		shop_destination[cid] = parameters.destination
		shop_cost[cid] = parameters.cost
		shop_premium[cid] = parameters.premium
		shop_npcuid[cid] = getNpcCid()

		local cost = parameters.cost
		local destination = parameters.destination
		local premium = parameters.premium

		module.npcHandler:say("Do you want to travel to " .. keywords[1] .. " for " .. cost .. " gold coins?", cid)
		return true
	end

	function TravelModule.onConfirm(cid, message, keywords, parameters, node)
		local module = parameters.module
		if not module.npcHandler:isFocused(cid) then
			return false
		end

		if shop_npcuid[cid] ~= getNpcCid() then
			return false
		end

		local npcHandler = module.npcHandler

		local parentParameters = node:getParent():getParameters()
		local cost = shop_cost[cid]
		local destination = shop_destination[cid]
		local premium = shop_premium[cid]

		local player = Player(cid)
		if not isPlayerPremiumCallback or isPlayerPremiumCallback(player) or shop_premium[cid] ~= true then
			if not player:removeTotalMoney(cost) then
				npcHandler:say("You do not have enough money!", cid)
			elseif player:isPzLocked() then
				npcHandler:say("Get out of there with this blood.", cid)
			else
				npcHandler:say("It was a pleasure doing business with you.", cid)
				npcHandler:releaseFocus(cid)
				-- Todo convert all destionation parameters to Position(x, y, z) instead of lua tables
				player:teleportTo(destination)
				Position(destination):sendMagicEffect(CONST_ME_TELEPORT)
			end
		else
			npcHandler:say("I can only allow premium players to travel there.", cid)
		end

		npcHandler:resetNpc(cid)
		return true
	end

	-- onDecline keyword callback function. Generally called when the player sais "no" after wanting to buy an item.
	function TravelModule.onDecline(cid, message, keywords, parameters, node)
		local module = parameters.module
		if not module.npcHandler:isFocused(cid) or shop_npcuid[cid] ~= getNpcCid() then
			return false
		end
		local parentParameters = node:getParent():getParameters()
		local parseInfo = { [TAG_PLAYERNAME] = Player(cid):getName() }
		local msg = module.npcHandler:parseMessage(module.npcHandler:getMessage(MESSAGE_DECLINE), parseInfo)
		module.npcHandler:say(msg, cid)
		module.npcHandler:resetNpc(cid)
		return true
	end

	function TravelModule.bringMeTo(cid, message, keywords, parameters, node)
		local module = parameters.module
		if not module.npcHandler:isFocused(cid) then
			return false
		end

		local cost = parameters.cost
		local destination = parameters.destination
		local premium = parameters.premium

		if(not isPlayerPremiumCallback or isPlayerPremiumCallback(cid) or parameters.premium ~= true) then
			local player = Player(cid)
			if player:removeTotalMoney(cost) then
				player:teleportTo(destination)
				Position(destination):sendMagicEffect(CONST_ME_TELEPORT)
			end
		end
		return true
	end

	function TravelModule.listDestinations(cid, message, keywords, parameters, node)
		local module = parameters.module
		if not module.npcHandler:isFocused(cid) then
			return false
		end

		local msg = "I can bring you to "
		--local i = 1
		local maxn = #module.destinations
		for i, destination in pairs(module.destinations) do
			msg = msg .. destination
			if i == maxn - 1 then
				msg = msg .. " and "
			elseif i == maxn then
				msg = msg .. "."
			else
				msg = msg .. ", "
			end
			i = i + 1
		end

		module.npcHandler:say(msg, cid)
		module.npcHandler:resetNpc(cid)
		return true
	end

	ShopModule = {
		npcHandler = nil,
		yesNode = nil,
		noNode = nil,
		noText = "",
		maxCount = 10000,
		amount = 0
	}

	-- Add it to the parseable module list.
	Modules.parseableModules["module_shop"] = ShopModule

	-- Creates a new instance of ShopModule
	function ShopModule:new()
		local obj = {}
		setmetatable(obj, self)
		self.__index = self
		return obj
	end

	-- Parses all known parameters.
	function ShopModule:parseParameters()
		local ret = NpcSystem.getParameter("shop_buyable")
		if ret then
			self:parseBuyable(ret)
		end

		local ret = NpcSystem.getParameter("shop_sellable")
		if ret then
			self:parseSellable(ret)
		end

		local ret = NpcSystem.getParameter("shop_buyable_containers")
		if ret then
			self:parseBuyableContainers(ret)
		end
	end

	-- Parse a string contaning a set of buyable items.
	function ShopModule:parseBuyable(data)
		for item in string.gmatch(data, "[^;]+") do
			local i = 1

			local name = nil
			local itemid = nil
			local cost = nil
			local subType = nil
			local realName = nil

			for temp in string.gmatch(item, "[^,]+") do
				if i == 1 then
					name = temp
				elseif i == 2 then
					itemid = tonumber(temp)
				elseif i == 3 then
					cost = tonumber(temp)
				elseif i == 4 then
					subType = tonumber(temp)
				elseif i == 5 then
					realName = temp
				else
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Unknown parameter found in buyable items parameter.", temp, item)
				end
				i = i + 1
			end

			if SHOPMODULE_MODE == SHOPMODULE_MODE_TRADE then
				if itemid and cost then
					if subType == nil and ItemType(itemid):isFluidContainer() then
						print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "SubType missing for parameter item:", item)
					else
						self:addBuyableItem(nil, itemid, cost, subType, realName)
					end
				else
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Parameter(s) missing for item:", itemid, cost)
				end
			else
				if name and itemid  and cost  then
					if subType == nil and ItemType(itemid):isFluidContainer() then
						print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "SubType missing for parameter item:", item)
					else
						local names = {}
						names[#names + 1] = name
						self:addBuyableItem(names, itemid, cost, subType, realName)
					end
				else
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Parameter(s) missing for item:", name, itemid, cost)
				end
			end
		end
	end

	-- Parse a string contaning a set of sellable items.
	function ShopModule:parseSellable(data)
		for item in string.gmatch(data, "[^;]+") do
			local i = 1

			local name = nil
			local itemid = nil
			local cost = nil
			local realName = nil
			local subType = nil

			for temp in string.gmatch(item, "[^,]+") do
				if i == 1 then
					name = temp
				elseif i == 2 then
					itemid = tonumber(temp)
				elseif i == 3 then
					cost = tonumber(temp)
				elseif i == 4 then
					realName = temp
				elseif i == 5 then
					subType = tonumber(temp)
				else
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Unknown parameter found in sellable items parameter.", temp, item)
				end
				i = i + 1
			end

			if SHOPMODULE_MODE == SHOPMODULE_MODE_TRADE then
				if itemid and cost then
					self:addSellableItem(nil, itemid, cost, realName, subType)
				else
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Parameter(s) missing for item:", itemid, cost)
				end
			else
				if name and itemid  and cost  then
					local names = {}
					names[#names + 1] = name
					self:addSellableItem(names, itemid, cost, realName, subType)
				else
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Parameter(s) missing for item:", name, itemid, cost)
				end
			end
		end
	end

	-- Parse a string contaning a set of buyable items.
	function ShopModule:parseBuyableContainers(data)
		for item in string.gmatch(data, "[^;]+") do
			local i = 1

			local name = nil
			local container = nil
			local itemid = nil
			local cost = nil
			local subType = nil
			local realName = nil

			for temp in string.gmatch(item, "[^,]+") do
				if i == 1 then
					name = temp
				elseif i == 2 then
					itemid = tonumber(temp)
				elseif i == 3 then
					itemid = tonumber(temp)
				elseif i == 4 then
					cost = tonumber(temp)
				elseif i == 5 then
					subType = tonumber(temp)
				elseif i == 6 then
					realName = temp
				else
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Unknown parameter found in buyable items parameter.", temp, item)
				end
				i = i + 1
			end

			if name and container and itemid and cost then
				if subType == nil and ItemType(itemid):isFluidContainer() then
					print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "SubType missing for parameter item:", item)
				else
					local names = {}
					names[#names + 1] = name
					self:addBuyableItemContainer(names, container, itemid, cost, subType, realName)
				end
			else
				print("[Warning : " .. Npc():getName() .. "] NpcSystem:", "Parameter(s) missing for item:", name, container, itemid, cost)
			end
		end
	end

	-- Initializes the module and associates handler to it.
	function ShopModule:init(handler)
		self.npcHandler = handler
		self.yesNode = KeywordNode:new(SHOP_YESWORD, ShopModule.onConfirm, {module = self})
		self.noNode = KeywordNode:new(SHOP_NOWORD, ShopModule.onDecline, {module = self})
		self.noText = handler:getMessage(MESSAGE_DECLINE)

		if SHOPMODULE_MODE ~= SHOPMODULE_MODE_TALK then
			for _, word in pairs(SHOP_TRADEREQUEST) do
				local obj = {}
				obj[#obj + 1] = word
				obj.callback = SHOP_TRADEREQUEST.callback or ShopModule.messageMatcher
				handler.keywordHandler:addKeyword(obj, ShopModule.requestTrade, {module = self})
			end
		end

		return true
	end

	-- Custom message matching callback function for requesting trade messages.
	function ShopModule.messageMatcher(keywords, message)
		for _, word in pairs(keywords) do
			if type(word) == "string" then
				if string.find(message, word) and not string.find(message, "[%w+]" .. word) and not string.find(message, word .. "[%w+]") then
					return true
				end
			end
		end

		return false
	end

	-- Resets the module-specific variables.
	function ShopModule:reset()
		self.amount = 0
	end

	-- Function used to match a number value from a string.
	function ShopModule:getCount(message)
		local ret = 1
		local b, e = string.find(message, PATTERN_COUNT)
		if b and e then
			ret = tonumber(string.sub(message, b, e))
		end

		if ret <= 0 then
			ret = 1
		elseif ret > self.maxCount then
			ret = self.maxCount
		end

		return ret
	end

	-- Adds a new buyable item.
	--	names = A table containing one or more strings of alternative names to this item. Used only for old buy/sell system.
	--	itemid = The itemid of the buyable item
	--	cost = The price of one single item
	--	subType - The subType of each rune or fluidcontainer item. Can be left out if it is not a rune/fluidcontainer. Default value is 1.
	--	realName - The real, full name for the item. Will be used as ITEMNAME in MESSAGE_ONBUY and MESSAGE_ONSELL if defined. Default value is nil (ItemType(itemId):getName() will be used)
	function ShopModule:addBuyableItem(names, itemid, cost, itemSubType, realName)
		if SHOPMODULE_MODE ~= SHOPMODULE_MODE_TALK then
			if itemSubType == nil then
				itemSubType = 1
			end

			local shopItem = self:getShopItem(itemid, itemSubType)
			if shopItem == nil then
				self.npcHandler.shopItems[#self.npcHandler.shopItems + 1] = {id = itemid, buy = cost, sell = -1, subType = itemSubType, name = realName or ItemType(itemid):getName()}
			else
				shopItem.buy = cost
			end
		end

		if names and SHOPMODULE_MODE ~= SHOPMODULE_MODE_TRADE then
			for _, name in pairs(names) do
				local parameters = {
						itemid = itemid,
						cost = cost,
						eventType = SHOPMODULE_BUY_ITEM,
						module = self,
						realName = realName or ItemType(itemid):getName(),
						subType = itemSubType or 1
					}

				keywords = {}
				keywords[#keywords + 1] = "buy"
				keywords[#keywords + 1] = name
				local node = self.npcHandler.keywordHandler:addKeyword(keywords, ShopModule.tradeItem, parameters)
				node:addChildKeywordNode(self.yesNode)
				node:addChildKeywordNode(self.noNode)
			end
		end

		if npcs_loaded_shop[getNpcCid()] == nil then
			npcs_loaded_shop[getNpcCid()] = getNpcCid()
			self.npcHandler.keywordHandler:addKeyword({'yes'}, ShopModule.onConfirm, {module = self})
			self.npcHandler.keywordHandler:addKeyword({'no'}, ShopModule.onDecline, {module = self})
		end
	end

	function ShopModule:getShopItem(itemId, itemSubType)
		if ItemType(itemId):isFluidContainer() then
			for i = 1, #self.npcHandler.shopItems do
				local shopItem = self.npcHandler.shopItems[i]
				if shopItem.id == itemId and shopItem.subType == itemSubType then
					return shopItem
				end
			end
		else
			for i = 1, #self.npcHandler.shopItems do
				local shopItem = self.npcHandler.shopItems[i]
				if shopItem.id == itemId then
					return shopItem
				end
			end
		end
		return nil
	end

	-- Adds a new buyable container of items.
	--	names = A table containing one or more strings of alternative names to this item.
	--	container = Backpack, bag or any other itemid of container where bought items will be stored
	--	itemid = The itemid of the buyable item
	--	cost = The price of one single item
	--	subType - The subType of each rune or fluidcontainer item. Can be left out if it is not a rune/fluidcontainer. Default value is 1.
	--	realName - The real, full name for the item. Will be used as ITEMNAME in MESSAGE_ONBUY and MESSAGE_ONSELL if defined. Default value is nil (ItemType(itemId):getName() will be used)
	function ShopModule:addBuyableItemContainer(names, container, itemid, cost, subType, realName)
		if names then
			for _, name in pairs(names) do
				local parameters = {
						container = container,
						itemid = itemid,
						cost = cost,
						eventType = SHOPMODULE_BUY_ITEM_CONTAINER,
						module = self,
						realName = realName or ItemType(itemid):getName(),
						subType = subType or 1
					}

				keywords = {}
				keywords[#keywords + 1] = "buy"
				keywords[#keywords + 1] = name
				local node = self.npcHandler.keywordHandler:addKeyword(keywords, ShopModule.tradeItem, parameters)
				node:addChildKeywordNode(self.yesNode)
				node:addChildKeywordNode(self.noNode)
			end
		end
	end

	-- Adds a new sellable item.
	--	names = A table containing one or more strings of alternative names to this item. Used only by old buy/sell system.
	--	itemid = The itemid of the sellable item
	--	cost = The price of one single item
	--	realName - The real, full name for the item. Will be used as ITEMNAME in MESSAGE_ONBUY and MESSAGE_ONSELL if defined. Default value is nil (getName will be used)
	function ShopModule:addSellableItem(names, itemid, cost, realName, itemSubType)
		if SHOPMODULE_MODE ~= SHOPMODULE_MODE_TALK then
			if itemSubType == nil then
				itemSubType = 0
			end

			local shopItem = self:getShopItem(itemid, itemSubType)
			if shopItem == nil then
				table.insert(self.npcHandler.shopItems, {id = itemid, buy = -1, sell = cost, subType = itemSubType, name = realName or ItemType(itemid):getName()})
			else
				shopItem.sell = cost
			end
		end

		if (names and SHOPMODULE_MODE ~= SHOPMODULE_MODE_TRADE) then
			for i = 1, #names do
				local parameters = {
					itemid = itemid,
					cost = cost,
					eventType = SHOPMODULE_SELL_ITEM,
					module = self,
					realName = realName or ItemType(itemid):getName()
				}

				keywords = {}
				table.insert(keywords, "sell")
				table.insert(keywords, name)
				local node = self.npcHandler.keywordHandler:addKeyword(keywords, ShopModule.tradeItem, parameters)
				node:addChildKeywordNode(self.yesNode)
				node:addChildKeywordNode(self.noNode)
			end
		end
	end

	-- onModuleReset callback function. Calls ShopModule:reset()
	function ShopModule:callbackOnModuleReset()
		self:reset()
		return true
	end

	-- Callback onBuy() function. If you wish, you can change certain Npc to use your onBuy().
	function ShopModule:callbackOnBuy(cid, itemid, subType, amount, ignoreCap, inBackpacks)
		local shopItem = self:getShopItem(itemid, subType)
		if shopItem == nil then
			error("[ShopModule.onBuy] shopItem == nil")
			return false
		end

		if shopItem.buy == -1 then
			error("[ShopModule.onSell] attempt to buy a non-buyable item")
			return false
		end

		--local backpack = 23782
		local totalCost = amount * shopItem.buy
		if inBackpacks then
			totalCost = ItemType(itemid):isStackable() and totalCost + 20 or totalCost + (math.max(1, math.floor(amount / ItemType(ITEM_SHOPPING_BAG):getCapacity())) * 20)
		end

		local player = Player(cid)
		local parseInfo = {
			[TAG_PLAYERNAME] = player:getName(),
			[TAG_ITEMCOUNT] = amount,
			[TAG_TOTALCOST] = totalCost,
			[TAG_ITEMNAME] = shopItem.name
		}

		if player:getTotalMoney() < totalCost then
			local msg = self.npcHandler:getMessage(MESSAGE_NEEDMONEY)
			msg = self.npcHandler:parseMessage(msg, parseInfo)
			player:sendCancelMessage(msg)
			return false
		end

		local subType = shopItem.subType or 1
		local a, b = doNpcSellItem(cid, itemid, amount, subType, ignoreCap, inBackpacks, ITEM_SHOPPING_BAG)
		if(a < amount) then
			local msgId = MESSAGE_NEEDMORESPACE
			if(a == 0) then
				msgId = MESSAGE_NEEDSPACE
			end

			local msg = self.npcHandler:getMessage(msgId)
			parseInfo[TAG_ITEMCOUNT] = a
			msg = self.npcHandler:parseMessage(msg, parseInfo)
			player:sendCancelMessage(msg)
			self.npcHandler.talkStart[cid] = os.time()

			if(a > 0) then
				player:removeTotalMoney((a * shopItem.buy) + (b * 20))
				return true
			end

			return false
		else
			local msg = self.npcHandler:getMessage(MESSAGE_BOUGHT)
			msg = self.npcHandler:parseMessage(msg, parseInfo)
			player:sendTextMessage(MESSAGE_INFO_DESCR, msg)
			if not player:removeTotalMoney(totalCost) then
				return false
			end
			self.npcHandler.talkStart[cid] = os.time()
			return true
		end
	end

	-- Callback onSell() function. If you wish, you can change certain Npc to use your onSell().
	function ShopModule:callbackOnSell(cid, itemid, subType, amount, ignoreEquipped, _)
		local shopItem = self:getShopItem(itemid, subType)
		if shopItem == nil then
			error("[ShopModule.onSell] items[itemid] == nil")
			return false
		end

		if shopItem.sell == -1 then
--			error("[ShopModule.onSell] attempt to sell a non-sellable item")
			return false
		end

		local player = Player(cid)
		local parseInfo = {
			[TAG_PLAYERNAME] = player:getName(),
			[TAG_ITEMCOUNT] = amount,
			[TAG_TOTALCOST] = amount * shopItem.sell,
			[TAG_ITEMNAME] = shopItem.name
		}

		if not ItemType(itemid):isFluidContainer() then
			subType = -1
		end

		if player:removeItem(itemid, amount, subType, ignoreEquipped) then
			local msg = self.npcHandler:getMessage(MESSAGE_SOLD)
			msg = self.npcHandler:parseMessage(msg, parseInfo)
			player:sendTextMessage(MESSAGE_INFO_DESCR, msg)
			player:addMoney(amount * shopItem.sell)
			self.npcHandler.talkStart[cid] = os.time()
			return true
		else
			local msg = self.npcHandler:getMessage(MESSAGE_NEEDITEM)
			msg = self.npcHandler:parseMessage(msg, parseInfo)
			player:sendCancelMessage(msg)
			self.npcHandler.talkStart[cid] = os.time()
			return false
		end
	end

	-- Callback for requesting a trade window with the NPC.
	function ShopModule.requestTrade(cid, message, keywords, parameters, node)
		local module = parameters.module
		if(not module.npcHandler:isFocused(cid)) then
			return false
		end

		if(not module.npcHandler:onTradeRequest(cid)) then
			return false
		end

		local itemWindow = {}
		for i = 1, #module.npcHandler.shopItems do
			table.insert(itemWindow, module.npcHandler.shopItems[i])
		end

		if itemWindow[1] == nil then
			local parseInfo = { [TAG_PLAYERNAME] = Player(cid):getName() }
			local msg = module.npcHandler:parseMessage(module.npcHandler:getMessage(MESSAGE_NOSHOP), parseInfo)
			module.npcHandler:say(msg, cid)
			return true
		end

		local parseInfo = { [TAG_PLAYERNAME] = Player(cid):getName() }
		local msg = module.npcHandler:parseMessage(module.npcHandler:getMessage(MESSAGE_SENDTRADE), parseInfo)
		openShopWindow(cid, itemWindow,
			function(cid, itemid, subType, amount, ignoreCap, inBackpacks) module.npcHandler:onBuy(cid, itemid, subType, amount, ignoreCap, inBackpacks) end,
			function(cid, itemid, subType, amount, ignoreCap, inBackpacks) module.npcHandler:onSell(cid, itemid, subType, amount, ignoreCap, inBackpacks) end)
		module.npcHandler:say(msg, cid)
		return true
	end

	-- onConfirm keyword callback function. Sells/buys the actual item.
	function ShopModule.onConfirm(cid, message, keywords, parameters, node)
		local module = parameters.module
		if(not module.npcHandler:isFocused(cid)) or shop_npcuid[cid] ~= getNpcCid() then
			return false
		end
		shop_npcuid[cid] = 0

		local parentParameters = node:getParent():getParameters()
		local parseInfo = {
			[TAG_PLAYERNAME] = Player(cid):getName(),
			[TAG_ITEMCOUNT] = shop_amount[cid],
			[TAG_TOTALCOST] = shop_cost[cid] * shop_amount[cid],
			[TAG_ITEMNAME] = shop_rlname[cid]
		}

		if(shop_eventtype[cid] == SHOPMODULE_SELL_ITEM) then
			local ret = doPlayerSellItem(cid, shop_itemid[cid], shop_amount[cid], shop_cost[cid] * shop_amount[cid])
			if ret then
				local msg = module.npcHandler:getMessage(MESSAGE_ONSELL)
				msg = module.npcHandler:parseMessage(msg, parseInfo)
				module.npcHandler:say(msg, cid)
			else
				local msg = module.npcHandler:getMessage(MESSAGE_MISSINGITEM)
				msg = module.npcHandler:parseMessage(msg, parseInfo)
				module.npcHandler:say(msg, cid)
			end
		elseif(shop_eventtype[cid] == SHOPMODULE_BUY_ITEM) then
			local cost = shop_cost[cid] * shop_amount[cid]
			if Player(cid):getTotalMoney() < cost then
				local msg = module.npcHandler:getMessage(MESSAGE_MISSINGMONEY)
				msg = module.npcHandler:parseMessage(msg, parseInfo)
				module.npcHandler:say(msg, cid)
				return false
			end

			local a, b = doNpcSellItem(cid, shop_itemid[cid], shop_amount[cid], shop_subtype[cid], false, false, ITEM_SHOPPING_BAG)
			if(a < shop_amount[cid]) then
				local msgId = MESSAGE_NEEDMORESPACE
				if(a == 0) then
					msgId = MESSAGE_NEEDSPACE
				end

				local msg = module.npcHandler:getMessage(msgId)
				msg = module.npcHandler:parseMessage(msg, parseInfo)
				module.npcHandler:say(msg, cid)
				if(a > 0) then
					Player(cid):removeTotalMoney(a * shop_cost[cid])
					if shop_itemid[cid] == ITEM_PARCEL then
						doNpcSellItem(cid, ITEM_LABEL, shop_amount[cid], shop_subtype[cid], true, false, ITEM_SHOPPING_BAG)
					end
					return true
				end
				return false
			else
				local msg = module.npcHandler:getMessage(MESSAGE_ONBUY)
				msg = module.npcHandler:parseMessage(msg, parseInfo)
				module.npcHandler:say(msg, cid)
				Player(cid):removeTotalMoney(cost)
				if shop_itemid[cid] == ITEM_PARCEL then
					doNpcSellItem(cid, ITEM_LABEL, shop_amount[cid], shop_subtype[cid], true, false, ITEM_SHOPPING_BAG)
				end
				return true
			end
		elseif(shop_eventtype[cid] == SHOPMODULE_BUY_ITEM_CONTAINER) then
			local ret = doPlayerBuyItemContainer(cid, shop_container[cid], shop_itemid[cid], shop_amount[cid], shop_cost[cid] * shop_amount[cid], shop_subtype[cid])
			if ret then
				local msg = module.npcHandler:getMessage(MESSAGE_ONBUY)
				msg = module.npcHandler:parseMessage(msg, parseInfo)
				module.npcHandler:say(msg, cid)
			else
				local msg = module.npcHandler:getMessage(MESSAGE_MISSINGMONEY)
				msg = module.npcHandler:parseMessage(msg, parseInfo)
				module.npcHandler:say(msg, cid)
			end
		end

		module.npcHandler:resetNpc(cid)
		return true
	end

	-- onDecline keyword callback function. Generally called when the player sais "no" after wanting to buy an item.
	function ShopModule.onDecline(cid, message, keywords, parameters, node)
		local module = parameters.module
		if(not module.npcHandler:isFocused(cid)) or shop_npcuid[cid] ~= getNpcCid() then
			return false
		end
		shop_npcuid[cid] = 0

		local parentParameters = node:getParent():getParameters()
		local parseInfo = {
			[TAG_PLAYERNAME] = Player(cid):getName(),
			[TAG_ITEMCOUNT] = shop_amount[cid],
			[TAG_TOTALCOST] = shop_cost[cid] * shop_amount[cid],
			[TAG_ITEMNAME] = shop_rlname[cid]
		}

		local msg = module.npcHandler:parseMessage(module.noText, parseInfo)
		module.npcHandler:say(msg, cid)
		module.npcHandler:resetNpc(cid)
		return true
	end

	-- tradeItem callback function. Makes the npc say the message defined by MESSAGE_BUY or MESSAGE_SELL
	function ShopModule.tradeItem(cid, message, keywords, parameters, node)
		local module = parameters.module
		if(not module.npcHandler:isFocused(cid)) then
			return false
		end

		if(not module.npcHandler:onTradeRequest(cid)) then
			return true
		end

		local count = module:getCount(message)
		module.amount = count

		shop_amount[cid] = module.amount
		shop_cost[cid] = parameters.cost
		shop_rlname[cid] = parameters.realName
		shop_itemid[cid] = parameters.itemid
		shop_container[cid] = parameters.container
		shop_npcuid[cid] = getNpcCid()
		shop_eventtype[cid] = parameters.eventType
		shop_subtype[cid] = parameters.subType

		local parseInfo = {
			[TAG_PLAYERNAME] = Player(cid):getName(),
			[TAG_ITEMCOUNT] = shop_amount[cid],
			[TAG_TOTALCOST] = shop_cost[cid] * shop_amount[cid],
			[TAG_ITEMNAME] = shop_rlname[cid]
		}

		if(shop_eventtype[cid] == SHOPMODULE_SELL_ITEM) then
			local msg = module.npcHandler:getMessage(MESSAGE_SELL)
			msg = module.npcHandler:parseMessage(msg, parseInfo)
			module.npcHandler:say(msg, cid)
		elseif(shop_eventtype[cid] == SHOPMODULE_BUY_ITEM) then
			local msg = module.npcHandler:getMessage(MESSAGE_BUY)
			msg = module.npcHandler:parseMessage(msg, parseInfo)
			module.npcHandler:say(msg, cid)
		elseif(shop_eventtype[cid] == SHOPMODULE_BUY_ITEM_CONTAINER) then
			local msg = module.npcHandler:getMessage(MESSAGE_BUY)
			msg = module.npcHandler:parseMessage(msg, parseInfo)
			module.npcHandler:say(msg, cid)
		end
		return true
	end

	VoiceModule = {
		voices = nil,
		voiceCount = 0,
		lastVoice = 0,
		timeout = nil,
		chance = nil
	}
	-- VoiceModule: makes the NPC say/yell random lines from a table, with delay, chance and yell optional 
	function VoiceModule:new(voices, timeout, chance)
		local obj = {}
		setmetatable(obj, self)
		self.__index = self
		obj.voices = voices
		for i = 1, #obj.voices do
			local voice = obj.voices[i]
			if voice.yell then
				voice.yell = nil
				voice.talktype = TALKTYPE_YELL
			else
				voice.talktype = TALKTYPE_SAY
			end
		end
		obj.voiceCount = #voices
		obj.timeout = timeout or 10
		obj.chance = chance or 10
		return obj
	end
	function VoiceModule:init(handler)
		return true
	end
	function VoiceModule:callbackOnThink()
		if self.lastVoice < os.time() then
			self.lastVoice = os.time() + self.timeout
			if math.random(100) <= self.chance  then
				local voice = self.voices[math.random(self.voiceCount)]
				Npc():say(voice.text, voice.talktype)
			end
		end
		return true
	end
end
