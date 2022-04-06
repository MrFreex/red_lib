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
    return common.Utils.find(policeJobs, job) or common.Utils.find(emergency, job)
end