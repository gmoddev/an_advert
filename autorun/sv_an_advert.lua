--[[
Not_Lowest
Delinquent Studios LLC
]]

if not SERVER then
    return
end
AddCSLuaFile("an_advert_config.lua")
AddCSLuaFile("autorun/an_advert_cl.lua")

include("an_advert_config.lua")

util.AddNetworkString("AdvertMessage")

--// ConVars
local cvCooldown = CreateConVar(
    "an_advert_cooldown",
    tostring(ANAdvert.Config.AdvertCooldown),
    FCVAR_ARCHIVE,
    "Seconds between adverts"
)

local cvSpamLimit = CreateConVar(
    "an_advert_spamlimit",
    tostring(ANAdvert.Config.SpamLimit),
    FCVAR_ARCHIVE,
    "Attempts before advert mute"
)

local cvSpamMute = CreateConVar(
    "an_advert_spammute",
    tostring(ANAdvert.Config.SpamMuteTime),
    FCVAR_ARCHIVE,
    "Mute duration for advert spam"
)

local cvAdvertCost = CreateConVar(
    "an_advert_cost",
    tostring(ANAdvert.Config.AdvertCost or 0),
    FCVAR_ARCHIVE,
    "Cost to send an advert"
)

local cvCommandName = CreateConVar(
    "an_advert_command",
    tostring(ANAdvert.Config.Command_Name or "advert"),
    FCVAR_ARCHIVE,
    "Advert command name"
)

local LastAdvert = {}
local SpamCounter = {}
local MutedUntil = {}

local function GetCommand()
    return "/" .. string.lower(cvCommandName:GetString())
end

hook.Add("PlayerSay","ANAdvertCommand",function(ply,text)

    local lower = string.lower(text)
    local command = GetCommand()

    if not string.StartWith(lower, command) then return end

    -- Extract message properly
    local msg = string.Trim(string.sub(text, #command + 1))

    if msg == "" then
        ply:ChatPrint("Usage: "..command.." <message>")
        return ""
    end

    local steamid = ply:SteamID()
    local now = CurTime()

    local AdvertCooldown = cvCooldown:GetFloat()
    local SpamLimit = cvSpamLimit:GetInt()
    local SpamMuteTime = cvSpamMute:GetFloat()
    local AdvertCost = cvAdvertCost:GetInt()

    -- Muted check
    if MutedUntil[steamid] and MutedUntil[steamid] > now then
        ply:ChatPrint("You are temporarily muted from adverts.")
        return ""
    end

    -- Cooldown
    if not (ANAdvert.Config.AdminBypass and ply:IsAdmin()) then

        local last = LastAdvert[steamid] or 0
        local remaining = AdvertCooldown - (now - last)

        if remaining > 0 then

            SpamCounter[steamid] = (SpamCounter[steamid] or 0) + 1

            ply:ChatPrint(
                "Please wait "..math.ceil(remaining)..
                " seconds before advertising again."
            )

            if SpamCounter[steamid] >= SpamLimit then

                MutedUntil[steamid] = now + SpamMuteTime
                SpamCounter[steamid] = 0

                ply:ChatPrint(
                    "You have been muted from adverts for spamming."
                )

            end

            return ""
        end

    end

    -- Cost check
    if AdvertCost > 0 and ply.getDarkRPVar then

        local money = ply:getDarkRPVar("money") or 0

        if money < AdvertCost then
            ply:ChatPrint("You need $"..AdvertCost.." to send an advert.")
            return ""
        end

        ply:addMoney(-AdvertCost)

    end

    SpamCounter[steamid] = 0
    LastAdvert[steamid] = now

    net.Start("AdvertMessage")
        net.WriteEntity(ply)
        net.WriteString(msg)
    net.Broadcast()

    return ""

end)
