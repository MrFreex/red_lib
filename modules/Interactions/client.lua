local Interactions = {}
exports("Interactions", Interactions)

local interactions = {
    active = {},
    drawn = {}
}



local Utils = Common("Utils")
local Arrays = Common("Arrays")
local UI

CreateThread(function()
    UI = Modules.UI

    UI.onReady(function()
        print("Ready")
        SendNUIMessage({
            manager = "setEnabled",
            what = "Interactions",
            enabled = true
        })

        Wait(1000)

        SendNUIMessage({
            manager = "toggle",
            toggle = true
        })
    end)

    UI.listen("interaction", function(data,cb)
        local cat = data.category
        interactions.drawn[cat].cb(data.id)
        if (interactions.drawn[cat].options.close) then
            SetNuiFocus(false, false)
        end
        cb("{}")
    end)
end)

local function parsePos(int)
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

    return pos
end

CreateThread(function()
    while true do
        if not next(interactions.drawn) then
            Wait(2000)
        end

        for k, int in pairs(interactions.active) do
            local pos = parsePos(int)
            if type(pos) == "vector3" then
                if #(pos - GetEntityCoords(PlayerPedId())) < Config.interactions.distance then
                    interactions.active[k] = nil
                    interactions.drawn[k] = int
                end
            end
        end

        for k, int in pairs(interactions.drawn) do
            local pos = parsePos(int)

            if type(pos) == "vector3" then
                if #(pos - GetEntityCoords(PlayerPedId())) > Config.interactions.distance then
                    interactions.drawn[k] = nil
                    interactions.active[k] = int
                end
            end


        end

        Interactions.Update()

        Wait(15)
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
    end,

    toWeb = function(self)
        return {
            id = self.id,
            label = self.label,
            icon = self.icon
        }
    end
}

local Interaction = class {
    __type = "RedInts:Interaction",
    __len = function(self)
        return self.id
    end,
    _Init = function(self, id, where, subints, callback, options)
        self.id = id
        self.where = where
        self.sub = subints
        self.cb = callback
        self.options = options or {}
    end,

    subToWeb = function(self)
        local sub = {}

        for k,e in pairs(self.sub) do
            table.insert(sub, e:toWeb())
        end
        
        return sub
    end
}

function Interactions.SubInt(id, label, icon)
    return SubInt(self, id, label, icon)
end

local function makeWebReady()
    local ints = {}

    for k,e in pairs(interactions.drawn) do
        table.insert(ints, {
            id = e.id,
            inside = e:subToWeb(),
            close = e.options.close
        })
    end

    return ints
end

function Interactions.Update()
    SendNUIMessage({
        manager = "interactions",
        interactions = makeWebReady()
    })
    Interactions.PosUpdate()
end

local MonitorRes = table.pack(GetActiveScreenResolution())

local function relToPX(x, y)


    x = x * MonitorRes[1]
    y = y * MonitorRes[2]

    return {x,y}
end

local function genPositions()
    local positions = {}
    for k, int in pairs(interactions.drawn) do
        local p = parsePos(int)
        local visible,x,y = GetScreenCoordFromWorldCoord(p.x, p.y, p.z)
        if visible then
            
            positions[k] = relToPX(x,y)
        end
    end

    return positions
end

function Interactions.PosUpdate()
    SendNUIMessage({
        manager = "positions",
        positions = genPositions() 
    })
end

function Interactions.Create(id, where, subints, func, options)
    interactions.active[id] = Interaction({}, id, where, subints, func, options)
end

RegisterCommand("cInt", function(p,a,r)
    Interactions.Create("test", PlayerPedId(), {
        Interactions.SubInt("test2", "test", "faCar")
    }, function()
        print("test")
    end, { close = true })
end)

RegisterCommand("+openInt", function()
    UI.toggle(true)
end)

RegisterCommand("-openInt", function()
    UI.toggle(false)
    SendNUIMessage({
        manager = "closeActive"
    })
end)

RegisterKeyMapping("+openInt", "Interaction Menu", "keyboard", "LMENU")

