--[[
Not_Lowest
Delinquent Studios LLC
Advanced Advert Server
]]

if not SERVER then return end

AddCSLuaFile("an_advert_config.lua")
AddCSLuaFile("autorun/cl_an_advert.lua")

include("an_advert_config.lua")

util.AddNetworkString("ANAdvert_Message")

local LastAdvert = {}

local NamedColors = {
    red    = {type="color",r=255,g=0,b=0},
    green  = {type="color",r=0,g=255,b=0},
    blue   = {type="color",r=0,g=120,b=255},
    yellow = {type="color",r=255,g=255,b=0},
    white  = {type="color",r=255,g=255,b=255},
    orange = {type="color",r=255,g=150,b=0},
    purple = {type="color",r=180,g=0,b=255}
}

local function ParseAdvert(text)

    local tokens = {}
    local i = 1
    local len = #text

    while i <= len do

        local s,e = text:find("<[^>]+>",i)

        if s then

            if s > i then
                tokens[#tokens+1] = {
                    type="text",
                    value=text:sub(i,s-1)
                }
            end

            local tag = text:sub(s+1,e-1):lower()

            local name = tag:match("^(%a+)$")
            local r,g,b = tag:match("^color=(%d+),(%d+),(%d+)$")
            local hex = tag:match("^#(%x%x%x%x%x%x)$")
            local rainbowSpeed = tag:match("^rainbow speed=(%d+)$")
            local g1,g2 = tag:match("^gradient=(#%x%x%x%x%x%x),(#%x%x%x%x%x%x)$")

            if name and NamedColors[name] then

                tokens[#tokens+1] = NamedColors[name]

            elseif tag == "team" then

                tokens[#tokens+1] = {type="team"}

            elseif tag == "rainbow" then

                tokens[#tokens+1] = {type="rainbow",speed=120}

            elseif rainbowSpeed then

                tokens[#tokens+1] = {type="rainbow",speed=tonumber(rainbowSpeed)}

            elseif tag == "wave" then

                tokens[#tokens+1] = {type="wave"}

            elseif tag == "shake" then

                tokens[#tokens+1] = {type="shake"}

            elseif g1 then

                local r1 = tonumber(g1:sub(2,3),16)
                local g1c = tonumber(g1:sub(4,5),16)
                local b1 = tonumber(g1:sub(6,7),16)

                local r2 = tonumber(g2:sub(2,3),16)
                local g2c = tonumber(g2:sub(4,5),16)
                local b2 = tonumber(g2:sub(6,7),16)

                tokens[#tokens+1] = {
                    type="gradient",
                    r1=r1,g1=g1c,b1=b1,
                    r2=r2,g2=g2c,b2=b2
                }

            elseif r then

                tokens[#tokens+1] = {
                    type="color",
                    r=tonumber(r),
                    g=tonumber(g),
                    b=tonumber(b)
                }

            elseif hex then

                tokens[#tokens+1] = {
                    type="color",
                    r=tonumber(hex:sub(1,2),16),
                    g=tonumber(hex:sub(3,4),16),
                    b=tonumber(hex:sub(5,6),16)
                }

            end

            i = e + 1

        else

            tokens[#tokens+1] = {
                type="text",
                value=text:sub(i)
            }

            break
        end

    end

    return tokens
end


timer.Simple(5,function()

    if not DarkRP then
        print("[ANAdvert] DarkRP not detected.")
        return
    end

    DarkRP.removeChatCommand(ANAdvert.Config.Command_Name)

    local function PlayerAdvertise(ply,args)

        if args == "" then
            DarkRP.notify(ply,1,4,"Usage: /"..ANAdvert.Config.Command_Name.." <message>")
            return ""
        end

        if #args > 300 then
            DarkRP.notify(ply,1,4,"Advert too long.")
            return ""
        end

        local steamid = ply:SteamID64()
        local now = CurTime()

        local cooldown = ANAdvert.Config.AdvertCooldown

        if not (ANAdvert.Config.AdminBypass and ply:IsAdmin()) then

            local last = LastAdvert[steamid] or 0
            local remaining = cooldown - (now-last)

            if remaining > 0 then
                DarkRP.notify(ply,1,4,"Wait "..math.ceil(remaining).." seconds.")
                return ""
            end

        end

        LastAdvert[steamid] = now

        local tokens = ParseAdvert(args)

        net.Start("ANAdvert_Message")

            net.WriteEntity(ply)
            net.WriteUInt(#tokens,8)

            for i=1,#tokens do

                local t = tokens[i]

                net.WriteString(t.type)

                if t.type == "text" then

                    net.WriteString(t.value)

                elseif t.type == "color" then

                    net.WriteUInt(t.r,8)
                    net.WriteUInt(t.g,8)
                    net.WriteUInt(t.b,8)

                elseif t.type == "rainbow" then

                    net.WriteUInt(t.speed or 120,16)

                elseif t.type == "gradient" then

                    net.WriteUInt(t.r1,8)
                    net.WriteUInt(t.g1,8)
                    net.WriteUInt(t.b1,8)

                    net.WriteUInt(t.r2,8)
                    net.WriteUInt(t.g2,8)
                    net.WriteUInt(t.b2,8)

                end

            end

        net.Broadcast()

        return ""

    end

    DarkRP.declareChatCommand{
        command = ANAdvert.Config.Command_Name,
        description = "Advertise something.",
        delay = ANAdvert.Config.AdvertCooldown
    }

    DarkRP.defineChatCommand(
        ANAdvert.Config.Command_Name,
        PlayerAdvertise,
        ANAdvert.Config.AdvertCooldown
    )

end)