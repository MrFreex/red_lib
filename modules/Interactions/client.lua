local Interactions = {}
exports("Interactions", Interactions)

local interactions = {
    active = {}
}

local Utils = Common("Utils")
local Arrays = Common("Arrays")
local UI = Modules.UI

CreateThread(function()
    while true do
        if #interactions.active == 0 then
            Wait(2000)
        end

        for i=1, #interactions.active do
            local int = interactions.active[i]

            local pos

            if type(int.where) == "vector3" then 
                pos = int.where
            elseif type(int.where) == "number" then
                pos = GetEntityCoords(int.where)
            elseif type(int.where) == "table" then
                pos = GetWorldPositionOfEntityBone(int.where.entity, int.where.bone)
            elseif type(int.where) == "string" then
                pos = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), Config.interactions.distance, GetHashKey(int.where), false, false, false)
            end

            if type(pos) == "vector3" then
                if #(pos - GetEntityCoords(PlayerPedId())) < Config.interactions.distance then
                    -- Continue here
                end
            end
        end

        Wait(0)
    end
end)

local SubInt = class {
    __type = "RedInts:SubInt",
    __len = function(self)
        return self.id
    end,
    _Init = function(self, id, label, icon)
        self.id = id
        self.label = label
        self.icon = icon
    end
}

local Interaction = class {
    __type = "RedInts:Interaction",
    __len = function(self)
        return self.id
    end,
    _Init = function(self, id, where, subints, callback)
        self.id = id
        self.where = where
        self.sub = subints
        self.cb = callback
    end
}

function Interactions.SubInt(id, label, icon)
    return SubInt(self, id, label, icon)
end

function Interactions.Update()
    SendNUIMessage({
        manager = "interactions",
        interactions = Arrays.toArray(interactions.active)
    })
end

function Interactions.Create(id, where, subints, func)
    interactions.active[id] = Interaction({}, id, where, subints, func)
end