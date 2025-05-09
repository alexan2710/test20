local shutdownAtServerSave = false
local cleanMapAtServerSave = true

local function serverSave()
	if shutdownAtServerSave then
		Game.setGameState(GAME_STATE_SHUTDOWN)
	else
--		Game.setGameState(GAME_STATE_CLOSED)

		if cleanMapAtServerSave then
			cleanMap()
		end

--		Game.setGameState(GAME_STATE_NORMAL)
		saveServer()
		loadHighscoreOnStartup()
		loadHighscorePvPOnStartup()
	end
end

local function secondServerSaveWarning()
	-- broadcastMessage("Server is saving game in one minute. Please mind it may freeze.", MESSAGE_STATUS_WARNING)
	-- addEvent(serverSave, 60000)
end

local function firstServerSaveWarning()
	-- broadcastMessage("Server is saving game in 3 minutes. Please mind it may freeze.", MESSAGE_STATUS_WARNING)
	-- addEvent(secondServerSaveWarning, 120000)
end

function onThink(interval)
	-- broadcastMessage("Server is saving game in 5 minutes. Please mind it may freeze.", MESSAGE_STATUS_WARNING)
--	Game.setGameState(GAME_STATE_STARTUP)
	-- addEvent(firstServerSaveWarning, 120000)
	return not shutdownAtServerSave
end
