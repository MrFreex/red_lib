BagsCallback = {}

local lastId = -1

function returnAndIncrement()
    lastId = lastId + 1
    return lastId
end

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
        elseif _TYPE(id) == "table" or _TYPE(id) == "function" then
            cb = id
        else -- Return cause no callback was supplied
            return false
        end
    end
    
    local hookId = returnAndIncrement()
    if id and (_TYPE(id) == "string" or _TYPE(id) == "number") then
        if (not IsDuplicityVersion()) and bagType == "entity" then
            id = NetworkGetNetworkIdFromEntity(id)
        end

        BagsCallback[bagType].bags[id] = BagsCallback[bagType].bags[id] or {
            global = {},
            indexes = {}
        }
    else
        table.insert(BagsCallback[bagType].global, {id,res,hookId})
        return hookId
    end

    local ref = BagsCallback[bagType].bags[id]

    if _TYPE(k) == "string" then
        ref.indexes[k] = ref.indexes[k] or {}
        table.insert(ref.indexes[k], {cb,res,hookId})
        return hookId
    else
        table.insert(ref.global, {cb,res,hookId})
        return hookId
    end
end)



local function callThem(stateIndex, newValue, object, table)
    for k,v in pairs(table) do
        v[1](stateIndex,newValue,object,v[3])
    end
end

local function cleanup(tab, res, index)
    local index = index or 2
    local toRem = {}

    for k,e in pairs(tab) do
        if e[index] == res then
            table.insert(toRem,k)
        end
    end

    for i=1,#toRem do
        table.remove(tab, toRem[i])
    end

    return #toRem > 0
end

--[[
    @param: res, what to search for
    @param: index, the index where @res is located
    @param: qf, quit at first match
]]
local function cleanAll(res,index,qf) -- Cleans all callbacks given a search query
    for k,e in pairs(BagsCallback) do
        if cleanup(e.global,res, index) and qf then return end
        for i,v in pairs(e.bags) do
            if cleanup(v.global,res, index) and qf then return end
            for j,w in pairs(v.indexes) do
                if cleanup(w, res, index) and qf then return end
            end
        end
    end
end

exports("UnHookBag", function(hookId)
    cleanAll(hookId, 3, true)
end)

AddEventHandler("onResourceStop", function(res)
    print("[RED] Cleaning Statebags for ", res)
    cleanAll(res,2)
end)

function checkForCallbacks(object, stateIndex, newValue) -- Checks for Hooks and calls the supplied functions
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