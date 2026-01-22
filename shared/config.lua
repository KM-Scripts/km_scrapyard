Config = {}

Config.PedModel = "s_m_y_construct_01" -- Ped model for the NPC at scrapyard
Config.PedAnimDict = "anim@heists@humane_labs@finale@strip_club" -- Animation dictionary for the NPC
Config.PedAnim = "ped_b_celebrate_loop" -- Animation name for the NPC

Config.PedTarget = {
    Label = "Talk to Scrap Dealer",
    Icon = "fas fa-dumpster",
    InteractDistance = 3.0
}

Config.NpcContextMenu = {
    Title = "Scrap Dealer",

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
}

Config.Locations = {
    {Zone = vec3(100.0, -200.0, 20.0), ZoneRadius = 10.0, Ped = vec4(100.0, -200.0, 20.0, 90.0)},
}
