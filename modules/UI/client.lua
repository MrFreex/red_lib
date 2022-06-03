local Utils = Common("Utils")

local onReady = {}

local isReady = false

RegisterNUICallback("uiReady", function(data, cb)
    Utils.callAll(onReady)
    isReady = true
    cb("{}")
end)


local UI = {

}

function UI.toggle(focus, toggle)
    if isReady and toggle ~= nil then
        SendNUIMessage({
            manager = "toggle",
            toggle = toggle
        })
    end
    SetNuiFocus(focus,focus)
end

function UI.listen(name, cb)
    return RegisterNUICallback(name, cb)
end

function UI.onReady(func)
    if isReady then return func() end
    table.insert(onReady, func)
end

Modules("UI", UI)