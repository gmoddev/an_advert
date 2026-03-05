--[[
Not_Lowest
Delinquent Studios LLC
Advanced Advert Client
]]

if not CLIENT then return end

include("an_advert_config.lua")

net.Receive("ANAdvert_Message",function()

    local ply = net.ReadEntity()
    local count = net.ReadUInt(8)

    local parts = {}

    local colorMode = ANAdvert.Config.DefaultAdvertColor
    local rainbowSpeed = 120
    local effectMode = nil

    local hueBase = CurTime() * rainbowSpeed

    for i = 1, count do

        local t = net.ReadString()

        if t == "text" then

            local txt = net.ReadString()

            if colorMode == "rainbow" or effectMode then

                for c = 1, #txt do

                    local ch = txt:sub(c,c)
                    local col

                    if colorMode == "rainbow" then
                        local hue = (hueBase + c * 15) % 360
                        col = HSVToColor(hue,1,1)
                    else
                        col = colorMode
                    end

                    local char = ch

                    if effectMode == "wave" then
                        if c % 4 == 0 then
                            char = " "..ch
                        end
                    elseif effectMode == "shake" then
                        if math.random(1,4) == 1 then
                            char = ch.." "
                        end
                    end

                    parts[#parts+1] = col
                    parts[#parts+1] = char

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
            rainbowSpeed = net.ReadUInt(16)

        elseif t == "team" then

            colorMode = team.GetColor(ply:Team())

        elseif t == "gradient" then

            local r1 = net.ReadUInt(8)
            local g1 = net.ReadUInt(8)
            local b1 = net.ReadUInt(8)

            local r2 = net.ReadUInt(8)
            local g2 = net.ReadUInt(8)
            local b2 = net.ReadUInt(8)

            colorMode = {
                gradient = true,
                r1=r1,g1=g1,b1=b1,
                r2=r2,g2=g2,b2=b2
            }

        elseif t == "wave" then
            effectMode = "wave"

        elseif t == "shake" then
            effectMode = "shake"

        end

    end

    local prefixColor = team.GetColor(ply:Team())

    chat.AddText(
        prefixColor,
        ANAdvert.Config.Prefix.." "..ply:Nick()..": ",
        unpack(parts)
    )

end)