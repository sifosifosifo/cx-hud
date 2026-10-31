Config = {}
Config.Version = "1.2.6" -- Don't change this, it is used for version checking and update notifications.

Config.DefaultVoice        = 'Normal'
Config.ShowStress          = false
Config.StressThreshold     = 5
Config.UpdateInterval      = 100
Config.MenuCommand            = 'hud'

-- ps-buffs integration
Config.UsePSBuffs            = false

-- Hide Minimap on foot
Config.HideMapAndStreetOnFoot = false

-- Redline threshold (percentage)
Config.RedlineThreshold = 85

-- jg-vehiclemileage integration
Config.JGMileage = true

-- Seatbelt settings
Config.EnableSeatbelt    = true -- do u even want to use our seatbelt? if not set it to false
Config.SeatbeltEject      = true
Config.SeatbeltEjectSpeed = 60.0
Config.SeatbeltBodyThresh = 500.0

-- Warning thresholds
Config.WarnHealth  = 20
Config.WarnHunger  = 15
Config.WarnThirst  = 15
Config.WarnFuel    = 10
Config.WarnEngine  = 20
Config.WarnAmmoClip = 5 -- ammo clip count below which the counter turns red

Config.Logo = {
    enabled        = true,
    url            = 'logo-animation-transparent.png', -- Local files are loaded from this resource's html folder.
    width          = 200,
    height         = 120,
    scale          = 1.0,
    position       = {
        top         = 10, -- Percentage from the top of the screen.
        left        = 50, -- Percentage from the left of the screen.
    },
    transparentBg  = true,
    zIndex         = 100,
}

-- Weapon item images (don't touch unless you know what you're doing)
Config.InventoryImages = {
    autoDetect = true,
    inventories = {
        { resource = 'qb-inventory',   path = 'nui://qb-inventory/web/images/%s' },
        { resource = 'qb-inventory',   path = 'nui://qb-inventory/html/images/%s' },
        { resource = 'ps-inventory',   path = 'nui://ps-inventory/html/images/%s' },
        { resource = 'core_inventory', path = 'nui://core_inventory/html/img/%s' },
        { resource = 'ox_inventory',   path = 'nui://ox_inventory/html/images/%s' },
    }
}

-- Default component visibility for new players
Config.DefaultVisible = {
    portrait    = true,
    charname    = true,
    voice       = true,
    playerid    = true,
    job         = true,
    cash        = true,
    bank        = false,
    minimap       = true,
    minimapBorder = true,
    streetPill    = true,
    streetclock   = true,
    streetCompass = true,
    statusRow     = true,
    radioList     = true,
    psBuffRow     = true,
    health      = true,
    armor       = true,
    hunger      = true,
    thirst      = true,
    vehicle     = true,
    lights      = true,
    cinebars    = false,
    logo        = true,
    weapon      = true,
}

-- Set a key to false to lock it server-side (players cannot toggle it via /hud).
-- Keys must match those in Config.DefaultVisible above.
Config.MenuOptions = {
    portrait    = true,
    charname    = true,
    voice       = true,
    playerid    = true,
    job         = true,
    cash        = true,
    bank        = true,
    minimap       = true,
    minimapBorder = true,
    streetPill    = true,
    streetclock   = true,
    streetCompass = true,
    statusRow     = true,
    radioList     = true,
    psBuffRow     = true,
    health      = true,
    armor       = true,
    hunger      = true,
    thirst      = true,
    vehicle     = true,
    lights      = true,
    cinebars    = true,
    logo        = false,
    weapon      = true,
}

-- UI colours, injected into CSS as custom properties
Config.Colors = {
    panel          = 'rgba(6, 9, 16, 0.88)',
    panel2         = 'rgba(10, 15, 24, 0.94)',
    border         = 'rgba(255,255,255,0.07)',
    border2        = 'rgba(255,255,255,0.12)',
    text           = '#d9d9d9',
    muted          = '#7a87a4',
    accent         = '#7ee8ca',
    cash           = '#5cf0a0',
    bank           = '#7dd8ff',
    ringHealth     = '#ff5577',
    ringArmor      = '#7ba4ff',
    ringHunger     = '#f5a623',
    ringThirst     = '#38c9ff',
    ringStress     = '#ff2d6b',
    ringStamina    = '#9f78ff',
    ringOxygen     = '#58b7ff',
    arcFuel        = '#7ee8ca',
    arcEngine      = '#8fb8ff',
    lightIndicator = '#f5a623',
    lightHeadlight = '#fff8c0',
    lightHighbeam  = '#7dd8ff',
    beltWarn       = '#ff4466',
    warnGlow       = 'rgba(255,60,60,0.55)',
    ringWeapon     = '#e8c97e',
    ringWeaponLow  = '#ff5555',
}
