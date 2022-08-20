FAPI = {}
local common = {}
local Events = {}

local Cache = {}

--// Import Classify

local function merge(...)
    local args = ({...})
    local merged = {}

    for i = 1, #args do
        for k,v in pairs(args[i]) do
            merged[k] = v
        end
    end
    return merged
end

function class(obj)
    obj.__type = "uClass"
    
    local class = {
        -- metamethods
        __add = obj.__add or obj._Add or nil,
        __sub = obj.__sub or obj._Sub or nil,
        __mul = obj.__mul or obj._Mul or nil,
        __div = obj.__div or obj._Div or nil,
        __idiv = obj.__idiv or obj._FloorDiv or nil,
        __mod = obj.__mod or obj._Mod or nil,
        __pow = obj.__pow or obj._Pow or nil,
        __unm = obj.__unm or obj._Neg or nil,
        __concat = obj.__concat or obj._Concat or nil,
        __index = obj.__index or obj._Index or nil,
        __len = obj.__len or obj._Len or obj.__len,
        
        __eq = obj.__eq or obj._IsEqual or nil,
        __lt = obj.__lt or obj._IsLessThan or nil,
        __le = obj.__le or obj._IsLessOrEqual or nil,
        
        __band = obj.__band or obj._And or nil,
        __bor = obj.__bor or obj._Or or nil,
        __bxor = obj.__bxor or obj._Xor or nil,
        __bnot = obj.__bnot or obj._Not or nil,
        
        __shl = obj.__shl or obj._LShift or nil,
        __shr = obj.__shr or obj._RShift or nil,
        
        __call = obj.__call or obj._Call or nil,
    }

    return function(...)
        local class = setmetatable(obj, class)

        if class._Init then
            class:_Init(...)
        end

        return class
    end
end

function extend(class, extension)
    if type(class) ~= 'function' then
        error("Cant extend a non uClass object")
    end
    
    return function(options)
        local a = class()
        
        local class = setmetatable(options and merge(options, extension, a) or merge(extension, a), a)

        if class._Init then
            class:_Init()
        end

        return class
    end
end

--// End Classify

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

local o_v3 = vector3

function vector3(x,y,z)
    if type(x) == "vector4" then
        return vector3(x.x, x.y, x.z)
    end

    return o_v3(x,y,z)
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

common.Objects = {}

common.Objects.find = function(t,k,v)
    for i,e in pairs(t) do
        if e[k] == v then
            return i
        end
    end

    return nil
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

local RedStateBags = {}

common.StateBags = RedStateBags

local Bags = {
    Player = {},
    Entity = {},
    Global = {}
}

setmetatable(Bags, {
    __call = function(self, bag_identification)
        return Bags[bag_identification.type][bag_identification.id]
    end
})




Events.Register("sync_bag", function(bag_identification, state_index, state_value) 
    if not Bags(bag_identification) then
        RedStateBags.GetBag(bag_identification.type, bag_identification.id).state[state_index] = state_value
    end
end, "red_statebags")

local GlobalHooks = {}


RedStateBags.UnHook = function(hook_cookie)
    local iterate = function(table)
        for k,e in pairs(table) do
            if e[1] == hook_cookie then
                table[k] = nil
                return true
            end
        end

        return false
    end

    for bag_type,bag_table in pairs(GlobalHooks) do
        if iterate(bag_table) then
            return true
        end
    end

    return false
end


local last_hook_id = -1

local CallHooks = function(hook_table,...)
    local args = {...}
    for _,v in pairs(hook_table) do
        local newTable = { table.unpack(args) }
        table.insert(newTable, v[1])
        v[2](table.unpack(newTable))
    end
end

