local Cache = {}


function GetData(index)
    if Cache[index] then return Cache[index] end

    local l = LoadResourceFile(GetCurrentResourceName(), "Data/" .. index .. ".lua")
    local chunk = load("return " .. l)
    if l:find("{") ~= 1 or not pcall(chunk) then
        return nil
    end

    local data = chunk()

    Cache[index] = data

    return data
end

exports("GetData", GetData)

exports("SetCache", function(c)
    for k,e in pairs(c) do
        if not Cache[k] then
            Cache[k] = e
        end
    end

    return GetData
end)


local Events = Common("Events")
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


