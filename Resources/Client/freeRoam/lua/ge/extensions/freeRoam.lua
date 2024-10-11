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
		local prefabData = jsonDecode(data)
		local userSettings = prefabData.pSettings
		local main
		local deco
		local obstacles
		local obstacles2
		local obstaclesfromFile
		local forward
		local reverse
		local arrive
		local ramp
		local p_drag_strip
		local p_drag_strip_l
		local p_drag_strip_r
		local prefab
		local screenFencesPrefab
		local road
		local vehicles
		if prefabData.pLoad == true then
			if prefabData.pPath then
				main = prefabData.pPath .. '/mainPrefab.prefab.json'
				deco = prefabData.pPath .. '/deco.prefab.json'
				obstacles = prefabData.pPath .. '/obstacles.prefab.json'
				obstacles2 = prefabData.pPath .. '/obstacles2.prefab.json'
				obstaclesfromFile = prefabData.pPath .. '/obstacles-fromFile.prefab.json'
				forward = prefabData.pPath .. '/forwardPrefab.prefab.json'
				reverse = prefabData.pPath .. '/reversePrefab.prefab.json'
				arrive = prefabData.pPath .. '/arrive.prefab.json'
				ramp = prefabData.pPath .. '/ramp.prefab.json'
				p_drag_strip = prefabData.pPath .. '/p_drag_strip.prefab.json'
				p_drag_strip_l = prefabData.pPath .. '/p_drag_strip_l.prefab.json'
				p_drag_strip_r = prefabData.pPath .. '/p_drag_strip_r.prefab.json'
				prefab = prefabData.pPath .. '/prefab.prefab.json'
				screenFencesPrefab = prefabData.pPath .. '/screenFencesPrefab.prefab.json'
				road = prefabData.pPath .. '/road.prefab.json'
				vehicles = prefabData.pPath .. '/vehicles.prefab.json'
			end
			if not FS:fileExists(main) then
				main = prefabData.pPath .. '/mainPrefab.prefab'
				if FS:fileExists(main) then
					prefabsTable[prefabData.pName .. "main"] = { path = main, outdated = true }
					log('W', 'freeRoamMP', 'Outdated main prefab found!')
				else
					main = nil
				end
			else
				prefabsTable[prefabData.pName .. "main"] = { path = main, outdated = false }
				log('W', 'freeRoamMP', 'Main prefab found!')
			end
			if not FS:fileExists(deco) then
				deco = prefabData.pPath .. '/deco.prefab'
				if FS:fileExists(deco) then
					prefabsTable[prefabData.pName .. "deco"] = { path = deco, outdated = true }
					log('W', 'freeRoamMP', 'Outdated deco prefab found!')
				else
					deco = nil
				end
			else
				prefabsTable[prefabData.pName .. "deco"] = { path = deco, outdated = false }
				log('W', 'freeRoamMP', 'Deco prefab found!')
			end
			if not FS:fileExists(obstacles) then
				obstacles = prefabData.pPath .. '/obstacles.prefab'
				if FS:fileExists(obstacles) then
					prefabsTable[prefabData.pName .. "obstacles"] = { path = obstacles, outdated = true }
					log('W', 'freeRoamMP', 'Outdated obstacles prefab found!')
				else
					obstacles = nil
				end
			else
				prefabsTable[prefabData.pName .. "obstacles"] = { path = obstacles, outdated = false }
				log('W', 'freeRoamMP', 'Obstacles prefab found!')
			end
			if not FS:fileExists(obstacles2) then
				obstacles2 = prefabData.pPath .. '/obstacles2.prefab'
				if FS:fileExists(obstacles2) then
					prefabsTable[prefabData.pName .. "obstacles2"] = { path = obstacles2, outdated = true }
					log('W', 'freeRoamMP', 'Outdated obstacles2 prefab found!')
				else
					obstacles2 = nil
				end
			else
				prefabsTable[prefabData.pName .. "obstacles2"] = { path = obstacles2, outdated = false }
				log('W', 'freeRoamMP', 'Obstacles2 prefab found!')
			end
			if not FS:fileExists(obstaclesfromFile) then
				obstaclesfromFile = prefabData.pPath .. '/obstaclesfromFile.prefab'
				if FS:fileExists(obstaclesfromFile) then
					prefabsTable[prefabData.pName .. "obstaclesfromFile"] = { path = obstaclesfromFile, outdated = true }
					log('W', 'freeRoamMP', 'Outdated obstaclesfromFile prefab found!')
				else
					obstaclesfromFile = nil
				end
			else
				prefabsTable[prefabData.pName .. "obstacles2"] = { path = obstacles2, outdated = false }
				log('W', 'freeRoamMP', 'Obstacles2 prefab found!')
			end
			if not FS:fileExists(forward) then
				forward = prefabData.pPath .. '/forwardPrefab.prefab'
				if FS:fileExists(forward) and not userSettings.reverse then
					prefabsTable[prefabData.pName .. "forward"] = { path = forward, outdated = true }
					log('W', 'freeRoamMP', 'Outdated forward prefab found!')
				else
					forward = nil
				end
			elseif not userSettings.reverse then
				prefabsTable[prefabData.pName .. "forward"] = { path = forward, outdated = false }
				log('W', 'freeRoamMP', 'Forward prefab found!')
			end
			if not FS:fileExists(reverse) then
				reverse = prefabData.pPath .. '/reversePrefab.prefab'
				if FS:fileExists(reverse) and userSettings.reverse then
					prefabsTable[prefabData.pName .. "reverse"] = { path = reverse, outdated = true }
					log('W', 'freeRoamMP', 'Outdated reverse prefab found!')
				else
					reverse = nil
				end
			elseif userSettings.reverse then
				prefabsTable[prefabData.pName .. "reverse"] = { path = reverse, outdated = false }
				log('W', 'freeRoamMP', 'Reverse prefab found!')
			end
			if not FS:fileExists(arrive) then
				arrive = prefabData.pPath .. '/arrive.prefab'
				if FS:fileExists(arrive) then
					prefabsTable[prefabData.pName .. "arrive"] = { path = arrive, outdated = true }
					log('W', 'freeRoamMP', 'Outdated arrive prefab found!')
				else
					arrive = nil
				end
			else
				prefabsTable[prefabData.pName .. "arrive"] = { path = arrive, outdated = false }
				log('W', 'freeRoamMP', 'Arrive prefab found!')
			end
			if not FS:fileExists(ramp) then
				ramp = prefabData.pPath .. '/ramp.prefab'
				if FS:fileExists(ramp) then
					prefabsTable[prefabData.pName .. "ramp"] = { path = ramp, outdated = true }
					log('W', 'freeRoamMP', 'Outdated ramp prefab found!')
				else
					ramp = nil
				end
			else
				prefabsTable[prefabData.pName .. "ramp"] = { path = ramp, outdated = false }
				log('W', 'freeRoamMP', 'Ramp prefab found!')
			end
			if not FS:fileExists(p_drag_strip) then
				p_drag_strip = prefabData.pPath .. '/p_drag_strip.prefab'
				if FS:fileExists(p_drag_strip) then
					prefabsTable[prefabData.pName .. "p_drag_strip"] = { path = p_drag_strip, outdated = true }
					log('W', 'freeRoamMP', 'Outdated p_drag_strip prefab found!')
				else
					p_drag_strip = nil
				end
			else
				prefabsTable[prefabData.pName .. "p_drag_strip"] = { path = p_drag_strip, outdated = false }
				log('W', 'freeRoamMP', 'P_drag_strip prefab found!')
			end
			if not FS:fileExists(p_drag_strip_l) then
				p_drag_strip_l = prefabData.pPath .. '/p_drag_strip_l.prefab'
				if FS:fileExists(p_drag_strip_l) then
					prefabsTable[prefabData.pName .. "p_drag_strip_l"] = { path = p_drag_strip_l, outdated = true }
					log('W', 'freeRoamMP', 'Outdated p_drag_strip_l prefab found!')
				else
					p_drag_strip_l = nil
				end
			else
				prefabsTable[prefabData.pName .. "p_drag_strip_l"] = { path = p_drag_strip_l, outdated = false }
				log('W', 'freeRoamMP', 'P_drag_strip_l prefab found!')
			end
			if not FS:fileExists(p_drag_strip_r) then
				p_drag_strip_r = prefabData.pPath .. '/p_drag_strip_r.prefab'
				if FS:fileExists(p_drag_strip_r) then
					prefabsTable[prefabData.pName .. "p_drag_strip_r"] = { path = p_drag_strip_r, outdated = true }
					log('W', 'freeRoamMP', 'Outdated p_drag_strip_r prefab found!')
				else
					p_drag_strip_r = nil
				end
			else
				prefabsTable[prefabData.pName .. "p_drag_strip_r"] = { path = p_drag_strip_r, outdated = false }
				log('W', 'freeRoamMP', 'P_drag_strip_r prefab found!')
			end
			if not FS:fileExists(prefab) then
				prefab = prefabData.pPath .. '/prefab.prefab'
				if FS:fileExists(prefab) then
					prefabsTable[prefabData.pName .. "prefab"] = { path = prefab, outdated = true }
					log('W', 'freeRoamMP', 'Outdated prefab found!')
				else
					prefab = nil
				end
			else
				prefabsTable[prefabData.pName .. "prefab"] = { path = prefab, outdated = false }
				log('W', 'freeRoamMP', 'Prefab found!')
			end
			if not FS:fileExists(screenFencesPrefab) then
				screenFencesPrefab = prefabData.pPath .. '/screenFencesPrefab.prefab'
				if FS:fileExists(screenFencesPrefab) then
					prefabsTable[prefabData.pName .. "screenFencesPrefab"] = { path = screenFencesPrefab, outdated = true }
					log('W', 'freeRoamMP', 'Outdated screenFencesPrefab found!')
				else
					screenFencesPrefab = nil
				end
			else
				prefabsTable[prefabData.pName .. "screenFencesPrefab"] = { path = screenFencesPrefab, outdated = false }
				log('W', 'freeRoamMP', 'ScreenFencesPrefab found!')
			end
			if not FS:fileExists(road) then
				road = prefabData.pPath .. '/road.prefab'
				if FS:fileExists(road) then
					prefabsTable[prefabData.pName .. "road"] = { path = road, outdated = true }
					log('W', 'freeRoamMP', 'Outdated road prefab found!')
				else
					road = nil
				end
			else
				prefabsTable[prefabData.pName .. "road"] = { path = road, outdated = false }
				log('W', 'freeRoamMP', 'Road prefab found!')
			end
			if not FS:fileExists(vehicles) then
				vehicles = prefabData.pPath .. '/vehicles.prefab'
				if FS:fileExists(vehicles) then
					prefabsTable[prefabData.pName .. "vehicles"] = { path = vehicles, outdated = true }
					log('W', 'freeRoamMP', 'Outdated vehicles prefab found!')
				else
					vehicles = nil
				end
			else
				prefabsTable[prefabData.pName .. "vehicles"] = { path = vehicles, outdated = false }
				log('W', 'freeRoamMP', 'Vehicles prefab found!')
			end
		elseif prefabData.pLoad == false then
			removePrefab(prefabData.pName)
			if scenetree.findObject(prefabData.pName .. "main") then
				removePrefab(prefabData.pName .. "main")
			end
			if scenetree.findObject(prefabData.pName .. "deco") then
				removePrefab(prefabData.pName .. "deco")
			end
			if scenetree.findObject(prefabData.pName .. "obstacles") then
				removePrefab(prefabData.pName .. "obstacles")
			end
			if scenetree.findObject(prefabData.pName .. "obstacles2") then
				removePrefab(prefabData.pName .. "obstacles2")
			end
			if scenetree.findObject(prefabData.pName .. "obstaclesfromFile") then
				removePrefab(prefabData.pName .. "obstaclesfromFile")
			end
			if scenetree.findObject(prefabData.pName .. "forward") then
				removePrefab(prefabData.pName .. "forward")
			end
			if scenetree.findObject(prefabData.pName .. "reverse") then
				removePrefab(prefabData.pName .. "reverse")
			end
			if scenetree.findObject(prefabData.pName .. "arrive") then
				removePrefab(prefabData.pName .. "arrive")
			end
			if scenetree.findObject(prefabData.pName .. "ramp") then
				removePrefab(prefabData.pName .. "ramp")
			end
			if scenetree.findObject(prefabData.pName .. "p_drag_strip") then
				removePrefab(prefabData.pName .. "p_drag_strip")
			end
			if scenetree.findObject(prefabData.pName .. "p_drag_strip_l") then
				removePrefab(prefabData.pName .. "p_drag_strip_l")
			end
			if scenetree.findObject(prefabData.pName .. "p_drag_strip_r") then
				removePrefab(prefabData.pName .. "p_drag_strip_r")
			end
			if scenetree.findObject(prefabData.pName .. "prefab") then
				removePrefab(prefabData.pName .. "prefab")
			end
			if scenetree.findObject(prefabData.pName .. "screenFencesPrefab") then
				removePrefab(prefabData.pName .. "screenFencesPrefab")
			end
			if scenetree.findObject(prefabData.pName .. "road") then
				removePrefab(prefabData.pName .. "road")
			end
			if scenetree.findObject(prefabData.pName .. "vehicles") then
				removePrefab(prefabData.pName .. "vehicles")
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
	log('W', 'freeRoamMP', 'freeRoamMP LOADED!')
end

local function onExtensionUnloaded()
	log('W', 'freeRoamMP', 'freeRoamMP UNLOADED!')
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
