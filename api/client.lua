local Events = Common("Events")

Events.Register("is-dev", function()
    _G.isDev = true
end, "red_lib")

Data = {}
Data.Synced = {}
Data.Hooks  = {}

local last_hook = 0



local getPath = function(t) -- Returns a list of indexes needed to reach the table t in a shared_table
    local parents = {}
    local f = t

    table.insert(parents, t)
    while
        pcall(function() 

            if type(f) == "shared_table" then -- Reached main table's id
                return error("break") 
            end  

            local v = f() -- Call the metatable __call method to get the parent
            table.insert(parents,v) 
        end) 
    do
        f = parents[#parents]
    end

    local indexes = {}

    for i=(#parents-1), 1, -1 do
        local n = parents[i + 1]
        
        for k,e in pairs(n) do
            if e == parents[i] then
                table.insert(indexes,k)
                break
            end
        end
    end

    
    
    return indexes, f
end

function setMeta(tab, parent)
    local proxy_table = {
        __original = tab
    }
    
    return setmetatable(proxy_table, {
        
        __newindex = function(t, index, value)
            if type(value) == "table" then                
                return rawset(tab, index, setMeta(value, t))
            end

            local old_v = rawget(tab,index)

            
            rawset(tab,index,value)
            
            local indexes, topmost
            if t() ~= nil then
                indexes, topmost = getPath(t)
                table.insert(indexes, index)
            else indexes = { index } topmost = t end
            
            local ind_string = encodeIndexes(indexes)
            for k,e in pairs(Data.Hooks) do
                if (e.index and ((#indexes == 1 and indexes[1] == e.index) or ind_string:find(e.index) == 1)) or not e.index then
                    e.cb(ind_string, value, old_v)
                end
            end

            Events.TriggerServer("sync-shared-table", { topmost.__id, indexes, value })
        end,

        __call = function()
            return parent or id
        end,

        __len = function()
            local n = {}

            for k,e in pairs(tab) do
                if k:find("__") ~= 1 then
                    n[k] = e
                end 
            end

            return n
        end
    })
end

Events.Register("new-shared-table", function(shared_table, id, restricted)
    Data.Synced[id] = setMeta(shared_table)
end)

function Data.Hook(cb, id, index)
    last_hook = last_hook + 1

    Data.Hooks[tostring(last_hook)] = {
        cb = cb,
        id = id,
        index = (index ~= nil and type(index) ~= "string") and encodeIndexes(index) or index
    }
    
    return tostring(last_hook)
end

Events.Register("sync-shared-table", function(id, indexes, value)
    local t = Data.Synced[id].__original
    
    if not t then return end -- Probably waiting for sync-all-tables to occur

    local i

    for i=1, (#indexes-1) do
        if not t[indexes[i]] then
            rawset(t, indexes[i], {})
        end
        t = t[indexes[i]]
    end

    local old_v = rawget(t,indexes[#indexes])

    rawset(t, indexes[#indexes], value)

    local ind_string = encodeIndexes(indexes)

    
    for k,e in pairs(Data.Hooks) do
        if (e.index and ((#indexes == 1 and indexes[1] == e.index) or ind_string:find(e.index) == 1)) or not e.index then
            e.cb(ind_string, value, old_v)
        end
    end
    
end)

Events.Register("sync-all-tables", function(s_tables)
    debugPrint("Syncing all tables")
    Data.Synced = s_tables
end)

CreateThread(function()
    Events.TriggerServer("client-ready", {})
end)

-- * Callbacks

Callbacks = {}

local clock_multip = 0

function Callbacks.Trigger(name, cb, ...)
    -- ! System thought to allow multiple sync executed events
    local timer = (GetGameTimer() * 10) + clock_multip
    clock_multip = clock_multip + 1
    SetTimeout(1, function() clock_multip = 0 end)
    
    local ev_handle
    ev_handle = Events.Register("callbacks::" .. name .. "::" .. timer, function(...)
        cb(...)
        RemoveEventHandler(ev_handle)
    end)
    
    local args = table.pack(...)
    
    Events.TriggerServer("callbacks::" .. name, { timer, args })
end