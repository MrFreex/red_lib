local Events = Common("Events")

local Bags = {
    Player = {},
    Entity = {},
    Global = {}
}

local BagsCallback = {}

local function callThem(stateIndex, newValue, object, table)
    for k,v in pairs(table) do
        print(k,v)
        v[1](stateIndex,newValue,object)
    end
end

local function cleanup(table, res)
    local toRem = {}

    for k,e in pairs(table) do
        if e[2] == res then
            table.insert(toRem,k)
        end
    end

    for i=1,#toRem do
        table.remove(table, toRem[i])
    end
end

AddEventHandler("onResourceStop", function(res)
    for k,e in pairs(BagsCallback) do
        cleanup(e.global)
        for i,v in pairs(e.bags) do
            cleanup(v.global)
            for j,w in pairs(v.indexes) do
                cleanup(w)
            end
        end
    end
end)

local function checkForCallbacks(object, stateIndex, newValue) -- Checks for Hooks and calls the supplied functions
    if BagsCallback[object.__type] then -- Is there any hook for the bag type?
        local BagsOfType = BagsCallback[object.__type]
        callThem(stateIndex, newValue, object, BagsOfType.global) -- Call the global ones 

        if BagsOfType.bags[object.id] then -- Is there any hook for this bag?
            local ForSingleBag = BagsOfType.bags[object.id]

            callThem(stateIndex, newValue, object, ForSingleBag.global) -- Call the global ones

            if ForSingleBag.indexes[stateIndex] then
                callThem(stateIndex, newValue, object, ForSingleBag.indexes[stateIndex]) -- Call the index-bound callbacks
            end
        end
    end
end


local Sync = {
    server = function(bag, index, newv)
        checkForCallbacks(bag,index,newv)
        Events.TriggerServer("syncBag", { bag,index,newv })
    end,

    me = function(bag, k, v, request)
        if request == GetPlayerServerId(PlayerId()) then return end
        if not Bags[type(bag)][bag.id] then
            Bags[type(bag)][bag.id] = getBag(type(bag), bag.id)
        end
        Bags?[type(bag)][bag.id]?.state[k] = v
    end
}

exports("HookBag", function(bagType, id, k, cb)
    if not bagType then return end

    local res = GetInvokingResource()

    BagsCallback[bagType] = BagsCallback[bagType] or {
        bags = {},
        global = {}
    }

    if not cb then
        if _TYPE(k) ~= "string" then -- Not == "function" cause funcRefs are also tables
            cb = k
        else -- Return cause no callback was supplied
            return false
        end
    end

    if id then
        BagsCallback[bagType].bags[id] = BagsCallback[bagType].bags[id] or {
            global = {},
            indexes = {}
        }
    else
        table.insert(BagsCallback[bagType].global, {cb,res})
        return true
    end

    local ref = BagsCallback[bagType].bags[id]

    if _TYPE(k) == "string" then
        ref.indexes[k] = ref.indexes[k] or {}
        table.insert(ref.indexes[k], {cb,res})
    else
        table.insert(ref.global, {cb,res})
    end

    return true
end)

Events.Register("syncBag", Sync.me)

local Bag = class {
    _Init = function(self, id, t)
        self.__type = t
        self.state = {}
        setmetatable(self.state, {
            __call = function(me, k, v)
                me[k] = v
                Sync.server(self, k, v)
            end
        })

        self.state.set = function(me, k, v)
            self.state[k] = v
            Sync.server(self, k, v)
        end

        self.id = id
    end
}

CreateThread(function()
    Bags.Global[1] = Bag({}, "Global", 1)
end)


function getBag(t, id)
    if t == nil and id == nil then
        return Bags.Global[1]
    end

    if not Bags[t][id] then
        Bags[t][id] = Bag({}, id, t)
    end

    return Bags[t][id]
end

exports("Bags", function()
    return getBag
end)