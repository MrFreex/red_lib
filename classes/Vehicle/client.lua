local function create(self, ...)
    self.ent = CreateVehicle(...)
end

local __indexes = {
    ["pos"] = function(self)
        return self:getCoords()
    end,

    ["heading"] = function(self)
        return self:getHeading()
    end,

    ["coords"] = function(self)
        return self:getCoords()
    end,

    ["ent"] = function(self)
        return DoesEntityExist(self.localEnt) and self.localEnt or NetworkGetEntityFromNetworkId(self.net)
    end,

    ["model"] = function(self)
        return self:getModel()
    end
}

Vehicle = class {
    -- Constructor
    _Init = function(self, ent, coords, heading, missionEntity, networked)
        if (type(ent) == "number") then
            if DoesEntityExist(ent) or NetworkDoesEntityExistWithNetworkId(NetworkGetNetworkIdFromEntity(ent)) then
                self.localEnt = ent
            elseif NetworkDoesEntityExistWithNetworkId(ent) then
                self.net = ent
                self.localEnt = NetworkGetEntityFromNetworkId(ent)
                ent = self.ent
            else
                create(self, ent, coords, heading, missionEntity, networked)
            end
        elseif type(ent) == "string" then
            create(self, ent, coords, heading, missionEntity, networked)
        end

        self.Imodel = self.model
        self.Icoords = self.pos
        self.Iheading = self.heading
    end,

    __index = function(self,k)
        if __indexes[k] then return __indexes[k](self) end
    
        return rawget(self,k)
    end,

    getCoords = function(self)
        return GetEntityCoords(self)
    end,

    getHeading = function(self)
        return GetEntityHeading(self)
    end,

    setHeading = function(self, heading)
        SetEntityHeading(self.ent, heading)
    end,
        
    setMissionEntity = function(self, missionEntity)
        SetEntityAsMissionEntity(self.ent, missionEntity, false)
    end,

    hasFreeSeats = function(self)
        return AreAnyVehicleSeatsFree(self.ent)
    end,

    attachToCargobob = function(self, cargobob, pos)
        AttachVehicleToCargobob(self.ent, cargobob or ThisPlayer.vehicle, -1, pos or vector3(0.0,0.0,0.0))
    end,

    attachToTowTruck = function(self, towTruck, offset)
        AttachVehicleToTowTruck(towTruck or ThisPlayer.vehicle, self.ent, offset or vector3(0.0,0.0,0.0))
    end,

    attachToTrailer = function(self, trailer, radius)
        AttachVehicleToTrailer(self.ent, trailer or ThisPlayer.vehicle, radius or 2.0)
    end,

    canShuffleSeat = function(self, seat)
        return CanShuffleSeat(self.ent, seat)
    end,

    clearColor = function(self, secondary)
        local f = secondary and ClearVehicleSecondaryColor or ClearVehiclePrimaryColor

        return f(self.ent)
    end,

    clearRouteHistory = function(self)
        return ClearVehicleRouteHistory(self.ent)
    end,

    canJump = function(self)
        return GetCanVehicleJump(self.ent)
    end,

    hasDriftTires = function(self)
        return GetDriftTyresEnabled(self.ent)
    end,

    getDoorEntryPos = function(self, door)
        return GetEntryPositionOfDoor(self.ent, door or -1)
    end,

    hasRocketBoost = function(self)
        return GetHasRocketBoost(self.ent)
    end,

    hasDoor = function(self, door)
        return GetIsDoorValid(self.ent, door)
    end,

    isEngineRunning = function(self)
        return GetIsVehicleEngineRunning(self)
    end,

    hasCustomColor = function(self, secondary)
        local f = secondary and GetIsVehicleSecondaryColourCustom or GetIsVehiclePrimaryColourCustom

        return f(self.ent)
    end,

    getModel = function(self)
        return GetEntityModel(self.ent)
    end,

    getManufacturer = function(self)
        return GetMakeNameFromVehicleModel(self.model)
    end,

    getDoorsNumber = function(self)
        return GetNumberOfVehicleDoors(self.ent)
    end,

    getPedInSeat = function(self, seat)
        seat = seat or -1

        local ped = GetPedInVehicleSeat(self.ent, seat)
        
        return Ped({}, ped)
    end,

    getPedUsingDoor = function(self, door)
        door = door or -1

        local ped = GetPedUsingVehicleDoor(self.ent, door)
        
        return Ped({}, ped)
    end,

    delete = function(self)
        return DeleteVehicle(self.ent)
    end,

    recreate = function(self, coords, heading)
        return self:_Init(self.Imodel, coords or self.Icoords, heading or self.Iheading)
    end,

    duplicate = function(self, coords, heading, actual)
        return Vehicle({},self.Imodel, coords or (actual and self.coords or self.Icoords), heading or (actual and self.heading or self.Iheading))
    end,
}