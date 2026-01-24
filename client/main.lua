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

local function CreateShopContextMenu()
    local options = {}

    for _, itemData in ipairs(Config.ScrapyardShop) do
        table.insert(options, {
            title = Config.NpcContextMenu.ShopMenu.ShopItemOption.Title:gsub("${itemLabel}", itemData.shopLabel),
            description = Config.NpcContextMenu.ShopMenu.ShopItemOption.Description:gsub("${itemLabel}", itemData.shopLabel):gsub("${itemPrice}", itemData.price),
            onSelect = function ()
                print("Buy " .. itemData.shopLabel .. " for " .. itemData.price)
                -- TODO: Function to buy item send itemData.item
            end
        })
    end

    table.insert(options, {
        title = Config.NpcContextMenu.BackOption.Title,
        icon = Config.NpcContextMenu.BackOption.Icon,
        onSelect = function ()
            lib.showContext('km_scrapyard_main_npc_menu')
        end
    })

    lib.registerContext({
        id = 'km_scrapyard_shop',
        title = Config.NpcContextMenu.Title,
        options = options
    })
end

local function CreateScrapContextMenu()
    local options = {}
    local vehiclesInZone = GetVehiclesInZone()

    table.insert(options, {
        title = Config.NpcContextMenu.ScrapVehicleMenu.FirstOption.Title,
        description = Config.NpcContextMenu.ScrapVehicleMenu.FirstOption.Description,
        readOnly = true
    })

    for _, vehicle in ipairs(vehiclesInZone) do
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        local vehicleDisplayName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))

        table.insert(options ,{
            title = Config.NpcContextMenu.ScrapVehicleMenu.VehicleOption.Title:gsub("${vehicleDisplayName}", vehicleDisplayName),
            description = Config.NpcContextMenu.ScrapVehicleMenu.VehicleOption.Description:gsub("${vehiclePlate}", vehiclePlate),
            onSelect = function ()
                print("Selected vehicle with plate: " .. vehiclePlate)
            end
        })
    end

    if #vehiclesInZone == 0 then
        table.insert(options, {
            title = Config.NpcContextMenu.ScrapVehicleMenu.NoVehiclesOption.Title,
            description = Config.NpcContextMenu.ScrapVehicleMenu.NoVehiclesOption.Description,
            readOnly = true
        })
    end

    table.insert(options, {
        title = Config.NpcContextMenu.BackOption.Title,
        icon = Config.NpcContextMenu.BackOption.Icon,
        onSelect = function ()
            lib.showContext('km_scrapyard_main_npc_menu')
        end
    })

    lib.registerContext({
        id = 'km_scrapyard_select_vehicle_menu',
        title = Config.NpcContextMenu.Title,
        options = options
    })
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
                    lib.registerContext({
                        id = 'km_scrapyard_main_npc_menu',
                        title = Config.NpcContextMenu.Title,
                        options = {
                            {
                                title = Config.NpcContextMenu.OpenShopMenu.Title,
                                description = Config.NpcContextMenu.OpenShopMenu.Description,
                                onSelect = function()
                                    CreateShopContextMenu()
                                    lib.showContext("km_scrapyard_shop")
                                end
                            },
                            {
                                title = Config.NpcContextMenu.OpenShopMenu.Title,
                                description = Config.NpcContextMenu.OpenShopMenu.Description,
                                onSelect = function ()
                                    CreateScrapContextMenu()
                                    lib.showContext('km_scrapyard_select_vehicle_menu')
                                end
                            }
                        }
                    })
                    lib.showContext('km_scrapyard_main_npc_menu')
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