local Events = Common("Events")
local Arrays = Common("Arrays")



-- Dev Stuff

Dev = {}

--[[
    Used to know wheter a player is marked as developer or not
--]]
function Dev.is(who)
    local identifiers = exports["red_lib"]:Identifiers(who)
    for k,e in pairs(Config.debug.identifiers) do
        local id_type = string.split(e, ":", true)

        if identifiers[id_type] == e:gsub(id_type .. ":", "") then
            return true
        end
    end

    return false
end

--[[
    Registers Dev-only commands, for testing purposes
--]]
function Dev.RegisterCommand(command_name, callback)
    return RegisterCommand(command_name, function(pid, args, r)
        if pid == 0 or Dev.is(pid) then
            callback(pid,args,r)
        end
    end)
end

--

local last_hook = 0

Data = {}
Data.Synced = {}
Data.Hooks  = {}

Events.Register("client-ready", function()
    
    Events.TriggerClient("sync-all-tables", source, { Data.Synced })
end)

local callHooks = function(indexes, id, value)
    local ind_string = encodeIndexes(indexes)
    
    for k,e in pairs(Data.Hooks) do
        if e.id == id and ((e.index and ((#indexes == 1 and indexes[1] == e.index) or ind_string:find(e.index) == 1)) or not e.index) then
            e.cb(ind_string, value)
        end
    end
end

Events.Register("sync-shared-table", function(id, indexes, value)
    local pid = source

    local t = Data.Synced[id].__original

    if (not t) or t.__restricted then return end

    for i=1, (#indexes-1) do
        if not t[indexes[i]] then
            t[indexes[i]] = {}
        end
        t = t[indexes[i]]
    end

    local old_v = rawget(t.__original, indexes[#indexes])

    rawset(t.__original, indexes[#indexes], value)

    callHooks(indexes, id, value, old_v)

    Events.TriggerClient("sync-shared-table", "except:" .. pid, { id, indexes, value })
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

function Data.Sync(shared_table, id, restricted)
    if id and Data.Synced[id] then
        return Data.Synced[id]
    end
    if restricted == nil then restricted = false end

    shared_table.__type = "shared_table"
    shared_table.__id = id
    shared_table.__restricted = restricted

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
            
            for k,e in pairs(n.__original) do
                if e == parents[i] then
                    table.insert(indexes,k)
                    break
                end
            end
        end

        
        
        return indexes
    end

    

    local setMeta
    setMeta = function(tab, parent)
        local proxy_t = {
            __original = tab
        }

        return setmetatable(proxy_t, {

            __index = function(t, k)
                return rawget(tab,k)
            end,
            
            __newindex = function(t, index, value)
                if type(value) == "table" then
                    local ass = setMeta(value, t)
                    return rawset(tab, index, ass)
                end

                local old_v = rawget(t, index)
                rawset(tab,index,value)

                local indexes
                if t() ~= nil then
                    indexes = getPath(t)
                    table.insert(indexes, index)
                else indexes = { index } end
                
                Events.TriggerClient("sync-shared-table", -1, { id, indexes, value })
                callHooks(indexes, id, value, old_v)

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
    
    shared_table = setMeta(shared_table)

    Data.Synced[id] = shared_table
    Events.TriggerClient("new-shared-table", -1, { shared_table.__original, id, restricted })

    return shared_table
end

Dev.RegisterCommand("test", function(p,args)
    if args[1] == "st" then
        local calls = Data.Sync({}, "calls")
        Data.Hook(function(...) print("Hook", ...)  end, "calls", { "a","c" })
        SetTimeout(1000, function()
            calls.a = {}
            calls.a.b = {}
            calls.a.b.c = "a"
            calls.a.b.c = "b"
        end)
    end
end)

-- * Callbacks

Callbacks = {}

function Callbacks.Register(name, handler, is_async)
    Events.Register("callbacks::".. name, function(caller_id, args)
        local client = source

        local ret = table.pack(handler(table.unpack(args, 1, args.n)))

        if is_async then -- ? Is handler returning a promise?
            ret = table.pack(Citizen.Await(ret[1])) -- ! Wait for it to be solved
        end

        Events.TriggerClient("callbacks::" .. name .. "::" .. caller_id, client, ret)
    end)
end

Callbacks.Register("test_cb", function(clp1, clp2, clp3)
    return (clp1+clp2+clp3), "sum"
end)