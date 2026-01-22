local zoneLocation, zoneRadius, pedLocation = lib.callback.await('km_scrapyard:server:location')

function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(1)
        RequestModel(model)
    end
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(1)
        RequestAnimDict(dict)
    end
end

local function GetVehiclesInZone()
    local vehicles = {}
    local nearbyVehicles = lib.getNearbyVehicles(zoneLocation, zoneRadius, true)
    for _, vehicle in ipairs(nearbyVehicles) do
        table.insert(vehicles, vehicle.vehicle)
    end
    return vehicles
end

local function buyVehicleScraping(vehicle)
    
end

local function CreateAndOpenContextMenu()
    local options = {}
    local vehiclesInZone = GetVehiclesInZone()

    options.push({
        title = Config.NpcContextMenu.FirstOption.Title,
        description = Config.NpcContextMenu.FirstOption.Description,
        readOnly = true
    })

    for _, vehicle in vehiclesInZone do
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        local vehicleDisplayName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

        options.push({
            title = Config.NpcContextMenu.VehicleOption.Title:gsub("${vehicleDisplayName}", vehicleDisplayName),
            description = Config.NpcContextMenu.VehicleOptions.Description:gsub("${vehiclePlate}", vehiclePlate),
            onSelect = function ()
                print("Selected vehicle with plate: " .. vehiclePlate)
            end
        })
    end

    if options == 0 then
        options.push({
            title = Config.NpcContextMenu.NoVehiclesOption.Title,
            description = Config.NpcContextMenu.NoVehiclesOption.Description,
            readOnly = true
        })
    end

    options.push({
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
        loadModel(Config.PedModel)

        Ped = CreatePed(4, Config.PedModel, pedLocation.x, pedLocation.y, pedLocation.z - 1.0, pedLocation.w, true, true)
        FreezeEntityPosition(Ped, true)
        SetEntityInvincible(Ped, true)
        SetBlockingOfNonTemporaryEvents(Ped, true)

        exports.ox_target:addEntity(Ped, {
            {
                distance = Config.PedTarget.InteractDistance,
                name = 'scrap_ped_interact',
                label = Config.PedTarget.Label,
                icon = Config.PedTarget.Icon,
                onSelect = function()
                    print('Interacted with Scrap Dealer')
                    CreateAndOpenContextMenu()                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
                end
           }
        })

        loadAnimDict(Config.PedAnimDict)
        TaskPlayAnim(Ped, Config.PedAnimDict, Config.PedAnim, 2.0, 2.0, -1, 4, 0, false, false, false)
    else
        if DoesEntityExist(Ped) then
            DeletePed(Ped)
        end

        SetModelAsNoLongerNeeded(Config.PedModel)
        RemoveAnimDict(Config.PedAnimDict)
    end
end


-- Initialization Thtread
Citizen.CreateThread(function()
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