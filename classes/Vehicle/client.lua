local function create(self, ...)
    self.ent = CreateVehicle(...)
end

Vehicle = class {
    -- Constructor
    _Init = function(self, ent, coords, heading, missionEntity, networked)
        if (type(ent) == "number") then
            if DoesEntityExist(ent) or NetworkDoesEntityExistWithNetworkId(NetworkGetNetworkIdFromEntity(ent)) then
                self.ent = ent
            elseif NetworkDoesEntityExistWithNetworkId(ent) then
                self.net = ent
                self.ent = NetworkGetEntityFromNetworkId(ent)
                ent = self.ent
            else
                create(self, ent, coords, heading, missionEntity, networked)
            end
        elseif type(ent) == "string" then
            create(self, ent, coords, heading, missionEntity, networked)
        end
    end,

    setHeading = function(self, heading)
        SetEntityHeading(self.ent, heading)
    end,
        
    setMissionEntity = function(self, missionEntity)
        SetEntityAsMissionEntity(self.ent, missionEntity, false)
    end
}