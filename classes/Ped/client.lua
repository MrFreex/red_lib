local PossibleIndexes = {
    ["pos"] = function(self) GetEntityCoords(self.ent) end,
    ["coords"] = function(self) GetEntityCoords(self.ent) end,
    ["heading"] = function(self) GetEntityHeading(self.ent) end,
    ["model"] = function(self) GetEntityModel(self.ent) end
}

Ped = class {
    _Init = function(self, ent, coords, heading, missionEntity, networked)
        if (type(ent) == "number") then
            if DoesEntityExist(ent) or NetworkDoesEntityExistWithNetworkId(NetworkGetNetworkIdFromEntity(ent)) then
                self.ent = ent
            elseif NetworkDoesEntityExistWithNetworkId(ent) then
                self.net = ent
                self.ent = NetworkGetEntityFromNetworkId(ent)
                ent = self.ent
            end
        elseif type(ent) == "string" then
            self.ent = CreatePed(nil, GetHashKey(ent), coords.x, coords.y, coords.z, heading, networked, missionEntity)
            
            if heading then
                self:setHeading(heading)
            end

            if typeof(missionEntity) == "boolean" then
                self:setMissionEntity(missionEntity)
            end
        end
    end,

    --[[
        @desc: Sets entity heading
        @param: heading : number
        @return: void
    ]]--

    setHeading = function(self, heading)
        SetEntityHeading(self.ent, heading)
    end,

    --[[
        @desc: Sets entity mission entity
        @param: missionEntity : boolean
        @return: void
    ]]--

    setMissionEntity = function(self, missionEntity)
        SetEntityAsMissionEntity(self.ent, missionEntity, false)
    end,

    --[[
        @desc: Hooks index to the entity
    ]]

    _Index = function(self, key)
        if (PossibleIndexes[key]) then
            return PossibleIndexes[key](self)
        end

        return rawget(self,key)
    end,

    --[[
        @desc: Hooks lenght
    ]]

    _Len = function(self)
        return self.ent
    end,

    --[[
        @desc: Checks if self.ent or self.net exist
        @return: "local" if it exists locally (DoesEntityExist), "net" if the network id exists, false if it doesn't 
    ]]

    exists = function(self)
        if DoesEntityExist(self.ent) then
            return "local"
        elseif NetworkDoesEntityExistWithNetworkId(self.net) then
            return "net"
        else
            return false
        end
    end,

    --[[
        @desc: Deletes Entity and object
    ]]

    destroy = function(self)
        if self:exists() == "local" then
            DeleteEntity(self.ent)
        elseif self:exists() == "net" then
            NetworkRequestControlOfNetworkId(self.net)
            local ent = NetworkGetEntityFromNetworkId(self.net)
            local net = self.net
            CreateThread(function()
                while not NetworkHasControlOfNetworkId(net) do
                    Wait(0)
                end

                DeleteEntity(ent)
            end)    
            self = nil
        end
    end
}