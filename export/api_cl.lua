UTIL = {}
FAPI = {}
local addons = {}

local Arrays = Common("Arrays")

local Keys = {["ESC"]=322,["F1"]=288,["F2"]=289,["F3"]=170,["F5"]=166,["F6"]=167,["F7"]=168,["F8"]=169,["F9"]=56,["F10"]=57,["~"]=243,["1"]=157,["2"]=158,["3"]=160,["4"]=164,["5"]=165,["6"]=159,["7"]=161,["8"]=162,["9"]=163,["-"]=84,["="]=83,["BACKSPACE"]=177,["TAB"]=37,["Q"]=44,["W"]=32,["E"]=38,["R"]=45,["T"]=245,["Y"]=246,["U"]=303,["P"]=199,["["]=39,["]"]=40,["ENTER"]=18,["CAPS"]=137,["A"]=34,["S"]=8,["D"]=9,["F"]=23,["G"]=47,["H"]=74,["K"]=311,["L"]=182,["LEFTSHIFT"]=21,["Z"]=20,["X"]=73,["C"]=26,["V"]=0,["B"]=29,["N"]=249,["M"]=244,[","]=82,["."]=81,["LEFTCTRL"]=36,["LEFTALT"]=19,["SPACE"]=22,["RIGHTCTRL"]=70,["HOME"]=213,["PAGEUP"]=10,["PAGEDOWN"]=11,["DELETE"]=178,["LEFT"]=174,["RIGHT"]=175,["TOP"]=27,["DOWN"]=173,["NENTER"]=201,["N4"]=108,["N5"]=60,["N6"]=107,["N+"]=96,["N-"]=97,["N7"]=117,["N8"]=61,["N9"]=118}

function Addon(name)
    return addons[name]
end


local Blips = {
    __index = function(self, k)
        return getBlips()[k]
    end
}

--// Class

function Blips:create()
    if (self.blip ~= nil and DoesBlipExist(self.blip)) then
        RemoveBlip(self.blip)
        self.blip = nil
    end

    if type(self.pos) == "vector3" then -- by pos
        self.blip = AddBlipForCoord(self.pos)
    elseif type(self.pos) == "number" then -- by ent
        self.blip = AddBlipForEntity(self.pos)
    end

    
end 

function Blips:destroy()
    if self.blip ~= 0 and self.blip ~= nil then
        RemoveBlip(self.blip)
    end

    self = nil -- Ram cleanup
end

function Blips:setSprite(sprite)
    if sprite then
        self.sprite = sprite
    end

    return SetBlipSprite(self.blip, self.sprite)
end

local function setBlipName(id, name)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(id)
end

function Blips:setText(text)
    if text then
        self.text = text
    end
    return setBlipName(self.blip, self.text)
end

function Blips:setColor(c)
    if c then
        self.color = c
    end

    return SetBlipColour(self.blip, self.color)
end

function Blips:setAsRoute(b)
    if b ~= nil then
        self.options.route = b
    end

    return SetBlipRoute(self.blip, self.options.route)
end

function Blips:setOptions(options)
    if options then
        self.options = options
    end

    SetBlipAsShortRange(self.blip, not self.options.lr)
    SetBlipRoute(self.blip, self.options.route)
    if self.options.routec then
        SetBlipRouteColour(self.blip, self.options.routec)
    end
    SetBlipScale(self.blip, self.options.scale)
end

--Instance

local RouteBlip = function(sprite, pos, text, color, options)
    options = options or {}
    options.route = true
    return FAPI.Blip(sprite, pos, text, color, options)
end

local defaultOptions = { 
    route = false,
    scale = 0.8,
    lr = false
}

local Blip = function(sprite, pos, text, color, options)

    for k,e in pairs(defaultOptions) do
        if options[k] == nil then
            options[k] = defaultOptions[k]
        end
    end

    local new = {
        sprite = sprite,
        pos = pos,
        text = text,
        color = color,
        options = options -- route, routec, scale
    }

    setmetatable(new, Blips)

    new:create()
    new:setSprite()
    new:setColor()
    new:setText()
    new:setOptions()

    return new
end

function getBlips()
    return Blips
end

FAPI.Blip = Blip
FAPI.RouteBlip = RouteBlip

addons.Blip = Blip
addons.RouteBlip = RouteBlip

--// Util functions

UTIL.toArray = function(tab) -- Useful for UI stuff
    local ret = {}
    for k,e in pairs(tab) do
        table.insert(ret,e)
    end

    return ret
end



addons.utils = UTIL

local Anims = {}

Anims.Flags = {
    Loop = 1,
    StopOnLastFrame = 2,
    OnlyAnimateUpperBody = 4,
    UpperBody = 16,
    EnablePlayerControl = 32,
    Cancelable = 120
}



async = Citizen.CreateThread

local active = {}

Anims.stop = function(ped)
    ped = ped or redPlayer.ped
    if not active[ped] then
        return false
    end

    active[ped] = nil
    ClearPedTasks(ped)
    return true
end

Anims.Allow = {0,1,2,3,4,5,6}

Anims.play = function(dict, name, params, duration, prevent, block, ped)
    if not ped then
        ped = redPlayer.ped
    end

    local flags = 0

    if type(params) == "table" then
        for _,e in pairs(params) do
            if Anims.Flags[e] then
                flags = flags + Anims.Flags[e]
            end
        end
    elseif type(params) == "number" then
        flags = params
    end

    duration = duration or GetAnimDuration(dict, name)
    
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
    
    TaskPlayAnim(ped, dict, name, 8.0, 8.0, duration or -1, flags, 2, false, false, false)
    local time
    if duration ~= -1 then
        time = GetGameTimer() + duration
    end
    if prevent then
        local lid

        repeat lid = math.random( 0, 999999 ) until not Arrays.find((active[ped] or {}), lid)

        Citizen.CreateThread(function()
            while Arrays.find(active[ped] or {}, lid) do
                if (not IsEntityPlayingAnim(ped, dict, name, 3)) then
                    TaskPlayAnim(ped, dict, name, 8.0, 8.0, duration or -1, flags, 2, false, false, false)
                end
    
                if time ~= nil then
                    if GetGameTimer() > (time - 300) then
                        if active[ped] then
                            for k,e in pairs(active[ped]) do
                                if e == lid then
                                    table.remove(active[ped], k)
                                end
                            end
                        end
                        
                        return
                    end
                end
    
                if block then
                    DisableAllControlActions(0)
                    for i=1, #Anims.Allow do
                        if old_EnableControlAction then
                            old_EnableControlAction(0, Anims.Allow[i], true)
                        else
                            EnableControlAction(0, Anims.Allow[i], true)
                        end
                    end
                else
                    Wait(1000)
                end

                Wait(0)
            end
        end)
        active[ped] = active[ped] or {}

        table.insert(active[ped], lid)

        return lid
    end
end

addons.Anims = Anims

if onLoad then
    onLoad()
end
