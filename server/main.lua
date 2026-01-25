local spawnPoint

Citizen.CreateThread(function()
    Wait(1000)
    spawnPoint = math.random(1, #Config.Locations)
end)

-- Edit this if you want to use some other notify script
local function Notify(title, message, type, duration)
    TriggerClientEvent('ox_lib:notify', source, {
        title = title,
        description = message,
        type = type,
        duration = duration,
    })
end

local function DistCheck(playerID, coords, check)
    local ped = GetPlayerPed(playerID)
    if not DoesEntityExist(ped) then return false end

    local playerCoords = GetEntityCoords(ped)
    local dist = #(playerCoords.xyz - coords)

    return dist <= check
end

lib.callback.register('km_scrapyard:server:location', function()
    if not spawnPoint then
        spawnPoint = math.random(1, #Config.Locations)
    end

    return Config.Locations[spawnPoint].Zone, Config.Locations[spawnPoint].ZoneRadius ,Config.Locations[spawnPoint].Ped
end)

local buyScrappingCooldowns = {}
lib.callback.register("km_scrapyard:server:buyScrapping", function(source, vehicle)
    if buyScrappingCooldowns[source] and os.time() < buyScrappingCooldowns[source] then
        Notify(Config.Notify.Title, Config.Notify.YouNeedToWait, "error", 2500)
        return false
    end

    if not DistCheck(source, Config.Locations[spawnPoint].Ped.xyz, 5.0) then
       Notify(Config.Notify.Title, Config.Notify.TooFarFromNPC, "error", 2500)
        return false
    end

    if not DoesEntityExist(vehicle) then
        Notify(Config.Notify.Title, Config.Notify.VehicleDontExist, "error", 2500)
        return false
    end

    local vehicleCoords = GetEntityCoords(vehicle)
    local distanceFromZone = #(vehicleCoords.xyz - Config.Locations[spawnPoint].Zone.xyz)

    if distanceFromZone > Config.Locations[spawnPoint].ZoneRadius then
        Notify(Config.Notify.Title, Config.Notify.VehicleNotInScrapyard, "error", 2500)
        return false
    end

    buyScrappingCooldowns[source] = os.time() + 1

    local price = 250 -- TODO: Make this in config some way...
    local money = exports.ox_inventory:GetItem(source, 'money', false) -- TODO: Config for payment item (money, black_money...)

    if not money or money.count < price then
        Notify(Config.Notify.Title, Config.Notify.NotEnoughMoney, "error", 2500)
        return false
    end

    exports.ox_inventory:RemoveItem(source, 'money', price) -- TODO: the same config item...
    return true
end)

local buyItemCooldown = {}
lib.callback.register("km_scrapyard:server:buyItem", function(source, itemData)
    if buyItemCooldown[source] and os.time() < buyItemCooldown[source] then
        Notify(Config.Notify.Title, Config.Notify.YouNeedToWait, "error", 2500)
        return false
    end

    if not DistCheck(source, Config.Locations[spawnPoint].Ped.xyz, 5.0) then
        Notify(Config.Notify.Title, Config.Notify.TooFarFromNPC, "error", 2500)
        return false
    end

    local canBeItemBought = false
    for _, itemDataf in ipairs(Config.ScrapyardShop) do
        if itemDataf == itemData then
            canBeItemBought = true
            break
        end
    end
    if not canBeItemBought then
        Notify(Config.Notify.Title, Config.Notify.NotSellingItem, "error", 2500)
        return false
    end

    buyScrappingCooldowns[source] = os.time() + 1
    local price = itemData.price
    local money = exports.ox_inventory:GetItem(source, 'money', false) -- TODO: Add config for payment method item

    if not money or money < price then
        return false
    end

    exports.ox_inventory:RemoveItem(source, 'money', price)
    exports.ox_inventory:AddItem(source, itemData.item, 1)
    return true
end)

AddEventHandler('playerDropped', function ()
    local source = source
    buyScrappingCooldowns[source] = nil
end)