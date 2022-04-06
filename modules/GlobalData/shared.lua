local Cache = {}

exports("GetData", function(index)
    if Cache[index] then return Cache[index] end

    local l = LoadResourceFile(GetCurrentResourceName(), "Data/" .. index .. ".lua")

    local data = load("return {" .. l .. "}")()

    Cache[index] = data

    return data
end)