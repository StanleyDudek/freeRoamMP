--freeRoamMP (CLIENT) by Dudekahedron, 2025

local M = {}

local originalSimplifiedTrafficValue = true

local freeRoam = false
local syncRequested = false

local prefabsTable = {}

local iterT = {}
local iterC = 0

local hiddens = {
	anticut = "anticut",
	ball = "ball",
	barrels = "barrels",
	barrier = "barrier",
	barrier_plastic = "barrier_plastic",
	blockwall = "blockwall",
	bollard = "bollard",
	boxutility = "boxutility",
	boxutility_large = "boxutility_large",
	cannon = "cannon",
	caravan = "caravan",
	cardboard_box = "cardboard_box",
	cargotrailer = "cargotrailer",
	chair = "chair",
	christmas_tree = "christmas_tree",
	cones = "cones",
	containerTrailer = "containerTrailer",
	couch = "couch",
	crowdbarrier = "crowdbarrier",
	delineator = "delineator",
	dolly = "dolly",
	dryvan = "dryvan",
	engine_props = "engine_props",
	flail = "flail",
	flatbed = "flatbed",
	flipramp = "flipramp",
	frameless_dump = "frameless_dump",
	fridge = "fridge",
	gate = "gate",
	haybale = "haybale",
	inflated_mat = "inflated_mat",
	kickplate = "kickplate",
	large_angletester = "large_angletester",
	large_bridge = "large_bridge",
	large_cannon = "large_cannon",
	large_crusher = "large_crusher",
	large_hamster_wheel = "large_hamster_wheel",
	large_roller = "large_roller",
	large_spinner = "large_spinner",
	large_tilt = "large_tilt",
	large_tire = "large_tire",
	log_trailer = "log_trailer",
	logs = "logs",
	mattress = "mattress",
	metal_box = "metal_box",
	metal_ramp = "metal_ramp",
	piano = "piano",
	porta_potty = "porta_potty",
	pressure_ball = "pressure_ball",
	rallyflags = "rallyflags",
	rallysigns = "rallysigns",
	rallytape = "rallytape",
	roadsigns = "roadsigns",
	rocks = "rocks",
	rollover = "rollover",
	roof_crush_tester = "roof_crush_tester",
	sawhorse = "sawhorse",
	shipping_container = "shipping_container",
	simple_traffic = "simple_traffic",
	spikestrip = "spikestrip",
	steel_coil = "steel_coil",
	streetlight = "streetlight",
	suspensionbridge = "suspensionbridge",
	tanker = "tanker",
	testroller = "testroller",
	tiltdeck = "tiltdeck",
	tirestacks = "tirestacks",
	tirewall = "tirewall",
	trafficbarrel = "trafficbarrel",
	trampoline = "trampoline",
	trashbin = "trashbin",
	tsfb = "tsfb",
	tub = "tub",
	tube = "tube",
	tv = "tv",
	wall = "wall",
	weightpad = "weightpad",
	woodcrate = "woodcrate",
	woodplanks = "woodplanks",
}



local function handlePrefabsA(path, name)
	local line_count = 0
	local count = io.open(path, "r")
	if count == nil then
		return
	end
	for line in count:lines() do
		line_count = line_count + 1
	end
	count:close()
	local file = io.open(path, "r")
	if file == nil then
		return
	end
	local originalContent = file:read("*all")
	file:close()
	local tempStringB = ""
	local sepA = 1
	local sepB = 1
	local sepC = 1
	for i = 1, line_count do
		sepB = originalContent:find("%]}", sepA)
		if not sepB then
			sepC = originalContent:find("}", sepA)
			if sepC then
				local tempStringA = originalContent:sub(sepA, sepC)
				sepA = originalContent:find("{", sepC)
				local matchA = string.find(tempStringA, "BeamNGVehicle", 1)
				if not matchA then
					tempStringB = tempStringB .. tempStringA .. "\n"
				end
			end
		else
			local tempStringA = originalContent:sub(sepA, sepB + 1)
			sepA = originalContent:find("{", sepB)
			local matchA = string.find(tempStringA, "BeamNGVehicle", 1)
			if not matchA then
				tempStringB = tempStringB .. tempStringA
			end
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

