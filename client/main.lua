local zoneLocation, zoneRadius, pedLocation
local Ped

local function GetVehiclesInZone()
    local vehicles = {}
    local nearbyVehicles = lib.getNearbyVehicles(zoneLocation, zoneRadius, true)
    for _, vehicleData in ipairs(nearbyVehicles) do
        table.insert(vehicles, vehicleData.vehicle)
    end
    return vehicles
end

local function buyVehicleScraping(vehicle)
    
end

local function CreateAndOpenContextMenu()
    local options = {}
    local vehiclesInZone = GetVehiclesInZone()

    table.insert(options, {
        title = Config.NpcContextMenu.FirstOption.Title,
        description = Config.NpcContextMenu.FirstOption.Description,
        readOnly = true
    })

    for _, vehicle in ipairs(vehiclesInZone) do
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        local vehicleDisplayName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))

        table.insert(options ,{
            title = Config.NpcContextMenu.VehicleOption.Title:gsub("${vehicleDisplayName}", vehicleDisplayName),
            description = Config.NpcContextMenu.VehicleOption.Description:gsub("${vehiclePlate}", vehiclePlate),
            onSelect = function ()
                print("Selected vehicle with plate: " .. vehiclePlate)
            end
        })
    end

    if #vehiclesInZone == 0 then
        table.insert(options, {
            title = Config.NpcContextMenu.NoVehiclesOption.Title,
            description = Config.NpcContextMenu.NoVehiclesOption.Description,
            readOnly = true
        })
    end

    table.insert(options, {
        title = Config.NpcContextMenu.CloseMenuOption.Title,
        description = Config.NpcContextMenu.CloseMenuOption.Description,
        event = 'lib:closeContext',
    })

    lib.registerContext({
        id = 'km_scrapyard_npc_menu',
        title = Config.NpcContextMenu.Title,
        options = options
    })

    lib.showContext('km_scrapyard_npc_menu')
end

-- Function to spawn the NPC (spawn argument true = spawn the ped, false = despawn)
local function SpawnScrapPed(spawn)
    if spawn then
        lib.requestModel(Config.PedModel)

        Ped = CreatePed(4, Config.PedModel, pedLocation.x, pedLocation.y, pedLocation.z - 1.0, pedLocation.w, true, true)
        FreezeEntityPosition(Ped, true)
        SetEntityInvincible(Ped, true)
        SetBlockingOfNonTemporaryEvents(Ped, true)

        exports.ox_target:addLocalEntity(Ped, {
            {
                distance = Config.PedTarget.InteractDistance,
                name = 'km_scrapyard_ped_interact',
                label = Config.PedTarget.Label,
                icon = Config.PedTarget.Icon,
                onSelect = function()
                    print('Interacted with Scrap Dealer')
                    CreateAndOpenContextMenu()                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
                end
           }
        })

        lib.requestAnimDict(Config.PedAnimDict)
        TaskPlayAnim(Ped, Config.PedAnimDict, Config.PedAnim, 2.0, 2.0, -1, 4, 0, false, false, false)
    else
        if DoesEntityExist(Ped) then
            exports.ox_target:removeLocalEntity(Ped, 'km_scrapyard_ped_interact')
            DeletePed(Ped)
        end

        SetModelAsNoLongerNeeded(Config.PedModel)
        RemoveAnimDict(Config.PedAnimDict)
    end
end


-- Initialization Thtread
Citizen.CreateThread(function()
    Wait(2000)
    zoneLocation, zoneRadius, pedLocation = lib.callback.await('km_scrapyard:server:location', false)

    -- Zone Initialization
    local scrapyardZone = lib.zones.sphere({
        coords = zoneLocation,
        radius = zoneRadius,
        debug = true,
        onEnter = function()
            print('Entered the scrapyard zone')
            SpawnScrapPed(true)
        end,
        onExit = function()
            print('Exited the scrapyard zone')
            SpawnScrapPed(false)
        end
    })
end)