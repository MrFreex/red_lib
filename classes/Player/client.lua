local __indexes = {
    ["ped"] = function(self)
        return self:getPed()
    end,

    ["vehicle"] = function(self)
        return self:getVehicle()
    end
}

Player = class {
    _Init = function(serverId)
        if not serverId then serverId = GetPlayerServerId(PlayerId()) end

        self.serverId = serverId
        self.pid = GetPlayerFromServerId(serverId)
    end,

    __index =  function(self, k)
        if __indexes[k] then
            return __indexes[k](self)
        end

        return rawget(self,k)
    end,

    getPed = function(self)
        return GetPlayerPed(self.pid)
    end,

    getVehicle = function(self, atGetIn)
        return GetVehiclePedIsIn(self.ped, atGetIn and false or atGetIn)
    end
}

ThisPlayer = Player()