local function rxFreeRoamVehSync(data)
	if data ~= "null" then
		local vehicleStates = jsonDecode(data)
		local vehicles = MPVehicleGE.getVehicles()
		for serverVehicleID, state in pairs(vehicleStates) do
			if vehicles[serverVehicleID] then
				local gameVehicleID = vehicles[serverVehicleID].gameVehicleID
				if gameVehicleID ~= -1 then
					if not MPVehicleGE.isOwn(gameVehicleID) then
						if not state.active then
							be:getObjectByID(gameVehicleID):setActive(0)
							vehicles[serverVehicleID].hideNametag = true
						else
							be:getObjectByID(gameVehicleID):setActive(1)
							if hiddens[vehicles[serverVehicleID].jbeam] then
								vehicles[serverVehicleID].hideNametag = true
							else
								vehicles[serverVehicleID].hideNametag = false
							end
						end
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
		local arrive
		local closedGates
		local deco
		local forward
		local main
		local obstacles
		local obstacles2
		local obstaclesfromFile
		local openGates
		local parkingLotClutter
		local prefab
		local ramp
		local reverse
		local road
		local targets
		local vehicles
		if prefabData.pLoad == true then
			if prefabData.pPath then
				arrive = prefabData.pPath .. '/arrive.prefab.json'
				closedGates = prefabData.pPath .. '/closedGates.prefab.json'
				deco = prefabData.pPath .. '/deco.prefab.json'
				forward = prefabData.pPath .. '/forwardPrefab.prefab.json'
				main = prefabData.pPath .. '/mainPrefab.prefab.json'
				obstacles = prefabData.pPath .. '/obstacles.prefab.json'
				obstacles2 = prefabData.pPath .. '/obstacles2.prefab.json'
				obstaclesfromFile = prefabData.pPath .. '/obstacles-fromFile.prefab.json'
				openGates = prefabData.pPath .. '/openGates.prefab.json'
				parkingLotClutter = prefabData.pPath .. '/parkingLotClutter.prefab.json'
				prefab = prefabData.pPath .. '/prefab.prefab.json'
				ramp = prefabData.pPath .. '/ramp.prefab.json'
				reverse = prefabData.pPath .. '/reversePrefab.prefab.json'
				road = prefabData.pPath .. '/road.prefab.json'
				targets = prefabData.pPath .. '/targets.prefab.json'
				vehicles = prefabData.pPath .. '/vehicles.prefab.json'
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
			if not FS:fileExists(closedGates) then
				closedGates = prefabData.pPath .. '/closedGates.prefab'
				if FS:fileExists(closedGates) then
					prefabsTable[prefabData.pName .. "closedGates"] = { path = closedGates, outdated = true }
					log('W', 'freeRoamMP', 'Outdated closedGates prefab found!')
				else
					closedGates = nil
				end
			else
				prefabsTable[prefabData.pName .. "closedGates"] = { path = closedGates, outdated = false }
				log('W', 'freeRoamMP', 'closedGates prefab found!')
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
			if not FS:fileExists(openGates) then
				openGates = prefabData.pPath .. '/openGates.prefab'
				if FS:fileExists(openGates) then
					prefabsTable[prefabData.pName .. "openGates"] = { path = openGates, outdated = true }
					log('W', 'freeRoamMP', 'Outdated openGates prefab found!')
				else
					openGates = nil
				end
			else
				prefabsTable[prefabData.pName .. "openGates"] = { path = openGates, outdated = false }
				log('W', 'freeRoamMP', 'openGates prefab found!')
			end
			if not FS:fileExists(parkingLotClutter) then
				parkingLotClutter = prefabData.pPath .. '/parkingLotClutter.prefab'
				if FS:fileExists(parkingLotClutter) then
					prefabsTable[prefabData.pName .. "parkingLotClutter"] = { path = parkingLotClutter, outdated = true }
					log('W', 'freeRoamMP', 'Outdated parkingLotClutter prefab found!')
				else
					parkingLotClutter = nil
				end
			else
				prefabsTable[prefabData.pName .. "parkingLotClutter"] = { path = parkingLotClutter, outdated = false }
				log('W', 'freeRoamMP', 'parkingLotClutter prefab found!')
			end
			if not FS:fileExists(prefab) then
				prefab = prefabData.pPath .. '/prefab.prefab'
				if FS:fileExists(prefab) then
					prefabsTable[prefabData.pName .. "prefab"] = { path = prefab, outdated = true }
					log('W', 'freeRoamMP', 'Outdated prefab prefab found!')
				else
					prefab = nil
				end
			else
				prefabsTable[prefabData.pName .. "prefab"] = { path = prefab, outdated = false }
				log('W', 'freeRoamMP', 'Prefab prefab found!')
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
			if not FS:fileExists(targets) then
				targets = prefabData.pPath .. '/targets.prefab'
				if FS:fileExists(targets) then
					prefabsTable[prefabData.pName .. "targets"] = { path = targets, outdated = true }
					log('W', 'freeRoamMP', 'Outdated targets prefab found!')
				else
					targets = nil
				end
			else
				prefabsTable[prefabData.pName .. "targets"] = { path = targets, outdated = false }
				log('W', 'freeRoamMP', 'targets prefab found!')
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
			if scenetree.findObject(prefabData.pName .. "arrive") then
				removePrefab(prefabData.pName .. "arrive")
			end
			if scenetree.findObject(prefabData.pName .. "closedGates") then
				removePrefab(prefabData.pName .. "closedGates")
			end
			if scenetree.findObject(prefabData.pName .. "deco") then
				removePrefab(prefabData.pName .. "deco")
			end
			if scenetree.findObject(prefabData.pName .. "forward") then
				removePrefab(prefabData.pName .. "forward")
			end
			if scenetree.findObject(prefabData.pName .. "main") then
				removePrefab(prefabData.pName .. "main")
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
			if scenetree.findObject(prefabData.pName .. "openGates") then
				removePrefab(prefabData.pName .. "openGates")
			end
			if scenetree.findObject(prefabData.pName .. "parkingLotClutter") then
				removePrefab(prefabData.pName .. "parkingLotClutter")
			end
			if scenetree.findObject(prefabData.pName .. "prefab") then
				removePrefab(prefabData.pName .. "prefab")
			end
			if scenetree.findObject(prefabData.pName .. "ramp") then
				removePrefab(prefabData.pName .. "ramp")
			end
			if scenetree.findObject(prefabData.pName .. "reverse") then
				removePrefab(prefabData.pName .. "reverse")
			end
			if scenetree.findObject(prefabData.pName .. "road") then
				removePrefab(prefabData.pName .. "road")
			end
			if scenetree.findObject(prefabData.pName .. "targets") then
				removePrefab(prefabData.pName .. "targets")
			end
			if scenetree.findObject(prefabData.pName .. "vehicles") then
				removePrefab(prefabData.pName .. "vehicles")
			end
			be:reloadCollision()
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

