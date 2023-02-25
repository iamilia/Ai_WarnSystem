local warns = {}
CreateThread(function()
    SendNuiMessage(json.encode({
        event = "setName",
        name = tostring(GetPlayerName(PlayerId()))
    }))
end)


RegisterNUICallback('close', function()
    Functions.ClosUi()
end)

RegisterNetEvent("WarnSystem:Notif", function(data)
    Functions.Notifaction(data.type, data.msg)
end)

RegisterNetEvent("WarnSystem:removeWarn", function(data)
    local warnidenti = data.warnid
    for i, v in ipairs(warns) do
        if v.warnIdentifier == warnidenti then
            SendNuiMessage(json.encode({
                event = "removewarn",
                warnid = tostring(""..i.."")
            }))
            table.remove(warns, i)
            break
        end
        Wait(0)
    end
end)

RegisterNetEvent("WarnSystem:addWarn", function(data)
    table.insert(warns, data)
    SendNuiMessage(json.encode({
        event = "addwarn",
        warnlevel = tostring(data.WarnLevel),
        reason = tostring(data.reason),
        warner = tostring(data.Warner),
        warnid = tostring(""..#warns.."")
    }))
end)


RegisterCommand("seewarning", function()
    Functions.ShowUi()
end, false)