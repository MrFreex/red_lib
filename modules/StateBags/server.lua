local Events = Common("Events")

local Bags = {
    Player = {},
    Entity = {}
}

local Bag = class {
    _Init = function(self, id, t)
        self.__type = t
        self.state = {}
        self.state.set = function(me, k, v)
            me[k] = v
            checkForCallbacks(self, k, v)
            Events.TriggerClient("syncBag", -1, { self, k, v, 0 })
        end

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

Events.Register("requestBags", function()
    Events.TriggerClient("initialSync", source, { Bags })
end)

Events.Register("syncBag", function(bag, k, v)
    checkForCallbacks(bag, k, v)
    getBag(type(bag), bag.id).state[k] = v
    Events.TriggerClient("syncBag", -1, { bag, k, v, source })
end)