--freeRoamMP (CLIENT) by Dudekahedron, 2024

local M = {}

local freeRoam = false
local syncRequested = false

local prefabsTable = {}

local iterT = {}
local iterC = 0

local function handlePrefabsA(path, name)
	local f = io.open(path, "r")
	if f == nil then
		return
	end
	local originalContent = f:read("*all")
	f:close()
	local tempStringB = ""
	local sepA, sepB = 1, 1
	for i = 1, #originalContent do
		sepA = originalContent:find("{", sepB)
		sepB = originalContent:find("}", sepA)
		if not sepA or not sepB then
			break
		end
		local tempStringA = originalContent:sub(sepA, sepB)
		local matchA = string.find(tempStringA, "BeamNGVehicle", 1)
		if not matchA then
			tempStringB = tempStringB .. tempStringA .. "\n"
		end
	end
	local tempPath = "settings/BeamMP/tempPrefab" .. name ..".prefab.json"
	local tempFile = io.open(tempPath, "w+")
	if tempFile then
		tempFile:write(tempStringB)
		tempFile:close()
	end
	spawnPrefab(name, tempPath, "0 0 0", "0 0 1", "1 1 1")
end

local function handlePrefabsB(path, name)
	local f = io.open(path, "r")
	if f == nil then
		return
	end
	local originalContent = f:read("*all")
	f:close()
	local tempStringB = ""
	local index = 1
	for i = index, #originalContent do
		local startBeam = originalContent:find("   new BeamNGVehicle%(", index)
		if not startBeam then
			tempStringB = tempStringB .. originalContent:sub(index)
			break
		end
		tempStringB = tempStringB .. originalContent:sub(index, startBeam - 1)
		local endBeam = originalContent:find("};", startBeam)
		if endBeam then
			index = endBeam + 2
		else
			break
		end
	end
	local tempPath = "settings/BeamMP/tempPrefab" .. name ..".prefab"
	local tempFile = io.open(tempPath, "w+")
	if tempFile then
		tempFile:write(tempStringB)
		tempFile:close()
	end
	spawnPrefab(name, tempPath, "0 0 0", "0 0 1", "1 1 1")
end

local function onUpdate(dt)
	if worldReadyState == 2 then
		if not freeRoam then
			core_gamestate.setGameState('freeroam', 'multiplayer', 'multiplayer')
			freeRoam = true
		end
		if not syncRequested then
			TriggerServerEvent("freeRoamSyncRequested", "")
			syncRequested = true
		end
		for name, data in pairs(prefabsTable) do
			if data.outdated == true then
				handlePrefabsB(data.path, name)
				prefabsTable[name] = nil
				be:reloadCollision()
				break
			elseif data.outdated == false then
				handlePrefabsA(data.path, name)
				prefabsTable[name] = nil
				be:reloadCollision()
				break
			end
		end
	end
end

local function rxFreeRoamSync(data)
	if data ~= "null" then
		local vehicleStates = jsonDecode(data)
		for serverVid, state in pairs(vehicleStates) do
			local gameVid = MPVehicleGE.getGameVehicleID(serverVid)
			if gameVid ~= -1 then
				if not MPVehicleGE.isOwn(gameVid) then
					if not state.active then
						be:getObjectByID(gameVid):setActive(0)
					else
						be:getObjectByID(gameVid):setActive(1)
					end
				end
			end
		end
	end
end

