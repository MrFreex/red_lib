local Events = Common("Events")

local Bags = {
    Player = {},
    Entity = {}
}

local Bag = class {
    _Init = function(self, id, t)
        self.__type = t
        self.state = {}
        setmetatable(self.state, {
            __call = function(me, k, v)
                me[k] = v
                Events.TriggerClient("syncBag", -1, { self, k, v, 0 })
            end,

            set = self.state.__call
        })
        self.id = id
    end
}

function getBag(t, id)
    if not Bags[t][id] then
        Bags[t][id] = Bag({}, id, t)
    end

    return Bags[t][id]
end

exports("Bags", function()
    return getBag
end)

Events.Register("syncBag", function(bag, k, v)
    getBag(type(bag), bag.id).state[k] = v
    Events.TriggerClient("syncBag", -1, { bag, k, v, source })
end)