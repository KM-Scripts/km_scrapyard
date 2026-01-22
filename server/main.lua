local spawnPoint

Citizen.CreateThread(function()
    Wait(1000)
    spawnPoint = math.random(1, #Config.Locations)
end)

lib.callback.register('km_scrapyard:server:location', function()
    return Config.Locations[spawnPoint].Zone, Config.Locations[spawnPoint].Ped
end)

lib.callback.register("km_scrapyard:server:buyScrapping", function(source, vehicle)
    local source = source
    
end)