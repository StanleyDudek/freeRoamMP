--freeRoamMP (CLIENT) by Dudekahedron, 2025

local M = {}

--Setup
local freeRoam = false
local syncRequested = false

local prefabsTable = {}

local iterT = {}
local iterC = 0

--Paths
local defaultAppLayoutDirectory = "settings/ui_apps/originalLayouts/default/"
local missionAppLayoutDirectory = "settings/ui_apps/originalLayouts/mission/"
local userDefaultAppLayoutDirectory = "settings/ui_apps/layouts/default/"
local userMissionAppLayoutDirectory = "settings/ui_apps/layouts/mission/"

--Default Settings Values
local userTrafficSettings = {}
local freeRoamMPTrafficSettings = {
	trafficAmount = 3,
	trafficExtraAmount = 3,
	trafficExtraVehicles = false,
	trafficParkedAmount = 0,
	trafficParkedVehicles = false,
	trafficLoadForFreeroam = false,
	trafficSmartSelections = false,
	trafficSimpleVehicles = true,
	trafficAllowMods = true,
	trafficEnableSwitching = false,
	trafficMinimap = true
}

local userGameplaySettings = {}
local freeRoamMPGameplaySettings = {
	simplifyRemoteVehicles = false
}

--UI Layouts
local stateToUpdate

local defaultLayouts = {
	freeroam = "freeroam",
	garage = "garage",
	garage_v2 = "garage_v2",
	menu = "menu",
	multiseatscenario = "multiseatscenario",
	noncompeteScenario = "noncompeteScenario",
	offroadScenario = "offroadScenario",
	proceduralScenario = "proceduralScenario",
	quickraceScenario = "quickraceScenario",
	radial = "radial",
	scenario = "scenario",
	scenario_cinematic_start = "scenario_cinematic_start",
	singleCheckpointScenario = "singleCheckpointScenario",
	tasklist = "tasklist",
	tasklistTall = "tasklistTall",
	unicycle = "unicycle",
	busRouteScenario = "busRouteScenario",
	busStuntMinSpeed = "busStuntMinSpeed",
	career = "career",
	careerBigMap = "careerBigMap",
	careerMission = "careerMission",
	careerMissionEnd = "careerMissionEnd",
	careerPause = "careerPause",
	careerRefuel = "careerRefuel",
	collectionEvent = "collectionEvent",
	crawl = "crawl",
	damageScenario = "damageScenario",
	dderbyScenario = "dderbyScenario",
	discover = "discover",
	driftScenario = "driftScenario",
	exploration = "exploration",
	externalUI = "externalUI"
}

local missionLayouts = {
	driftMission = "driftMission",
	driftNavigationMission = "driftNavigationMission",
	evadeMission = "evadeMission",
	garageToGarage = "garageToGarage",
	rallyModeRecce = "rallyModeRecce",
	rallyModeStage = "rallyModeStage",
	scenarioMission = "scenarioMission",
	timeTrialMission = "timeTrialMission",
	aRunForLife = "aRunForLife",
	basicMission = "basicMission",
	crashTestMission = "crashTestMission",
	crawlMission = "crawlMission",
	dragMission = "dragMission"
}

local multiplayerApps = {
	multiplayerchat = {
		appName = "multiplayerchat",
		placement = {
			width = "550px",
			bottom = "0px",
			height = "170px",
			left = "180px"
		}
	},
	multiplayersession = {
		appName = "multiplayersession",
		placement = {
			bottom = "",
			height = "40px",
			left = 0,
			margin = "auto",
			position = "absolute",
			right = 0,
			top = "0px",
			width = "700px"
		}
	},
	multiplayerplayerlist = {
		appName = "multiplayerplayerlist",
		placement = {
			bottom = "",
			height = "560px",
			left = "",
			position = "absolute",
			right = "0px",
			top = "30px",
			width = "300px"
		}
	}
}

--Hidden Nametags by Vehicle Model
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

--Drag Race Displays
local dragData

local driverLightBlinkState = {
	lane = nil,
	isBlinking = false,
	timer = 0,
	frequency = 1/6,
	isOn = false
}

local function findLightObject(name, prefabId)
	if prefabId then
		local prefabInstance = scenetree.findObjectById(prefabId)
		if prefabInstance then
			local obj = prefabInstance:findObject(name)
			if obj then
				return obj
			end
		end
	end
	return scenetree.findObject(name)
