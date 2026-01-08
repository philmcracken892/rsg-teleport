Config = {}


Config.InteractionDistance = 1.5
Config.UseFadeEffect = true
Config.FadeDuration = 500
Config.PromptKey = 0xD9D0E1C0  --- space key
Config.UseHoldMode = true      

-- Teleport Locations
Config.Locations = {
   
    {
        name = "couthouse",
        
        -- Entry point (outside)
        enterPos = vector3(-798.645, -1202.61, 44.193),
        enterHeading = 0.0,
        enterPrompt = "Enter Building",
        
        -- Exit point (inside)
        exitPos = vector3(-756.639, -1174.74, 23.879),
        exitHeading = 180.0,
        exitPrompt = "Exit Building",
        
        -- Blip settings (optional)
        showBlip = true,
        blip = {
            x = -798.645,
            y = -1202.61,
            z = 44.193,
            sprite = "blip_shop_store",
            name = "couthouse",
            color = "BLIP_MODIFIER_MP_COLOR_5"  -- Optional
        }
    },

    
}
