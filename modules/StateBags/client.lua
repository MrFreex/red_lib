local Events = Common("Events")

local Bags = {
    Player = {},
    Entity = {},
    Global = {}
}


local Sync = {
    server = function(bag, index, newv)
        Events.TriggerServer("syncBag", { bag,index,newv })
    end,

    me = function(bag, k, v, request)
        if request == GetPlayerServerId(PlayerId()) then return end
        if not Bags[type(bag)][bag.id] then
            Bags[type(bag)][bag.id] = getBag(type(bag), bag.id)
        end
        Bags?[type(bag)][bag.id]?.state[k] = v
    end
}

Events.Register("syncBag", Sync.me)

local Bag = class {
    _Init = function(self, id, t)
        self.__type = t
        self.state = {}
        setmetatable(self.state, {
            __call = function(me, k, v)
                me[k] = v
                Sync.server(self, k, v)
            end
        })

        self.state.set = function(me, k, v)
            self.state[k] = v
            Sync.server(self, k, v)
        end

        self.id = id
    end
}

CreateThread(function()
    Bags.Global[1] = Bag({}, "Global", 1)
end)


function getBag(t, id)
    if t == nil and id == nil then
        return Bags.Global[1]
    end

    if not Bags[t][id] then
        Bags[t][id] = Bag({}, id, t)
    end

    return Bags[t][id]
end

exports("Bags", function()
    return getBag
end)