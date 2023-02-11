-- [[ QBCore Function ]] --
local QBCore = exports['qb-core']:GetCoreObject()

-- [[ Events ]] --
RegisterNetEvent('LENT-GovernmentJob:Client:SelectVehicle', function()
    local Job = QBCore.Functions.GetPlayerData().job.name
    local CurrentGarage = 0
    local pos = GetEntityCoords(PlayerPedId())

    local vehicleMenu = {
        {
            header = Config.MenuName,
            icon = Config.IconName,
            isMenuHeader = true,
        }
    }

    for k, v in pairs(CoordsList.Coords[QBCore.Functions.GetPlayerData().job.name]) do
        if #(pos - v) < 5 then
            CurrentGarage = k
        end
    end 

    if Job == Config.Job["DOJ"] then
    elseif Job == Config.Job["StatePolice"] then
    elseif Job == Config.Job["Police"] then
    elseif Job == Config.Job["Sheriff"] then
        local CurrentGarage = CurrentGarage
        local pos = GetEntityCoords(PlayerPedId())
        local takeLoc = CoordsList.Coords['bcso'][CurrentGarage]

        if not takeLoc then return end

        if #(pos - takeLoc) <= 10.0 then
            local ChooseRandomCoord = CoordsList.RandomSpawns['bcso'][CurrentGarage]
            local RandomizedCoord = (ChooseRandomCoord[math.random(#ChooseRandomCoord)])

            local AuthorizedVehicles = Vehicles.AuthorizedVehiclesBCSO[QBCore.Functions.GetPlayerData().job.grade.level]
            for veh, label in pairs(AuthorizedVehicles) do
                vehicleMenu[#vehicleMenu + 1] = {
                    header = label,
                    params = {
                        event = "LENT-GovernmentJob:Client:SpawnSelectedVehicle",
                        args = {
                            vehicle = veh,
                            coords = RandomizedCoord
                        }
                    }
                }
            end
        end
    elseif Job == Config.Job["Corrections"] then
    elseif Job == Config.Job["FireDepartment"] then
    end

    vehicleMenu[#vehicleMenu + 1] = {
        header = "Close Menu",
        params = {
            event = "qb-menu:client:closeMenu"
        }

    }

    exports['LENT-Menu']:openMenu(vehicleMenu)
end)

-- [ Spawn Vehicle Event ]
RegisterNetEvent("LENT-GovernmentJob:Client:SpawnSelectedVehicle", function(data)
    local coords = data.coords
    local dataVehicle = data.vehicle

    local vehicleCode = dataVehicle
    
    if not IsModelInCdimage(vehicleCode) then 
        return 
    end
    
    RequestModel(vehicleCode)
    
    while not HasModelLoaded(vehicleCode) do
        Wait(10)
    end

    local MyPed = PlayerPedId()
    local plate = Config.Plate

    local vehicle = CreateVehicle(vehicleCode, coords.x, coords.y, coords.z-1, coords.w, true, false) -- Spawns a networked vehicle on your current coords

    SetVehicleNumberPlateText(vehicle, plate)

    if Vehicle.VehicleSettings[vehicleCode] ~= nil then
        if Vehicle.VehicleSettings[vehicleCode].extras ~= nil then
            QBCore.Shared.SetDefaultVehicleExtras(vehicle, Vehicle.VehicleSettings[vehicleCode].extras)
        end
        if Vehicle.VehicleSettings[vehicleCode].livery ~= nil then
            SetVehicleLivery(vehicle, Vehicle.VehicleSettings[vehicleCode].livery)
        end
    end

    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
    SetVehicleEngineOn(vehicle, true, true)
    SetVehicleDirtLevel(vehicle, 0.0)

    exports['cdn-fuel']:SetFuel(vehicle, 100.0)

    SetModelAsNoLongerNeeded(vehicleCode) -- removes model from game memory as we no longer need it    
end)

RegisterNetEvent('LENT-GovernmentJob:Client:StoreVehicle', function()
    local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    local vehicleClass = GetVehicleClass(vehicle)

    for k, v in pairs(Config.ParkingLocations) do
        if #(plyCoords - v["Coords"]) <= 10.0 then
            if vehicleClass == 18 then
                QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
            end
        end
    end
end)