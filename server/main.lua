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

local buyCooldowns = {}
lib.callback.register("km_scrapyard:server:buyScrapping", function(source, vehicle)
    if buyCooldowns[source] and os.time() < buyCooldowns[source] then
        -- Notify too fast
        return false
    end

    if not DistCheck(source, Config.Locations[spawnPoint].Ped.xyz, 5.0) then
        -- Notify too far from NPC
        return false
    end

    if not DoesEntityExist(vehicle) then
        -- Notify vehicle dont exist
        return false
    end

    local vehicleCoords = GetEntityCoords(vehicle)
    local distanceFromZone = #(vehicleCoords.xyz - Config.Locations[spawnPoint].Zone.xyz)

    if distanceFromZone > Config.Locations[spawnPoint].ZoneRadius then
        -- Notify vehicle not in scrapyard zone
        return false
    end

    buyCooldowns[source] = os.time() + 1

    local cost = 250 -- TODO: Make this in config some way...
    local money = exports.ox_inventory:GetItem(source, 'money', false) -- TODO: Config for payment item (money, black_money...)

    if not money or money.count < cost then
        -- Notify not enough money
        return false
    end

    exports.ox_inventory:RemoveItem(source, 'money', cost) -- TODO: the same config item...
    return true
end)