end

local function createTreeLights(lane, prefabId)
	return {
		stageLights = {
			prestageLight  = {obj = findLightObject("Prestagelight_" .. lane, prefabId),       anim = "prestage", isOn = false},
			stageLight     = {obj = findLightObject("Stagelight_" .. lane, prefabId),          anim = "prestage", isOn = false},
			winnerLight    = {obj = findLightObject("WinLight_Timeboard_" .. lane, prefabId),  anim = "prestage", isOn = false},
			driverLight    = {obj = findLightObject("WinLight_Driver_" .. lane, prefabId),     anim = "prestage", isOn = false},
		},
		countDownLights = {
			amberLight1    = {obj = findLightObject("Amberlight1_" .. lane, prefabId), anim = "tree", isOn = false},
			amberLight2    = {obj = findLightObject("Amberlight2_" .. lane, prefabId), anim = "tree", isOn = false},
			amberLight3    = {obj = findLightObject("Amberlight3_" .. lane, prefabId), anim = "tree", isOn = false},
			greenLight     = {obj = findLightObject("Greenlight_" .. lane, prefabId),  anim = "tree", isOn = false},
			redLight       = {obj = findLightObject("Redlight_" .. lane, prefabId),    anim = "tree", isOn = false},
		},
		globalLights = {
			blueLight = {obj = findLightObject("BlueLight", prefabId), anim = "prestage", isOn = false},
		},
		timers = {
			dialOffset = 0,
			laneTimer = 0,
			laneTimerFlag = false
		}
	}
end

local function initTree()
	local prefabId = nil
	if dragData and dragData.prefabs and dragData.prefabs.christmasTree then
		prefabId = dragData.prefabs.christmasTree.prefabId
	end

	local treeLights = {}
	for laneIndex = 1, #dragData.strip.lanes do
		treeLights[laneIndex] = createTreeLights(laneIndex, prefabId)
	end
	return treeLights
end

local function updateTreeLightsUI(vehId, changes)
	if not changes then
		return
	end
	if not vehId then
		guihooks.trigger("updateTreeLightApp", changes)
	end
end

local function initDisplay()
	local displayDigits = {
		timeDigits = {},
		speedDigits = {}
	}
	local time = {}
	local speed = {}
	for i=1, 5 do
		local timeDigit = scenetree.findObject("display_time_" .. i .. "_r")
		table.insert(time, timeDigit)

		local speedDigit = scenetree.findObject("display_speed_" .. i .. "_r")
		table.insert(speed, speedDigit)
	end
	table.insert(displayDigits.timeDigits, time)
	table.insert(displayDigits.speedDigits, speed)

	time = {}
	speed = {}

	for i=1, 5 do
		local timeDigit = scenetree.findObject("display_time_" .. i .. "_l")
		table.insert(time, timeDigit)

		local speedDigit = scenetree.findObject("display_speed_" .. i .. "_l")
		table.insert(speed, speedDigit)
	end
	table.insert(displayDigits.timeDigits, time)
	table.insert(displayDigits.speedDigits, speed)

	if not displayDigits then
		return
	end
	return displayDigits
end

local function clearLights()
	if not dragData then
		return
	end
	for _, laneTree in ipairs(dragData.strip.treeLights) do
		for _,group in pairs(laneTree) do
			if type(group) == "table" then
				for _,light in pairs(group) do
					if type(light) == "table" and light.obj then
						light.obj:setHidden(true)
						light.isOn = false
					end
				end
			end
		end
		laneTree.timers.laneTimer = 0
		laneTree.timers.laneTimerFlag = false
		laneTree.timers.dialOffset = 0
	end
	updateTreeLightsUI(nil, {
		stageLights = {
			prestageLight = false,
			stageLight = false
		},
		countDownLights = {
			amberLight1 = false,
			amberLight2 = false,
			amberLight3 = false,
			greenLight = false,
			redLight = false
		},
		globalLights = {
			blueLight = false
		}
	})
	driverLightBlinkState = {
		lane = nil,
		isBlinking = false,
		timer = 0,
		frequency = 1/6,
		isOn = false
	}
end

local function clearDisplay()
	if not dragData then
		return
	end
	for _, digitTypeData in pairs(dragData.strip.displayDigits) do
		for _,laneTypeData in ipairs(digitTypeData) do
			for _,digit in ipairs(laneTypeData) do
				digit:setHidden(true)
			end
		end
	end
