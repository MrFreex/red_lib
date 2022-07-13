BagsCallback = {}

exports("HookBag", function(bagType, id, k, cb)
    if not bagType then return end

    local hookId
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
        return { bagType, "global", #BagsCallback[bagType].global }
    end

    local ref = BagsCallback[bagType].bags[id]

    if _TYPE(k) == "string" then
        ref.indexes[k] = ref.indexes[k] or {}
        table.insert(ref.indexes[k], {cb,res})
        return { bagType, "bags", id, "indexes", k, #ref.indexes[k] }
    else
        table.insert(ref.global, {cb,res})
        return { bagType, "bags", id, "global", #ref.global }
    end
end)

exports("UnHookBag", function(hookId))

local function callThem(stateIndex, newValue, object, table)
    for k,v in pairs(table) do print(k, v[1], v[2]) end
    for k,v in pairs(table) do
        v[1](stateIndex,newValue,object)
    end
end

local function cleanup(tab, res)
    
    local toRem = {}

    for k,e in pairs(tab) do
        print(e[2], res)
        if e[2] == res then
            table.insert(toRem,k)
        end
    end

    for i=1,#toRem do
        table.remove(tab, toRem[i])
    end
end

AddEventHandler("onResourceStop", function(res)
    print("[RED] Cleaning Statebags for ", res)
    for k,e in pairs(BagsCallback) do
        cleanup(e.global,res)
        for i,v in pairs(e.bags) do
            cleanup(v.global,res)
            for j,w in pairs(v.indexes) do
                cleanup(w, res)
            end
        end
    end
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