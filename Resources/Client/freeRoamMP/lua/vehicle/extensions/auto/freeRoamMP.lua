
local M = {}

local function onVehicleReady()
	obj:queueGameEngineLua("freeRoamMP.onVehicleReady(" .. obj:getID() .. ") ")
end

M.onVehicleReady    = onVehicleReady

return M
