local zoneLocation, pedLocation = lib.callback.await('km_scrapyard:server:location')

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

local function SpawnScrapPed()
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
                -- TODO: Interaction Menu
            end
        }
    })

    loadAnimDict(Config.PedAnimDict)
    TaskPlayAnim(Ped, Config.PedAnimDict, Config.PedAnim, 2.0, 2.0, -1, 4, 0, false, false, false)
end