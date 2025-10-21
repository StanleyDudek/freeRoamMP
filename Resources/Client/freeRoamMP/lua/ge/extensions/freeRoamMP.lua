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

local multiplayerchat = {
	appName = "multiplayerchat",
	placement = {
		width = "550px",
		bottom = "0px",
		height = "170px",
		left = "180px"
	}
}

local multiplayersession = {
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
}

local multiplayerplayerlist = {
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
	if hiddens[veh.JBeam] then
		if not MPVehicleGE.isOwn(newGameVehicleID) then
			be:enterNextVehicle(0, 1)
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

--Prefabs
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
		sepB = originalContent:find("%]}\n", sepA)
		if not sepB then
			sepC = originalContent:find("}\n", sepA)
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
				tempStringB = tempStringB .. tempStringA .. "\n"
			end
		end
		if not sepA then
			break
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
					multiplayerchat = app
				end
				if app.appName == "multiplayersession" then
					multiplayersession = app
				end
				if app.appName == "multiplayerplayerlist" then
					multiplayerplayerlist = app
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
					table.insert(currentLayout.apps, multiplayerchat)
					stateToUpdate = true
				end
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayersession" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayersession)
					stateToUpdate = true
				end
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayerplayerlist" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayerplayerlist)
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
					multiplayerchat = app
				end
				if app.appName == "multiplayersession" then
					multiplayersession = app
				end
				if app.appName == "multiplayerplayerlist" then
					multiplayerplayerlist = app
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
					table.insert(currentLayout.apps, multiplayerchat)
					stateToUpdate = true
				end
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayersession" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayersession)
					stateToUpdate = true
				end
				for _, app in pairs(currentLayout.apps) do
					if app.appName == "multiplayerplayerlist" then
						found = true
					end
				end
				if not found then
					table.insert(currentLayout.apps, multiplayerplayerlist)
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
