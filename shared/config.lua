Config = {}

Config.PedModel = "s_m_y_construct_01" -- Ped model for the NPC at scrapyard
Config.PedAnimDict = "anim@heists@humane_labs@finale@strip_club" -- Animation dictionary for the NPC
Config.PedAnim = "ped_b_celebrate_loop" -- Animation name for the NPC

Config.PedTarget = {
    Label = "Talk to Scrap Dealer",
    Icon = "fas fa-dumpster",
    InteractDistance = 3.0
}

Config.ScrapyardShop = {
    { item = "screwdriver", price = 500, shopLabel = "Screwdriver" },
    { item = "WEAPON_WRENCH", price = 2000, shopLabel = "Wrench"},
    { item = "WEAPON_CROWBAR", price = 3500, shopLabel = "Crowbar"}
}

Config.NpcContextMenu = {
    Title = "Scrapyard Dealer",

    OpenShopMenu = {
        Title = "Scrapyard Shop",
        Description = "Buy tools for scrapping"
    },

    OpenScrapVehicleMenu = {
        Title = "Scrap Vehicle",
        Description = "Select vehicle for scrapping"
    },

    ShopMenu = {
        ShopItemOption = {
            Title = "${itemLabel}",
            Description = "Buy ${itemLabel} for $${itemPrice}"
        }
    },

    ScrapVehicleMenu = {
        FirstOption = {
            Title = "Select a vehicle to scrap",
            Description = "Choose from the list below:",
        },

        VehicleOption = {
            Title = "${vehicleDisplayName}",
            Description = "Plate: ${vehiclePlate}",
        },

        NoVehiclesOption = {
            Title = "No vehicles found",
            Description = "There are no vehicles in the scrapyard zone.",
        },

        CloseMenuOption = {
            Title = "Close",
            Description = "Close this menu.",
        }
    },

    BackOption = {
        Title = "Back",
        Icon = "arrow-left"
    }
}

Config.Locations = {
    {Zone = vec3(1563.6631, -2163.8687, 77.5299), ZoneRadius = 50.0, Ped = vec4(1553.6616, -2177.4434, 77.3225, 267.4076)},
    {Zone = vec3(1563.6631, -2163.8687, 77.5299), ZoneRadius = 50.0, Ped = vec4(1567.4507, -2179.2358, 77.4686, 59.2518)},
}