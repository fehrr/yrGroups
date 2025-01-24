local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
local config = module(GetCurrentResourceName(), "config") --GetCurrentResourceName()
local vRP = Proxy.getInterface("vRP")
--

nui = false

RegisterNetEvent("yrGroups:NUIlider", function(data)
    if not nui then
        SendNUIMessage({
            action = "openUIlider",
            data = data
        })
        SetNuiFocus(true, true)
        SetCursorLocation(0.5, 0.5)
        nui = true
    else
        SendNUIMessage({
            action = "closeUI",
        })
        SetNuiFocus(false, false)
        SetCursorLocation(0.5, 0.5)
        nui = false
    end
end)
RegisterNetEvent("yrGroups:RefreshNUIlider", function(data)
    SendNUIMessage({
        action = "openUIlider",
        data = data
    })
    SetNuiFocus(true, true)
    nui = true
end)

RegisterNetEvent("yrGroups:NUIgerente", function(data)
    if not nui then
        SendNUIMessage({
            action = "openUIgerente",
            data = data
        })
        SetNuiFocus(true, true)
        SetCursorLocation(0.5, 0.5)
        nui = true
    else
        SendNUIMessage({
            action = "closeUI",
        })
        SetNuiFocus(false, false)
        SetCursorLocation(0.5, 0.5)
        nui = false
    end
end)
RegisterNetEvent("yrGroups:RefreshNUIgerente", function(data)
    SendNUIMessage({
        action = "openUIgerente",
        data = data
    })
    SetNuiFocus(true, true)
    nui = true
end)

RegisterNetEvent("yrGroups:NUImembro", function(data)
    if not nui then
        SendNUIMessage({
            action = "openUImembro",
            data = data
        })
        SetNuiFocus(true, true)
        SetCursorLocation(0.5, 0.5)
        nui = true
    else
        SendNUIMessage({
            action = "closeUI",
        })
        SetNuiFocus(false, false)
        SetCursorLocation(0.5, 0.5)
        nui = false
    end
end)
RegisterNetEvent("yrGroups:RefreshNUImembro", function(data)
    SendNUIMessage({
        action = "openUImembro",
        data = data
    })
    SetNuiFocus(true, true)
    nui = true
end)

RegisterNUICallback("closeSystem", function()
	SendNUIMessage({
        action = "closeUI",
    })
    SetNuiFocus(false, false)
    SetCursorLocation(0.5, 0.5)
    nui = false
end)

RegisterNUICallback("sacar", function(value)
    local value = json.decode(json.encode(value))
    TriggerServerEvent("yrGroups:Sacar", value[1], value[2])
end)

RegisterNUICallback("depositar", function(value)
    local value = json.decode(json.encode(value))
    TriggerServerEvent("yrGroups:Depositar", value[1], value[2])
end)

RegisterNUICallback("contratar", function(dataa)
    local data = json.decode(json.encode(dataa))
    TriggerServerEvent("yrGroups:Contratar", data[1], data[2])
end)

RegisterNUICallback("demitir", function(dataa)
    local data = json.decode(json.encode(dataa))
    TriggerServerEvent("yrGroups:Demitir", data[1], data[2])
end)

RegisterNUICallback("rebaixar", function(dataa)
    local data = json.decode(json.encode(dataa))
    TriggerServerEvent("yrGroups:Rebaixar", data[1], data[2])
end)

RegisterNUICallback("promover", function(dataa)
    local data = json.decode(json.encode(dataa))
    TriggerServerEvent("yrGroups:Promover", data[1], data[2])
end)