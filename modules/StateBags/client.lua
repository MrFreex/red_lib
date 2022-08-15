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

Events.TriggerServer("requestBags", {})
Events.Register("initialSync", function(sv_bags)
    Bags = sv_bags
end)

Events.Register("deleteBag", function(bag_type,bag_id)
    if Bags[bag_type] and Bags[bag_type][bag_id] then
        Bags[bag_type][bag_id] = nil
    end
end)

local IsControlJustPressed = function(key, cb)
    RegisterCommand("keymap-" .. key, cb, false)
    RegisterKeyMapping("keymap-" .. key, "", "keyboard", key)
end

IsControlJustPressed("F", function()
    local time = GetGameTimer()
    local cveh = GetVehiclePedIsIn(PlayerPedId(),false)

    if cveh ~= 0 then
        entered = 0
        getBag("Player", GetPlayerServerId(PlayerId())).state:set("currentVehicle", 0)
    else
        while GetGameTimer() - time < 3000 do
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                entered = GetVehiclePedIsIn(PlayerPedId(),true)
                return getBag("Player", GetPlayerServerId(PlayerId())).state:set("currentVehicle", entered)
            end
    
            Wait(10)
        end
    end
end)

local Sync = {
    server = function(bag, index, newv)
        checkForCallbacks(bag,index,newv)
        Events.TriggerServer("syncBag", { bag,index,newv })
    end,

    me = function(bag, k, v, request)
        if request == GetPlayerServerId(PlayerId()) then return end
        if not Bags[type(bag)][bag.id] then
            Bags[type(bag)][bag.id] = getBag(type(bag), bag.id, true)
        end
        Bags?[type(bag)][bag.id]?.state[k] = v
        checkForCallbacks(bag,k,v)
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
    Bags.Global[1] = Bag({}, 1, "Global")
end)


function getBag(t, id, avoidConvert)
    if t == nil and id == nil then
        return Bags.Global[1]
    end

    if t == "Entity" and not Bags[t][id] and not avoidConvert then
        id = NetworkGetNetworkIdFromEntity(id)
        NetworkSetNetworkIdDynamic(id, false)
        SetNetworkIdExistsOnAllMachines(id, true)
    end

    if not Bags[t][id] then
        Bags[t][id] = Bag({}, id, t)
    end

    return Bags[t][id]
end

exports("Bags", function()
    return getBag
end)

