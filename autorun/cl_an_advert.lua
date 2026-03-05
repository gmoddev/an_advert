--[[
Not_Lowest
Delinquent Studios LLC
]]

if CLIENT then

include("an_advert_config.lua")

local ColorTags = {
    red = Color(255,0,0),
    green = Color(0,255,0),
    blue = Color(0,120,255),
    yellow = Color(255,255,0),
    white = Color(255,255,255),
    orange = Color(255,150,0),
    purple = Color(180,0,255)
}

local function ParseColors(text)

    local parts = {}
    local currentColor = ANAdvert.Config.DefaultAdvertColor

    for token in string.gmatch(text,"<[^>]+>|[^<]+") do

        local lower = string.lower(token)

        --// Named colors
        local name = lower:match("<(%a+)>")

        if name and ColorTags[name] then
            currentColor = ColorTags[name]
            continue
        end

        --// RGB colors
        local r,g,b = lower:match("<color=(%d+),(%d+),(%d+)>")

        if r then
            currentColor = Color(tonumber(r),tonumber(g),tonumber(b))
            continue
        end

        table.insert(parts,currentColor)
        table.insert(parts,token)

    end

    return parts

end

net.Receive("AdvertMessage",function()

    local ply = net.ReadEntity()
    local msg = net.ReadString()

    local args = {
        Color(255,200,0),
        ANAdvert.Config.Prefix,
        Color(255,255,255),
        ply:Nick()..": "
    }

    local parsed = ParseColors(msg)

    for _,v in ipairs(parsed) do
        table.insert(args,v)
    end

    chat.AddText(unpack(args))

end)

end