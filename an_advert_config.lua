ANAdvert = ANAdvert or {}

ANAdvert.Config = {

    AdvertCooldown = 30,      -- seconds between adverts
    SpamLimit = 5,            -- attempts before mute
    SpamMuteTime = 120,       -- mute duration in seconds

    an_advert_cost = 0        -- Cost

    AdminBypass = true,       -- admins ignore cooldown

    Command_Name = "advert",  -- Do not put the / here unless you want //advert
    Prefix = "[ADVERT]",

    DefaultAdvertColor = Color(255,255,0,194)

}