local Interactions = {}
exports("Interactions", function()
    return Interactions
end)

local interactions = {
    active = {},
    drawn = {},
    hidden = {}
}

local showHidden = false

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
        local t = interactions.drawn[cat] or interactions.hidden[cat]
        t.cb(data.id)
        if (t.options.close) then
            SetNuiFocus(false, false)
        end
        cb("{}")
    end)
end)

local function parsePos(int)
    local pos
    local avoidOffset = false
    if type(int.where) == "vector3" then 
        pos = int.where
    elseif type(int.where) == "number" then
        pos = GetEntityCoords(int.where)
        if int.options.offset then
            int.options.offset = GetOffsetFromEntityInWorldCoords(int.where, int.options.offset.x, int.options.offset.y, int.options.offset.z)
        end
    elseif type(int.where) == "table" then
        pos = GetWorldPositionOfEntityBone(int.where.entity, int.where.bone)
        if int.options.offset then
            pos = GetOffsetFromEntityGivenWorldCoords(int.where.entity, pos)
            pos = GetOffsetFromEntityInWorldCoords(int.where.entity, pos + int.options.offset)
            avoidOffset = true
        end
    elseif type(int.where) == "string" then
        pos = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), Config.interactions.distance, GetHashKey(int.where), false, false, false)
    end

    return (int.options.offset and not avoidOffset) and (pos + int.options.offset) or pos
end

function cleanFrom(t)
    for k, int in pairs(t) do
        local pos = parsePos(int)

        if type(pos) == "vector3" then
            if #(pos - GetEntityCoords(PlayerPedId())) > Config.interactions.distance then
                t[k] = nil
                interactions.active[k] = int
            end
        end


    end
end

-- To optimize
CreateThread(function()
    while true do
        if not next(interactions.drawn) and not next(interactions.hidden) then
            Wait(2000)
        end

        for k, int in pairs(interactions.active) do
            local pos = parsePos(int)
            if type(pos) == "vector3" then
                if #(pos - GetEntityCoords(PlayerPedId())) < Config.interactions.distance then
                    interactions.active[k] = nil

                    if int.options.hidden then
                        interactions.hidden[k] = int
                    else
                        interactions.drawn[k] = int
                    end
                end
            end
        end

        cleanFrom(interactions.hidden)
        cleanFrom(interactions.drawn)

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

local function push(tab, ints)
    
    for k,e in pairs(tab) do
        table.insert(ints, {
            id = e.id,
            inside = e:subToWeb(),
            close = e.options.close
        })
    end
end

local function makeWebReady()
    local ints = {}

    push(interactions.drawn, ints)

    if showHidden then
        push(interactions.hidden, ints)
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

local function genPosFor(t,positions)
    for k, int in pairs(t) do
        local p = parsePos(int)
        local visible,x,y = GetScreenCoordFromWorldCoord(p.x, p.y, p.z)
        if visible then
            
            positions[k] = relToPX(x,y)
        end
    end
end

local function genPositions()
    local positions = {}
    genPosFor(interactions.drawn,positions)

    if showHidden then
        genPosFor(interactions.hidden,positions)
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
    options = options or {}
    options.resource = GetInvokingResource()
    interactions.active[id] = Interaction({}, id, where, subints, func, options)
end

function Interactions.Delete(id)
    interactions.active[id] = nil
    interactions.drawn[id] = nil
end

RegisterCommand("cInt", function(p,a,r)
    Interactions.Create("test", PlayerPedId(), {
        Interactions.SubInt("test2", "test", "faCar")
    }, function()
        print("test")
    end, { close = true })
end)

RegisterCommand("cInt2", function(p,a,r)
    Interactions.Create("test", vector3(-771.4241, 5594.5273, 33.4857), {
        Interactions.SubInt("test2", "test", "faCar"),
        Interactions.SubInt("test3", "test", "faCar"),
        Interactions.SubInt("test4", "test", "faCar")
    }, function()
        print("test")
    end, { close = true })
end)

RegisterCommand("+openInt", function()
    showHidden = true
    UI.toggle(true)
end)

RegisterCommand("-openInt", function()
    showHidden = false
    UI.toggle(false)
    SendNUIMessage({
        manager = "closeActive"
    })
end)

RegisterKeyMapping("+openInt", "Interaction Menu", "keyboard", "LMENU")

AddEventHandler("onResourceStop", function(res)
    function iter(t)
        for k,e in pairs(t) do
            print(k,e, e.options.resource)
            if e.options.resource == res then
                t[k] = nil
            end
        end
    end

    iter(interactions.active)
    iter(interactions.drawn)
end)