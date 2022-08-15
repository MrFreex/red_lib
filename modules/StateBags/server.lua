local Events = Common("Events")

local Bags = {
    Player = {},
    Entity = {},
    Global = {}
}

AddEventHandler("updateBagIndex", function(b_type,b_id,index,value)
    if Bags[b_type] and Bags[b_type][b_id] then
        rawset(Bags[b_type][b_id], index, value)
    end
end)

exports("cleanBag", function(bag_type, bag_id)
    if not bag_id then bag_id = bag_type bag_type = "Global" end

    local exists = Bags[bag_type] and Bags[bag_type][bag_id]
    if exists then 
        Bags[bag_type][bag_id] = nil 
        Events.TriggerClient("deleteBag", -1, { bag_type, bag_id })
    end

    return exists
end)

exports("cleanBagIfHas", function(bag_type, key)
    local exists = Bags[bag_type]

    for k,e in pairs(exists) do
        if e.state[key] then
            e.state:set(key,nil)
        end
    end
end)

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

CreateThread(function()
    Bags.Global[1] = Bag({}, 1, "Global")
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

Events.Register("requestBags", function()
    Events.TriggerClient("initialSync", source, { Bags })
end)

Events.Register("syncBag", function(bag, k, v)
    checkForCallbacks(bag, k, v)
    getBag(type(bag), bag.id).state[k] = v
    Events.TriggerClient("syncBag", -1, { bag, k, v, source })
end)