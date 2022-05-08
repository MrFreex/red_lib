local addons = {}

local Utils = Common("Utils")
local Arrays = Common("Arrays")

function Addon(name)
    return addons[name]
end

addons.Jobs = {}

local policeJobs = { "police", "sheriffP", "sheriffS" }

addons.Jobs.isPolice = function(job)
    return Utils.find(policeJobs, job)
end

local function getId(source, name)
    local ids = GetPlayerIdentifiers(source) or {}

    for i,v in pairs(ids) do
        if v:find(name .. ":") then
            return v
        end
    end

    return false
end

addons.Identifiers = {
    get = function(s, idname, opt)
        local id = getId(idname)

        return (id and opt) and addons.Identifiers.optimise(id) or id
    end,

    optimise = function(s, idname, ncomplete)
        if tonumber(s) then
            s = addons.Identifiers.get(s,idname)
        else
            ncomplete = idname
        end

        local find = s:find(":")

        if ncomplete then 
            return s:sub(1, find) 
        end

        local f = s:find("110000")

        if s:find("steam:") then
            return s:gsub("steam:110000","")
        elseif f == 1 then
            return s:gsub("110000", "")
        end
    end
}

addons.Permissions = {}



local Permissions = addons.Permissions

Permissions.Groups = {}

setmetatable(Permissions, {
    __call = function(self, gname)
        if gname then
            return self.Groups[gname]
        end
    end
})

function Permissions:addGroup(groupName, permissions, inherit)
    self.Groups[groupName] = {
        permissions = permissions,
        name = groupName,
        inherit = inherit,
        users = {}
    }
end

function Permissions:hasPermission(group, permission)
    local g = self.Groups[group]

    if not g then return false end
    if Arrays.find(g.permissions, permission) then return true end

    if g.inherit then
        return Permissions:hasPermission(g.inherit, permission)
    end

    return false
end

function Permissions:isOfGroup(user, group)
    local g = self(group)

    if tonumber(user) then
        user = addons.Identifiers.get(user, "license", true)
    end

    if not g then return false end

    return Arrays.find(g.users, user)
end

if onLoad then
    onLoad()
end