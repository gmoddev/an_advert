
--[[
Not_Lowest
Delinquent Studios LLC
]]
if not CLIENT then
    return 
end

include("an_advert_config.lua")

net.Receive("ANAdvert_Message",function()

    local ply = net.ReadEntity()
    local count = net.ReadUInt(8)

    local parts = {}

    local colorMode = ANAdvert.Config.DefaultAdvertColor
    local hueBase = CurTime()*120

    for i=1,count do

        local t = net.ReadString()

        if t == "text" then

            local txt = net.ReadString()

            if colorMode == "rainbow" then

                for c = 1,#txt do

                    local ch = txt:sub(c,c)
                    local hue = (hueBase + c*15) % 360
                    local col = HSVToColor(hue,1,1)

                    parts[#parts+1] = col
                    parts[#parts+1] = ch

                end

            else

                parts[#parts+1] = colorMode
                parts[#parts+1] = txt

            end

        elseif t == "color" then

            colorMode = {
                r = net.ReadUInt(8),
                g = net.ReadUInt(8),
                b = net.ReadUInt(8)
            }

        elseif t == "rainbow" then

            colorMode = "rainbow"

        elseif t == "team" then

            colorMode = team.GetColor(ply:Team())

        end

    end

    local prefixColor = team.GetColor(ply:Team())

    chat.AddText(
        prefixColor,
        ANAdvert.Config.Prefix.." "..ply:Nick()..": ",
        unpack(parts)
    )

end)