local BaseBag = class {
    _Init = function(self, bag_type, bag_id)
        self.__type = bag_type
        self.id = bag_id

        self.state = {}

        self.lastHookId = -1
        self.myHooks = {
            global = {},
            indexed = {}
        }

        Events.Register("sync_bag", function(bag_identification, state_index, state_value) 
            if self:equals(bag_identification) then
               self.state[state_index] = state_value
               self:triggerHooks(state_index,state_value)
            end
        end, "red_statebags")

        local setStateFunction = function(me, k, v)
            rawset(me, k, v)
            self:syncState(k, v)
        end

        setmetatable(self.state, {
            __call = setStateFunction,

            __index = function(me, k)
                if k == "set" then
                    return setStateFunction
                end

                return rawget(me, k)
            end
        })
    end,

    triggerHooks = function(self, k, v)
        if GlobalHooks.all then
            CallHooks(GlobalHooks.all, self.__type, self.id, k, v)
        end

        if GlobalHooks[self.__type] then
            CallHooks(GlobalHooks[self.__type], self.id, k, v)
        end

        CallHooks(self.myHooks.global, k, v)

        if self.myHooks.indexed[k] then
            CallHooks(self.myHooks.indexed[k], v)
        end
    end,

    hook = function(self, watch_index, callback)
        if not callback then
            callback = watch_index
            watch_index = nil
        end

        if not callback then return false end

        self.lastHookId = self.lastHookId + 1

        local addToTable

        if watch_index then
            self.myHooks.indexed[watch_index] = self.myHooks.indexed[watch_index] or {}
            addToTable = self.myHooks.indexed[watch_index]
        else
            addToTable = self.myHooks.global
        end
        
        table.insert(addToTable, {self.lastHookId, callback})

        return self.lastHookId
    end,

    unhook = function(self, hook_cookie)
        local iterate = function(table)
            for k,e in pairs(table) do
                if e[1] == hook_cookie then
                    table[k] = nil
                    return true
                end
            end

            return false
        end

        if iterate(self.myHooks.global) then
            return true
        end

        for k,e in pairs(self.myHooks.indexed) do
            if iterate(e) then
                return true
            end
        end

        return false
    end,

    getIdentity = function(self)
        return { id = self.id, type = self.__type }
    end,

    equals = function(self, compare_to)
        local identity = self:getIdentity()
        return identity.id == compare_to.id and identity.type == compare_to.type
    end,

    syncState = function(self, state_index, state_value)
        if IsDuplicityVersion() then
            Events.TriggerClient("sync_bag", -1, { self:getIdentity(), state_index, state_value }, "red_statebags")
        else
            Events.TriggerServer("sync_bag_fc", { self:getIdentity(), state_index, state_value }, "red_statebags")
        end
    end
}

RedStateBags.GetBag = function(bag_type, bag_id)
    if Bags[bag_type][bag_id] then 
        return Bags[bag_type][bag_id]
    end

    Bags[bag_type][bag_id] = Bags[bag_type][bag_id] or BaseBag(bag_type, bag_id)

    return Bags[bag_type][bag_id]
end


RedStateBags.import = function()
    for k,e in pairs(Bags) do
        _G[k] = function(bag_id)
            return RedStateBags.GetBag(k, bag_id)
        end
    end

    if IsDuplicityVersion() then
        _G.ServerState = function()
            return RedStateBags.GetBag("Player", 0)
        end
    else
        _G.LocalPlayer = function()
            return RedStateBags.GetBag("Player", GetPlayerServerId(PlayerId()))
        end

        _G.CurrentVehicle = function()
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then
                return RedStateBags.GetBag("Entity", veh)
            end
        end
    end
    
end

RedStateBags.Hook = function(bag_type, callback)
    if not (bag_type) then return end

    if not callback then 
        callback = bag_type 
        bag_type = "all"
    end

    GlobalHooks[bag_type] = GlobalHooks[bag_type] or {}
    
    last_hook_id = last_hook_id + 1

    table.insert(GlobalHooks[bag_type], {last_hook_id, callback})

    return last_hook_id
end

--[[
RedStateBags.Hook = function(bag_type, bag_id, state_index, callback)
    if not bag_type then return end

    if not callback then
        if state_index then
            callback = state_index
            state_index = nil
        elseif bag_id then
            callback = bag_id
            bag_id = nil
        end
    end

    local ThisHook = Hook(bag_type,bag_id,)
end

]]


common.Strings = {}

common.Strings.split = function(inputstr,sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end

    return t
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