end

local function rxUpdateDisplay(data)
	local decodedData = jsonDecode(data)
	if gameplay_drag_general then
		if not dragData then
			gameplay_drag_general.setDragRaceData(decodedData.dragData)
			dragData = gameplay_drag_general.getData()
		end
	end
	if dragData then
		dragData.strip.displayDigits = initDisplay()
		dragData.strip.treeLights = initTree()
		guihooks.trigger('updateTreeLightStaging', true)
	end
	local timeDisplayValue = decodedData.timeDisplayValue
	local speedDisplayValue = decodedData.speedDisplayValue
	local timeDigits
	local speedDigits
	local lane = decodedData.lane
	timeDigits = dragData.strip.displayDigits.timeDigits[lane]
	speedDigits = dragData.strip.displayDigits.speedDigits[lane]
	if #timeDisplayValue > 0 and #timeDisplayValue < 6 then
		for i,v in ipairs(timeDisplayValue) do
			timeDigits[i]:preApply()
			timeDigits[i]:setField('shapeName', 0, "art/shapes/quarter_mile_display/display_".. v ..".dae")
			timeDigits[i]:setHidden(false)
			timeDigits[i]:postApply()
		end
	end
	for i,v in ipairs(speedDisplayValue) do
		if speedDigits and speedDigits[i] then
			speedDigits[i]:preApply()
			speedDigits[i]:setField('shapeName', 0, "art/shapes/quarter_mile_display/display_".. v ..".dae")
			speedDigits[i]:setHidden(false)
			speedDigits[i]:postApply()
		end
	end
end

local function rxUpdateWinnerLight(data)
	local decodedData = jsonDecode(data)
	if gameplay_drag_general then
		if not dragData then
			gameplay_drag_general.setDragRaceData(decodedData.dragData)
			dragData = gameplay_drag_general.getData()
		end
	end
	driverLightBlinkState = decodedData.driverLightBlinkState
	local lane = driverLightBlinkState.lane
	local prefabId = dragData.prefabs.christmasTree.prefabId
	dragData.strip.treeLights[lane].stageLights.winnerLight.obj = findLightObject("WinLight_Timeboard_" .. lane, prefabId)
	dragData.strip.treeLights[lane].stageLights.driverLight.obj = findLightObject("WinLight_Driver_" .. lane, prefabId)
	if lane then
		if dragData.strip.treeLights[lane].stageLights.winnerLight and dragData.strip.treeLights[lane].stageLights.winnerLight.obj then
			dragData.strip.treeLights[lane].stageLights.winnerLight.isOn = true
			dragData.strip.treeLights[lane].stageLights.winnerLight.obj:setHidden(false)
		end
		if dragData.strip.treeLights[lane].stageLights.driverLight and dragData.strip.treeLights[lane].stageLights.driverLight.obj and not driverLightBlinkState.isBlinking then
			dragData.strip.treeLights[lane].stageLights.driverLight.isOn = true
			driverLightBlinkState.lane = lane
			driverLightBlinkState.isBlinking = true
			driverLightBlinkState.timer = 0
		end
	end
end

local function rxClearAll()
	if not dragData then
		dragData = gameplay_drag_general.getData()
		return
	end
	local prefabId = dragData.prefabs.christmasTree.prefabId
	for i = 1, 2 do
		local winnerLightObj = findLightObject("WinLight_Timeboard_" .. i, prefabId)
		local driverLightObj = findLightObject("WinLight_Driver_" .. i, prefabId)
		winnerLightObj:setHidden(true)
		driverLightObj:setHidden(true)
	end
	clearLights()
  	clearDisplay()
	gameplay_drag_general.unloadRace()
end

--Vehicles
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

local function onVehicleSwitched(oldGameVehicleID, newGameVehicleID)
	local veh = be:getObjectByID(newGameVehicleID)
	if veh then
		if hiddens[veh.JBeam] then
			if not MPVehicleGE.isOwn(newGameVehicleID) then
				be:enterNextVehicle(0, 1)
			end
		end
	end
end

--Traffic
local function getUserGameplaySettings()
	userGameplaySettings.simplifyRemoteVehicles = settings.getValue("simplifyRemoteVehicles")
end

local function setGameplaySettings(gameplaySettings)
	for setting, value in pairs(gameplaySettings) do
		settings.setValue(setting, value)
	end
end

