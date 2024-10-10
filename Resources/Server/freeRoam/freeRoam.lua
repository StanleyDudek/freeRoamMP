--freeRoamMP (SERVER) by Dudekahedron, 2024

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
	MP.RegisterEvent("onPlayerDisconnect","onPlayerDisconnectHandler")
	print("[freeRoam] ---------- freeRoam Loaded!")
end

function freeRoamVehSyncRequested(player_id)
	MP.TriggerClientEventJson(player_id, "rxFreeRoamSync", vehicleStates)
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
					MP.TriggerClientEvent(player_id, "rxPrefabSync", k)
				end
			end
        end
    end
end

function freeRoamVehicleActiveHandler(player_id, data)
	local tempData = Util.JsonDecode(data)
	if string.find(tempData[2], "-") then
		if vehicleStates[tempData[2]] then
			vehicleStates[tempData[2]].active = tempData[1]
		else
			vehicleStates[tempData[2]] = {}
			vehicleStates[tempData[2]].active = tempData[1]
		end
		MP.TriggerClientEventJson(-1, "rxFreeRoamSync", vehicleStates)
	end
end

function onPlayerJoinHandler(player_id)
    loadedPrefabs[player_id] = {}
	freeRoamVehSyncRequested(player_id)
end

function onVehicleSpawnHandler(player_id, vehicle_id,  data)
	vehicleStates[player_id .. "-" .. vehicle_id] = {}
	vehicleStates[player_id .. "-" .. vehicle_id].active = true
end

function onVehicleEditedHandler(player_id, vehicle_id,  data)
	if vehicleStates[player_id .. "-" .. vehicle_id] then
		vehicleStates[player_id .. "-" .. vehicle_id].active = true
	else
		vehicleStates[player_id .. "-" .. vehicle_id] = {}
		vehicleStates[player_id .. "-" .. vehicle_id].active = true
	end
end

function onPlayerDisconnectHandler(player_id)
	for id in pairs(vehicleStates) do
		if string.find(id, player_id .. "-") then
			vehicleStates[id] = nil
		end
	end
end
