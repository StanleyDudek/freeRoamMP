--freeRoamMP (SERVER) by Dudekahedron, 2025

local vehicleStates = {}
local loadedPrefabs = {}
local signalTimer = MP.CreateTimer()

local trapNames = {
    [1] = "Riverway Plaza",
    [2] = "Plaza North Bound",
    [3] = "Plaza South Bound",
    [4] = "Beach",
    [5] = "Lighthouse",
    [6] = "Island Port North Bound",
    [7] = "Island Port South Bound"
}

function onInit()
	MP.RegisterEvent("freeRoamPrefabSync","freeRoamPrefabSync")
	MP.RegisterEvent("freeRoamSyncRequested","freeRoamSyncRequested")
	MP.RegisterEvent("freeRoamVehSyncRequested","freeRoamVehSyncRequested")
	MP.RegisterEvent("freeRoamVehicleActiveHandler","freeRoamVehicleActiveHandler")

	MP.RegisterEvent("txUpdateDisplay", "txUpdateDisplay")
	MP.RegisterEvent("txClearAll", "txClearAll")

	MP.RegisterEvent("speedTrap", "speedTrap")
    MP.RegisterEvent("redLight", "redLight")
    MP.RegisterEvent("trafficLightTimer","trafficLightTimer")
	MP.CreateEventTimer("trafficLightTimer", 10000)

	MP.RegisterEvent("onPlayerJoin","onPlayerJoinHandler")
	MP.RegisterEvent("onVehicleSpawn","onVehicleSpawnHandler")
	MP.RegisterEvent("onVehicleEdited","onVehicleEditedHandler")
	MP.RegisterEvent("onVehicleDeleted","onVehicleDeletedHandler")
	MP.RegisterEvent("onPlayerDisconnect","onPlayerDisconnectHandler")

	print("[freeRoam] ---------- freeRoam Loaded!")
end

function txUpdateDisplay(player_id, data)
	for id in pairs(MP.GetPlayers()) do
		if player_id ~= id then
			MP.TriggerClientEvent(id, "rxUpdateDisplay", data)
		end
	end
end

function txClearAll(player_id)
	for id in pairs(MP.GetPlayers()) do
		if player_id ~= id then
			MP.TriggerClientEvent(id, "rxClearAll", "")
		end
	end
end

function speedTrap(player_id, data)
    local speedTrapData = Util.JsonDecode(data)
    local triggerName = speedTrapData.triggerName
    local triggerNumber = tonumber(string.match(triggerName, "%d+"))
    local triggerPlace = trapNames[triggerNumber] or "Unknown"
    local player_name = MP.GetPlayerName(player_id)
    MP.SendChatMessage( -1, "Speed Violation by " .. player_name .. "!")
    MP.SendChatMessage( -1, "Speed: " .. string.format( "%.1f", speedTrapData.playerSpeed * 2.23694 ) .. " in " .. string.format( "%.0f", speedTrapData.speedLimit * 2.23694 ) .. " MPH Zone" )
    MP.SendChatMessage( -1, "Location: " .. triggerPlace)
    MP.SendChatMessage( -1, "Vehicle: " .. speedTrapData.vehicleModel )
    MP.SendChatMessage( -1, "Plate: " .. speedTrapData.licensePlate )
end

function redLight(player_id, data)
    local redLightData = Util.JsonDecode(data)
    local triggerName = redLightData.triggerName
    local triggerNumber = tonumber(string.match(triggerName, "%d+"))
    local triggerPlace = trapNames[triggerNumber] or "Unknown"
    local player_name = MP.GetPlayerName(player_id)
    MP.SendChatMessage( -1, "Failure to stop at Red Light by " .. player_name .. "!")
    MP.SendChatMessage( -1, "Speed: " .. string.format( "%.1f", redLightData.playerSpeed * 2.23694 ) .. " MPH" )
    MP.SendChatMessage( -1, "Location: " .. triggerPlace)
    MP.SendChatMessage( -1, "Vehicle: " .. redLightData.vehicleModel )
    MP.SendChatMessage( -1, "Plate: " .. redLightData.licensePlate )
end

function trafficLightTimer()
	if #MP.GetPlayers() >= 1 then
		MP.TriggerClientEvent(-1, "rxTrafficSignalTimer", tostring(signalTimer:GetCurrent()))
	end
end

function freeRoamVehSyncRequested(player_id)
	MP.TriggerClientEventJson(player_id, "rxFreeRoamVehSync", vehicleStates)
end

function freeRoamPrefabSync(player_id, data)
    local prefab = Util.JsonDecode(data)
    if prefab.pLoad == true then
        loadedPrefabs[player_id][prefab.pName] = prefab
    elseif prefab.pLoad == false then
        loadedPrefabs[player_id][prefab.pName] = nil
    end
	for id in pairs(MP.GetPlayers()) do
		if player_id ~= id then
			MP.TriggerClientEvent(id, "rxPrefabSync", data)
		end
	end
end

function freeRoamSyncRequested(player_id)
    for id in pairs(MP.GetPlayers()) do
		if player_id ~= id then
			if loadedPrefabs[id] then
				for k,v in pairs(loadedPrefabs[id]) do
					MP.TriggerClientEventJson(player_id, "rxPrefabSync", loadedPrefabs[id][k])
				end
			end
        end
    end
end

function freeRoamVehicleActiveHandler(player_id, data)
	local vehicleData = Util.JsonDecode(data)
	if vehicleStates[vehicleData.serverVehicleID] then
		vehicleStates[vehicleData.serverVehicleID].active = vehicleData.active
	else
		vehicleStates[vehicleData.serverVehicleID] = {}
		vehicleStates[vehicleData.serverVehicleID].active = vehicleData.active
	end
	MP.TriggerClientEventJson(-1, "rxFreeRoamVehSync", vehicleStates)
end

function onPlayerJoinHandler(player_id)
    loadedPrefabs[player_id] = {}
end

function onVehicleSpawnHandler(player_id, vehicle_id,  data)
	vehicleStates[player_id .. "-" .. vehicle_id] = {}
	vehicleStates[player_id .. "-" .. vehicle_id].active = true
	MP.TriggerClientEventJson(-1, "rxFreeRoamVehSync", vehicleStates)
end

function onVehicleEditedHandler(player_id, vehicle_id,  data)
	if vehicleStates[player_id .. "-" .. vehicle_id] then
		vehicleStates[player_id .. "-" .. vehicle_id].active = true
	else
		vehicleStates[player_id .. "-" .. vehicle_id] = {}
		vehicleStates[player_id .. "-" .. vehicle_id].active = true
	end
end

function onVehicleDeletedHandler(player_id, vehicle_id)
	if vehicleStates[player_id .. "-" .. vehicle_id] then
		vehicleStates[player_id .. "-" .. vehicle_id] = nil
	end
end

function onPlayerDisconnectHandler(player_id)
	loadedPrefabs[player_id] = nil
end