local function onVehicleActiveChanged(gameVehicleID, active)
	if gameVehicleID then
		if MPVehicleGE.isOwn(gameVehicleID) then
			local serverVehicleID = MPVehicleGE.getServerVehicleID(gameVehicleID)
			if serverVehicleID then
				local data = {}
				data.active = active
				data.serverVehicleID = serverVehicleID
				TriggerServerEvent("freeRoamVehicleActiveHandler", jsonEncode(data))
			end
		else
			local serverVehicleID = MPVehicleGE.getServerVehicleID(gameVehicleID)
			if serverVehicleID then
				TriggerServerEvent("freeRoamVehSyncRequested", "")
			end
		end
	end
end

local function onVehicleSpawned(gameVehicleID)
	if gameVehicleID then
		if not MPVehicleGE.isOwn(gameVehicleID) then
			TriggerServerEvent("freeRoamVehSyncRequested", "")
		end
		local veh = be:getObjectByID(gameVehicleID)
		if veh then
			veh:setField('renderDistance', '', 6969)
			veh:queueLuaCommand('freeRoamMP.onVehicleReady()')
		end
	end
end

local function onVehicleReady(gameVehicleID)
	local serverVehicleID = MPVehicleGE.getServerVehicleID(gameVehicleID)
	if serverVehicleID then
		if not MPVehicleGE.isOwn(gameVehicleID) then
			local vehicles = MPVehicleGE.getVehicles()
			local veh = be:getObjectByID(gameVehicleID)
			if hiddens[veh.JBeam] then
				vehicles[serverVehicleID].hideNametag = true
			else
				vehicles[serverVehicleID].hideNametag = false
			end
		end
	end
end

local function onExtensionLoaded()
	if not settings.getValue("trafficSimpleVehicles") then
		originalSimplifiedTrafficValue = false
		settings.setValue("trafficSimpleVehicles", true)
	end
	AddEventHandler("rxPrefabSync", rxPrefabSync)
	AddEventHandler("rxFreeRoamVehSync", rxFreeRoamVehSync)
	log('W', 'freeRoamMP', 'freeRoamMP LOADED!')
end

local function onExtensionUnloaded()
	if originalSimplifiedTrafficValue == false then
		settings.setValue("trafficSimpleVehicles", originalSimplifiedTrafficValue)
	end
	log('W', 'freeRoamMP', 'freeRoamMP UNLOADED!')
end

M.onUpdate = onUpdate

M.onAnyMissionChanged = onAnyMissionChanged
M.onMissionStartWithFade = onMissionStartWithFade

M.onVehicleActiveChanged = onVehicleActiveChanged
M.onVehicleSpawned = onVehicleSpawned
M.onVehicleReady = onVehicleReady

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

M.onInit = function() setExtensionUnloadMode(M, 'manual') end

return M