local function getUserTrafficSettings()
	userTrafficSettings.trafficAmount = settings.getValue('trafficAmount')
	userTrafficSettings.trafficExtraAmount = settings.getValue('trafficExtraAmount')
	userTrafficSettings.trafficExtraVehicles = settings.getValue('trafficExtraVehicles')
	userTrafficSettings.trafficParkedAmount = settings.getValue('trafficParkedAmount')
	userTrafficSettings.trafficParkedVehicles = settings.getValue('trafficParkedVehicles')
	userTrafficSettings.trafficLoadForFreeroam = settings.getValue('trafficLoadForFreeroam')
	userTrafficSettings.trafficSmartSelections = settings.getValue('trafficSmartSelections')
	userTrafficSettings.trafficSimpleVehicles = settings.getValue('trafficSimpleVehicles')
	userTrafficSettings.trafficAllowMods = settings.getValue('trafficAllowMods')
	userTrafficSettings.trafficEnableSwitching = settings.getValue('trafficEnableSwitching')
	userTrafficSettings.trafficMinimap = settings.getValue('trafficMinimap')
end

local function setTrafficSettings(trafficSettings)
	for setting, value in pairs(trafficSettings) do
		settings.setValue(setting, value)
	end
end

local function onSpeedTrapTriggered(speedTrapData, playerSpeed, overSpeed)
    if MPVehicleGE.isOwn(speedTrapData.subjectID) then
        local veh = be:getObjectByID(speedTrapData.subjectID)
        local highscore, leaderboard = gameplay_speedTrapLeaderboards.addRecord(speedTrapData, playerSpeed, overSpeed, veh)
        speedTrapData.licensePlate = veh:getDynDataFieldbyName("licenseText", 0) or "Illegible"
        speedTrapData.vehicleModel = core_vehicles.getModel(veh.JBeam).model.Name
        speedTrapData.playerSpeed = playerSpeed
        speedTrapData.overSpeed = overSpeed
        speedTrapData.highscore = highscore
        speedTrapData.leaderboard = leaderboard
        TriggerServerEvent("speedTrap", jsonEncode( speedTrapData ) )
    end
end

local function onRedLightCamTriggered(redLightData, playerSpeed)
    if MPVehicleGE.isOwn(redLightData.subjectID) then
        local veh = be:getObjectByID(redLightData.subjectID)
        redLightData.licensePlate = veh:getDynDataFieldbyName("licenseText", 0) or "Illegible"
        redLightData.vehicleModel = core_vehicles.getModel(veh.JBeam).model.Name
        redLightData.playerSpeed = playerSpeed
        TriggerServerEvent("redLight", jsonEncode( redLightData ) )
    end
end

local function rxTrafficSignalTimer(data)
	core_trafficSignals.setTimer(tonumber(data))
	local vehicles = MPVehicleGE.getVehicles()
	local count = 0
	for serverVehicleID, vehicle in pairs(vehicles) do
		count = count + 1
	end
	count = count + freeRoamMPTrafficSettings.trafficExtraAmount
	settings.setValue("trafficAmount", count)
end

--Prefabs
local prefabNames = {
	"arrive",
	"closedGates",
	"deco",
	"forwardPrefab",
	"mainPrefab",
	"obstacles",
	"obstacles2",
	"obstacles-fromFile",
	"openGates",
	"parkingLotClutter",
	"prefab",
	"ramp",
	"reversePrefab",
	"road",
	"targets",
	"vehicles"
}

local function addPrefabEntry(name, path, outdated, message)
	prefabsTable[name] = {
		path = path,
		outdated = outdated
	}
	log('W', 'freeRoamMP', message)
end

local function checkPrefab(prefabData, baseName, userSettings)
	local fullJson = string.format("%s/%s.prefab.json", prefabData.pPath, baseName)
	local fullLegacy = string.format("%s/%s.prefab", prefabData.pPath, baseName)
	local prefabKey = prefabData.pName .. baseName:gsub("Prefab", ""):gsub("%-", "")
	local outdated, exists = false, FS:fileExists(fullJson)
	if not exists then
		outdated = true
		exists = FS:fileExists(fullLegacy)
		if not exists then
			return
		end
	end
	if baseName == "forwardPrefab" and userSettings.reverse then
		return
	end
	if baseName == "reversePrefab" and not userSettings.reverse then
		return
	end
	addPrefabEntry(prefabKey, exists and (outdated and fullLegacy or fullJson), outdated, string.format("%s prefab found!%s", baseName:gsub("Prefab", ""), outdated and " (outdated)" or ""))
