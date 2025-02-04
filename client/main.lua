local RSGCore = exports['rsg-core']:GetCoreObject()
local blips = {}

-- create blips and targets
Citizen.CreateThread(function()
    for banks, v in pairs(Config.BankLocations) do
        if Config.UseTarget == false then
            exports['rsg-core']:createPrompt(v.name, v.coords, RSGCore.Shared.Keybinds['J'], 'Open ' .. v.name, {
                type = 'client',
                event = 'rsg-banking:openBankScreen',
                args = {},
            })
        else
            exports['rsg-target']:AddCircleZone(v.name, v.coords, 1, {
                name = v.name,
                debugPoly = false,
              }, {
                options = {
                  {
                    type = "client",
                    event = 'rsg-banking:openBankScreen',
                    icon = "fas fa-dollar-sign",
                    label = "Open Bank",
                  },
                },
                distance = 2.0,
              })
        end
        if v.showblip == true then
            local StoreBlip = N_0x554d9d53f696d002(1664425300, v.coords)
            SetBlipSprite(StoreBlip, -2128054417, 52)
            SetBlipScale(StoreBlip, 0.2)
        end
    end
end)

-- open all doors
Citizen.CreateThread(function()
    for k,v in pairs(Config.BankDoors) do
        Citizen.InvokeNative(0xD99229FE93B46286,v,1,1,0,0,0,0)
        Citizen.InvokeNative(0x6BAB9442830C7F53,v,0)
    end
end)

-- Functions

local function openAccountScreen()
    RSGCore.Functions.TriggerCallback('rsg-banking:getBankingInformation', function(banking)
        if banking ~= nil then
            SetNuiFocus(true, true)
            SendNUIMessage({
                status = "openbank",
                information = banking
            })
        end
    end)
end

-- Events

RegisterNetEvent('rsg-banking:successAlert', function(msg)
    SendNUIMessage({
        status = "successMessage",
        message = msg
    })
end)

RegisterNetEvent('rsg-banking:openBankScreen', function()
    openAccountScreen()
end)

-- NUI

RegisterNetEvent("hidemenu", function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closebank"
    })
end)

-- NUI Callbacks

RegisterNUICallback("NUIFocusOff", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closebank"
    })
    cb("ok")
end)

RegisterNUICallback("doDeposit", function(data, cb)
    if tonumber(data.amount) ~= nil and tonumber(data.amount) > 0 then
        TriggerServerEvent('rsg-banking:doQuickDeposit', data.amount)
        openAccountScreen()
        cb("ok")
    end
    cb(nil)
end)

RegisterNUICallback("doWithdraw", function(data, cb)
    if tonumber(data.amount) ~= nil and tonumber(data.amount) > 0 then
        TriggerServerEvent('rsg-banking:doQuickWithdraw', data.amount, true)
        openAccountScreen()
        cb("ok")
    end
    cb(nil)
end)
