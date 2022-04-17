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
    RegisterCommand("fixWeapons", function(p,a,r)
        local Weapons = exports["red_lib"]:GetData("weapons") -- Heavy File
        for k,e in pairs(Weapons) do
            if GetHashKey(e.HashKey) ~= k then
                Weapons[GetHashKey(e.HashKey)] = Weapons[k]
                Weapons[k] = nil
            end
        end

        SaveResourceFile(GetCurrentResourceName(), "Data/weapons.lua", json.encode(Weapons), -1)
    end, true)
end