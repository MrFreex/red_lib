local Cache = {}

exports("GetData", function(index)
    if Cache[index] then return Cache[index] end

    local l = LoadResourceFile(GetCurrentResourceName(), "Data/" .. index .. ".lua")
    local chunk = load("return " .. l)

    if not l:find("{") or not pcall(chunk) then
        return nil
    end

    local data = chunk()

    Cache[index] = data

    return data
end)

if IsDuplicityVersion() then
    RegisterCommand("refreshFiles", function(p,a,r)
        Cache = {}
        Events.TriggerClient("clearCache", -1, {})
    end, true)
else
    Events.Register("clearCache", function()
        Cache = {}
    end)
end