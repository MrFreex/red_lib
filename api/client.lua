local Events = Common("Events")

Events.Register("is-dev", function()
    _G.isDev = true
end, "red_lib")

Data = {}

Data.Synced = {}

Events.Register("new-shared-table", function(shared_table, id, restricted)
    Data.Synced[id] = shared_table
end, true)

Events.Register("sync-shared-table", function(id, indexes, value)
    local t = Data.Synced[id]  

    if not t then return end -- Probably waiting for sync-all-tables to occur

    for i=1, (#indexes-1) do
        t = t[indexes[i]]
    end

    t[indexes[#indexes]] = value
end, true)

Events.Register("sync-all-tables", function(s_tables)
    debug("Syncing all tables")
    Data.Synced = s_tables
end)

CreateThread(function()
    Events.TriggerServer("client-ready", {})
end)