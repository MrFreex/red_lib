Data = {}

local Events = Common("Events")
local Arrays = Common("Arrays")

Data.Synced = {}

Events.Register("client-ready", function()
    
    Events.TriggerClient("sync-all-tables", source, { Data.Synced })
end)

function Data.Sync(shared_table, id, restricted)
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
            
            for k,e in pairs(n) do
                if e == parents[i] then
                    table.insert(indexes,k)
                    break
                end
            end
        end

        Events.TriggerClient("new-shared-table", -1, { shared_table, id, restricted })
        
        return indexes
    end

    local setMeta
    setMeta = function(tab, parent)

        return setmetatable(tab, {
            
            __newindex = function(t, index, value)
                if type(value) == "table" then
                    setMeta(value, t)
                    return rawset(t, index, value)
                end

                rawset(t,index,value)
                
                if t() ~= nil then
                    local indexes = getPath(t)
                    table.insert(indexes, index)

                    Events.TriggerClient("sync-shared-table", -1, { id, indexes, value })
                end


            end,

            __call = function()
                return parent or id
            end
        })
    end
    
    setMeta(shared_table)

    Data.Synced[id] = shared_table

    return shared_table
end

local t = Data.Sync({}, "patrols")

t.table1 = {}

t.table1.a = {}
t.table1.a.b = {}
t.table1.a.b.c = {}
t.table1.a.b.c.d = "A"