local function rxPrefabSync(data)
	if data ~= "null" or data ~= nil then
		local prefab = jsonDecode(data)
		local userSettings = prefab.pSettings
		local main
		local deco
		local obstacles
		local forward
		local reverse
		if prefab.pLoad == true then
			if prefab.pPath then
				main = prefab.pPath .. '/mainPrefab.prefab.json'
				deco = prefab.pPath .. '/deco.prefab.json'
				obstacles = prefab.pPath .. '/obstacles.prefab.json'
				forward = prefab.pPath .. '/forwardPrefab.prefab.json'
				reverse = prefab.pPath .. '/reversePrefab.prefab.json'
			end
			if not FS:fileExists(deco) then
				deco = nil
			end
			if not FS:fileExists(obstacles) then
				obstacles = nil
			end
			if not FS:fileExists(main) then
				main = nil
				deco = prefab.pPath .. '/deco.prefab'
				obstacles = prefab.pPath .. '/obstacles.prefab'
				if deco and FS:fileExists(deco) then
					prefabsTable[prefab.pName .. "deco"] = {}
					prefabsTable[prefab.pName .. "deco"].path = deco
					prefabsTable[prefab.pName .. "deco"].outdated = true
				end
				if obstacles and FS:fileExists(obstacles) then
					prefabsTable[prefab.pName .. "obstacles"] = {}
					prefabsTable[prefab.pName .. "obstacles"].path = obstacles
					prefabsTable[prefab.pName .. "obstacles"].outdated = true
				end
				return
			end
			if not FS:fileExists(forward) then
				forward = nil
			end
			if not FS:fileExists(reverse) then
				reverse = nil
			end
			if deco then
				prefabsTable[prefab.pName .. "deco"] = {}
				prefabsTable[prefab.pName .. "deco"].path = deco
				prefabsTable[prefab.pName .. "deco"].outdated = false
			end
			if main then
				prefabsTable[prefab.pName .. "main"] = {}
				prefabsTable[prefab.pName .. "main"].path = main
				prefabsTable[prefab.pName .. "main"].outdated = false
			end
			if obstacles then
				prefabsTable[prefab.pName .. "obstacles"] = {}
				prefabsTable[prefab.pName .. "obstacles"].path = obstacles
				prefabsTable[prefab.pName .. "obstacles"].outdated = false
			end
			if forward and not userSettings.reverse then
				prefabsTable[prefab.pName .. "forward"] = {}
				prefabsTable[prefab.pName .. "forward"].path = forward
				prefabsTable[prefab.pName .. "forward"].outdated = false
			end
			if reverse and userSettings.reverse then
				prefabsTable[prefab.pName .. "reverse"] = {}
				prefabsTable[prefab.pName .. "reverse"].path = reverse
				prefabsTable[prefab.pName .. "reverse"].outdated = false
			end
		elseif prefab.pLoad == false then
			removePrefab(prefab.pName)
			if scenetree.findObject(prefab.pName .. "main") then
				removePrefab(prefab.pName .. "main")
			end
			if scenetree.findObject(prefab.pName .. "deco") then
				removePrefab(prefab.pName .. "deco")
			end
			if scenetree.findObject(prefab.pName .. "obstacles") then
				removePrefab(prefab.pName .. "obstacles")
			end
			if scenetree.findObject(prefab.pName .. "forward") then
				removePrefab(prefab.pName .. "forward")
			end
			if scenetree.findObject(prefab.pName .. "reverse") then
				removePrefab(prefab.pName .. "reverse")
			end
			be:reloadCollision()
		end
	end
end

local function rxFreeRoamVehicleActive(data)
	if data ~= "null" or data ~= nil then
		local tempData = jsonDecode(data)
		local active = tempData[1]
		local serverVid = tempData[2]
		if serverVid then
			local gameVid = MPVehicleGE.getGameVehicleID(serverVid)
			if gameVid ~= -1 then
				if not MPVehicleGE.isOwn(gameVid) then
					if not active then
						be:getObjectByID(gameVid):setActive(0)
					else
						be:getObjectByID(gameVid):setActive(1)
					end
				end
			end
		end
	end
end

local function onAnyMissionChanged(state, mission)
	if state == "stopped" then
		local prefab = {}
		prefab.pName = mission.missionType .. "-" .. tostring(iterT[mission.missionType])
		prefab.pLoad = false
		local data = jsonEncode(prefab)
		TriggerServerEvent("freeRoamPrefabSync", data)
		ui_fadeScreen.stop()
		core_gamestate.setGameState('freeroam', 'multiplayer', 'multiplayer')
	end
end

local function onMissionStartWithFade(mission, userSettings)
	local prefab = {}
	iterT[mission.missionType] = iterC
	prefab.pName = mission.missionType .. "-" .. tostring(iterT[mission.missionType])
	prefab.pPath = mission.missionFolder
	prefab.pSettings = userSettings
	prefab.pLoad = true
	local data = jsonEncode(prefab)
	TriggerServerEvent("freeRoamPrefabSync", data)
	iterC = iterC + 1
end

local function onVehicleActiveChanged(gameVid, active)
	if gameVid then
		if MPVehicleGE.isOwn(gameVid) then
			local serverVid = MPVehicleGE.getServerVehicleID(gameVid)
			if serverVid then
				local data = jsonEncode( { active, serverVid } )
				TriggerServerEvent("freeRoamVehicleActiveHandler", data)
			end
		else
			TriggerServerEvent("freeRoamVehSyncRequested", "")
		end
	end
end

local function onVehicleSpawned(gameVehicleID)
	local veh = be:getObjectByID(gameVehicleID)
	if veh then
		veh:setField('renderDistance', '', 6969)
	end
end

local function onExtensionLoaded()
	AddEventHandler("rxPrefabSync", rxPrefabSync)
	AddEventHandler("rxFreeRoamSync", rxFreeRoamSync)
	AddEventHandler("rxFreeRoamVehicleActive", rxFreeRoamVehicleActive)
	log('W', 'freeRoam', 'freeRoam LOADED!')
end

local function onExtensionUnloaded()
	log('W', 'freeRoam', 'freeRoam UNLOADED!')
end

M.onUpdate = onUpdate

M.onAnyMissionChanged = onAnyMissionChanged
M.onMissionStartWithFade = onMissionStartWithFade

M.onVehicleActiveChanged = onVehicleActiveChanged
M.onVehicleSpawned = onVehicleSpawned

M.onInit = function() setExtensionUnloadMode(M, 'manual') end

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

return M