end

local function removeAllPrefabs(pName)
	for _, base in pairs(prefabNames) do
		local key = pName .. base:gsub("Prefab", ""):gsub("%-", "")
		if scenetree.findObject(key) then
			removePrefab(key)
		end
	end
	be:reloadCollision()
end

local function rxPrefabSync(data)
	if not data or data == "null" then
		return
	end
	local prefabData = jsonDecode(data)
	local userSettings = prefabData.pSettings
	if prefabData.pLoad then
		for _, base in ipairs(prefabNames) do
			checkPrefab(prefabData, base, userSettings)
		end
	else
		removePrefab(prefabData.pName)
		removeAllPrefabs(prefabData.pName)
	end
end

local function readPrefab(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*all")
	f:close()
	return content
end

local function writePrefab(path, content)
	local f = io.open(path, "w+")
	if not f then
		return
	end
	f:write(content)
	f:close()
end

local function cleanPrefab(content)
	local result = ""
	local inSep = 1
	for _ = 1, #content do
		local outSep = content:find("}\n", inSep)
		if not outSep then
			break
		end
		local block = content:sub(inSep, outSep)
		inSep = content:find("{", outSep)
		if not block:find("BeamNGVehicle", 1) then
			result = result .. block .. "\n"
		end
		if not inSep then
			break
		end
	end
	return result
end

local function cleanPrefabOutdated(content)
	local result = ""
	local inSep = 1
	for _ = 1, #content do
		local start = content:find("   new BeamNGVehicle%(", inSep)
		if not start then
			result = result .. content:sub(inSep)
			break
		end
		result = result .. content:sub(inSep, start - 1)
		local outSep = content:find("};", start)
		if not outSep then
			break
		end
		inSep = outSep + 2
		if inSep > #content then
			break
		end
	end
	return result
end

local function processPrefab(path, name, outdated)
	local content = readPrefab(path)
	if not content then
		return
	end
	local cleanedPrefab = not outdated and cleanPrefab(content) or cleanPrefabOutdated(content)
	if cleanedPrefab then
		local ext = not outdated and ".prefab.json" or ".prefab"
		local tempPath = "settings/BeamMP/tempPrefab" .. name .. ext
		writePrefab(tempPath, cleanedPrefab)
		spawnPrefab(name, tempPath, "0 0 0", "0 0 1", "1 1 1")
	end
end

local function onAnyMissionChanged(state, mission)
	if state == "stopped" then
		local prefab = {}
		prefab.pName = mission.missionType .. "-" .. tostring(iterT[mission.missionType])
		prefab.pLoad = false
		local data = jsonEncode(prefab)
		TriggerServerEvent("freeRoamPrefabSync", data)
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

--State and UI Apps
local function onGameStateUpdate(state)
	local originalMpLayout = jsonReadFile(userDefaultAppLayoutDirectory .. "multiplayer.uilayout.json")
	local currentMpLayout = deepcopy(originalMpLayout)
	if defaultLayouts[state.appLayout] then
		local found
		if currentMpLayout then
			for _, app in pairs(currentMpLayout.apps) do
				if app.appName == "multiplayerchat" then
					multiplayerApps.multiplayerchat = app
				end
				if app.appName == "multiplayersession" then
					multiplayerApps.multiplayersession = app
				end
				if app.appName == "multiplayerplayerlist" then
					multiplayerApps.multiplayerplayerlist = app
				end
			end
			local defaultLayout = jsonReadFile(defaultAppLayoutDirectory .. state.appLayout .. ".uilayout.json")
			local currentLayout = deepcopy(defaultLayout)
			if currentLayout then
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayerchat" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayerApps.multiplayerchat)
					stateToUpdate = true
				end
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayersession" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayerApps.multiplayersession)
					stateToUpdate = true
				end
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayerplayerlist" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayerApps.multiplayerplayerlist)
					stateToUpdate = true
				end
			end
			if stateToUpdate then
				jsonWriteFile(userDefaultAppLayoutDirectory .. state.appLayout .. ".uilayout.json", currentLayout, 1)
			end
		end
	elseif missionLayouts[state.appLayout] then
		local found
		if currentMpLayout then
			for _, app in pairs(currentMpLayout.apps) do
				if app.appName == "multiplayerchat" then
					multiplayerApps.multiplayerchat = app
				end
				if app.appName == "multiplayersession" then
					multiplayerApps.multiplayersession = app
				end
				if app.appName == "multiplayerplayerlist" then
					multiplayerApps.multiplayerplayerlist = app
				end
			end
			local missionLayout = jsonReadFile(missionAppLayoutDirectory .. state.appLayout .. ".uilayout.json")
			local currentLayout = deepcopy(missionLayout)
			if currentLayout then
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayerchat" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayerApps.multiplayerchat)
					stateToUpdate = true
				end
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayersession" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayerApps.multiplayersession)
					stateToUpdate = true
				end
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayerplayerlist" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayerApps.multiplayerplayerlist)
					stateToUpdate = true
				end
			end
			if stateToUpdate then
				jsonWriteFile(userMissionAppLayoutDirectory .. state.appLayout .. ".uilayout.json", currentLayout, 1)
			end
		end
	end
end

--Initial Syncs and Updates
local function onWorldReadyState(state)
	if state == 2 then
		if not freeRoam then
			core_gamestate.setGameState('freeroam', 'freeroam', 'freeroam')
			freeRoam = true
		end
		if not syncRequested then
			TriggerServerEvent("freeRoamSyncRequested", "")
			syncRequested = true
		end
	end
end

local function onUpdate(dtReal, dtSim, dtRaw)
	if worldReadyState == 2 then
		for name, data in pairs(prefabsTable) do
			processPrefab(data.path, name, data.outdated)
			prefabsTable[name] = nil
			be:reloadCollision()
			break
		end
		if stateToUpdate then
			ui_apps.requestUIAppsData()
			stateToUpdate = false
		end
	end
	if driverLightBlinkState.isBlinking then
		if dragData then
			local driverLight = dragData.strip.treeLights[driverLightBlinkState.lane].stageLights.driverLight
			driverLight.obj = findLightObject("WinLight_Driver_" .. driverLightBlinkState.lane, dragData.prefabs.christmasTree.prefabId)
			if driverLight and driverLight.obj then
				local newTimer = driverLightBlinkState.timer + dtSim
				if newTimer >= driverLightBlinkState.frequency then
					driverLightBlinkState.timer = newTimer % driverLightBlinkState.frequency
					driverLightBlinkState.isOn = not driverLightBlinkState.isOn
					driverLight.obj:setHidden(not driverLightBlinkState.isOn)
				else
					driverLightBlinkState.timer = newTimer
				end
			else
				driverLightBlinkState.isBlinking = false
				driverLightBlinkState.isOn = false
			end
		end
	end
end

--Loading / Unloading
local function onExtensionLoaded()
	getUserTrafficSettings()
	setTrafficSettings(freeRoamMPTrafficSettings)
	getUserGameplaySettings()
	setGameplaySettings(freeRoamMPGameplaySettings)
	AddEventHandler("rxUpdateDisplay", rxUpdateDisplay)
	AddEventHandler("rxUpdateWinnerLight", rxUpdateWinnerLight)
	AddEventHandler("rxClearAll", rxClearAll)
	AddEventHandler("rxPrefabSync", rxPrefabSync)
	AddEventHandler("rxFreeRoamVehSync", rxFreeRoamVehSync)
	AddEventHandler("rxTrafficSignalTimer", rxTrafficSignalTimer)
	log('W', 'freeRoamMP', 'freeRoamMP LOADED!')
end

local function onExtensionUnloaded()
	setTrafficSettings(userTrafficSettings)
	setGameplaySettings(userGameplaySettings)
	log('W', 'freeRoamMP', 'freeRoamMP UNLOADED!')
end

--Access
M.onVehicleActiveChanged = onVehicleActiveChanged
M.onVehicleSpawned = onVehicleSpawned
M.onVehicleReady = onVehicleReady
M.onVehicleSwitched = onVehicleSwitched

M.onSpeedTrapTriggered = onSpeedTrapTriggered
M.onRedLightCamTriggered = onRedLightCamTriggered
M.onAnyMissionChanged = onAnyMissionChanged
M.onMissionStartWithFade = onMissionStartWithFade
M.onGameStateUpdate = onGameStateUpdate

M.onWorldReadyState = onWorldReadyState
M.onUpdate = onUpdate

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

M.onInit = function() setExtensionUnloadMode(M, 'manual') end

return M
