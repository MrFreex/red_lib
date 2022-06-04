FAPI = {}
local common = {}
local Events = {}

local Cache = {}

local function __getData(index)
    if Cache[index] then return Cache[index] end

    local l = LoadResourceFile("red_lib", "Data/" .. index .. ".lua")
    if l == nil then return nil end
    local chunk = load("return " .. l)
    if l:find("{") ~= 1 or not pcall(chunk) then
        return nil
    end

    local data = chunk()

    Cache[index] = data

    return data
end

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
    Registers an event with the specified name. Automatically joining, if present, the resource name.
]]
Events.Register = function(name, callback, resname, notNet)
    name = repName(name, resname)

    if notNet then
        return AddEventHandler(name, callback)
    else
        return RegisterNetEvent(name, callback)
    end
end


Events.Register("loaded", function()
    local nf = exports["red_lib"]:SetCache(Cache)
    __getData = nf
end, "red_lib")

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

common.Utils.callAll = function(tab, ...)
    for _,v in pairs(tab) do
        v(...)
    end
end

common.Arrays = {}

common.Arrays.find = function(self, v)
    for k,e in pairs(self) do
        if v == e then return k end
    end

    return false
end

common.Arrays.toArray = function(tab) -- Useful for UI stuff
    local ret = {}
    for k,e in pairs(tab) do
        table.insert(ret,e)
    end

    return ret
end

common.Bones = {

}

common.Bones.Ped = __getData("pedBones")



common.Weapons = {}

local Weapons = __getData("weapons") -- Heavy File 

common.Weapons.Data = Weapons

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

local weaModels = __getData("weaponMin")

local JobData = __getData("jobs")



common.Weapons.getGameModel = function(model)
    return weaModels[string.upper(model)]
end

common.Jobs = {}


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

local Bags = {}

common.StateBags = Bags

Bags.import = function()

    local GetBag = exports["red_lib"]:Bags()

    _G.Player = function(id) return GetBag("Player", id) end
    _G.Entity = function(id) return GetBag("Entity", id) end
    if not IsDuplicityVersion() then
        _G.LocalPlayer = function() return GetBag("Player", GetPlayerServerId(PlayerId())) end
    end

    _G.GlobalState = function() return GetBag() end
end

Bags.Use = function(b)

    local GetBag = exports["red_lib"]:Bags()

    return function(id)
        return GetBag(b, id)
    end
end


local Active = {}

function Do(cb,sleep,after)
    CreateThread(function()
        local tid = GetCurrentThreadId()
        local KillMe = function()
            Active[tid] = false
        end
        Active[tid] = true
        while Active[tid] do
            cb(tid,KillMe)
            Citizen.Wait(sleep or 0)
        end

        after()
    end)
end

function Kill(threadId)
    TerminateThread(threadId)
end