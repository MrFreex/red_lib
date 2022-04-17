FAPI = {}
local common = {}
local Events = {}

function Common(name)
    return common[name]
end

local function repName(name, resname)
    return ((resname) and string.format("%s:%s", resname, name) or string.format("%s:%s",GetCurrentResourceName(), name))
end

--[[
    Triggers an event with the given name and arguments. Automatically prepends the resource name to the event name.
]]
Events.Trigger = function(name, params, resname)
    name = repName(name, resname)

    return TriggerEvent(name, table.unpack(params))
end


if IsDuplicityVersion() then

    --[[
        Triggers an event on the client with the given name and arguments. Automatically prepends the resource name to the event name.
    ]]
    Events.TriggerClient = function (name, source, params, resname)
        name = repName(name, resname)

        return TriggerClientEvent(name, source, table.unpack(params))
    end
else

    --[[
        Triggers an event on the server with the specified name and parameters. Automatically joining, if present, the resource name.
    ]]--
    Events.TriggerServer = function(name, params, resname)
        name = repName(name, resname)

        return TriggerServerEvent(name, table.unpack(params))
    end
end

--[[
    Registers a net event with the specified name. Automatically joining, if present, the resource name.
]]
Events.Register = function(name, callback, resname)
    name = repName(name, resname)

    return RegisterNetEvent(name, callback)
end

common.Events = Events

common.Utils = {}

common.Utils.Characters = {
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'
}

common.Utils.randomString = function(length, customValues)
    local values = customValues or common.Utils.Characters
    local str = ''

    for i = 1, length do
        str = str .. values[math.random(1, #values)]
    end

    return str
end

common.Utils.find = function(t, v)
    for _,e in pairs(t) do
        if e == v then
            return true
        end
    end

    return false
end

common.Arrays = {}

common.Arrays.find = function(self, v)
    for k,e in pairs(self) do
        if v == e then return k end
    end

    return false
end

common.Bones = {

}

common.Bones.Ped = exports["red_lib"]:GetData("pedBones")

common.Weapons = {}

local Weapons 

Citizen.CreateThreadNow(function()
    Weapons = exports["red_lib"]:GetData("weapons") -- Heavy File
    common.Weapons.Data = Weapons
end)

common.Weapons.Types = {
    ["rifle"] = { "GROUP_MG", "GROUP_RIFLE", "GROUP_SHOTGUN", "GROUP_SNIPER"},
    ["pistol"] = { "GROUP_PISTOL" },
    ["melee"] = { "GROUP_MELEE" },
    ["heavy"] = { "GROUP_HEAVY" },
    ["sniper"] = { "GROUP_SNIPER" },
    ["shotgun"] = { "GROUP_SHOTGUN" },
    ["thrown"] = { "GROUP_THROWN" },
    ["smg"] = { "GROUP_SMG" }
}

common.Weapons.isOfGroup = function(weapon, type)
    local hash = GetHashKey(weapon)

    return GetWeapontypeGroup(hash) == GetHashKey(type)
end

common.Weapons.isOfType = function(weapon, type)
    local t = common.Weapons.Types[type]
    if not t then return false end

    for _,e in pairs(t) do
        if common.Weapons.isOfGroup(weapon, e) then
            return true
        end
    end
    
    return false
end

common.Weapons.getType = function(weapon)
    local hash = GetHashKey(weapon)
    for k,v in pairs(common.Weapons.Types) do
        for _,e in pairs(v) do
            if GetWeapontypeGroup(hash) == GetHashKey(e) then
                return k
            end
        end
    end

    return false
end

local weaModels = exports["red_lib"]:GetData("weaponMin")

common.Weapons.getGameModel = function(model)
    return weaModels[string.upper(model)]
end

common.Jobs = {}

local JobData = exports["red_lib"]:GetData("jobs")

local policeJobs = JobData.PoliceJobs

if IsDuplicityVersion() then
    common.Jobs.count = function(job)
        local count = 0
        for k,e in pairs(ESX.GetPlayers()) do
            if ESX.GetPlayerFromId(e).job.name == job then
                count = count + 1
            end
        end

        return count
    end

    common.Jobs.countLEA = function()
        local c = 0
        
        for _,e in pairs(policeJobs) do
            c = c + common.Jobs.count(e)
        end

        return c
    end
end

common.Jobs.isPolice = function(job)
    return common.Utils.find(policeJobs, job)
end

local emergency = JobData.Emergency

common.Jobs.isEmergency = function(job)
    return common.Arrays.find(policeJobs, job) or common.Arrays.find(emergency, job)
end