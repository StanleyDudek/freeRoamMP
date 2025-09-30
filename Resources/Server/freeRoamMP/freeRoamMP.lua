--freeRoamMP (SERVER) by Dudekahedron, 2025

local vehicleStates = {}
local loadedPrefabs = {}

function onInit()
	MP.RegisterEvent("freeRoamPrefabSync","freeRoamPrefabSync")
	MP.RegisterEvent("freeRoamSyncRequested","freeRoamSyncRequested")
	MP.RegisterEvent("freeRoamVehSyncRequested","freeRoamVehSyncRequested")
	MP.RegisterEvent("freeRoamVehicleActiveHandler","freeRoamVehicleActiveHandler")
	MP.RegisterEvent("onPlayerJoin","onPlayerJoinHandler")
	MP.RegisterEvent("onVehicleSpawn","onVehicleSpawnHandler")
	MP.RegisterEvent("onVehicleEdited","onVehicleEditedHandler")
	MP.RegisterEvent("onVehicleDeleted","onVehicleDeletedHandler")
	MP.RegisterEvent("onPlayerDisconnect","onPlayerDisconnectHandler")
	print("[freeRoam] ---------- freeRoam Loaded!")
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
