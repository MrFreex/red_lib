local Utils = Common("Utils")

local onReady = {}

RegisterNUICallback("uiReady", function(data, cb)
    Utils.callAll(onReady)
    cb("{}")
end)

local UI = {

}

function UI.onReady(func)
    table.insert(onReady, func)
end

Modules("UI", UI)