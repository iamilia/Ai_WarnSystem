players = {}
AddEventHandler('playerConnecting', function()
    local src = source
    players[tonumber(src)] = CreatePlayer(src)
    Wait(math.random(1, 500))
    players[tonumber(src)].load()
    players[tonumber(src)].AutoSave()
end)

Functions.CreateCommand("AddWarn", function(source, args)
    if source < 1 then return print("[^2INFO^7] You Cannot run this command from console") end
    local Target = Functions.GetPlayer(args[1])
    local WarnLevel = type(args[2]) == "string" and args[2] or false
    local reason = table.concat(args, " ", 3)
    if WarnLevel == false then return TriggerClientEvent("WarnSystem:Notif", source, {
        type = "warning",
        msg = "Warn level must be string"
    })
    end
    local WarnInfo = Target.AddWarn(WarnLevel, reason, source)
end)

Functions.CreateCommand("RemoveWarn", function(source, args)
    if source < 1 then return print("[^2INFO^7] You Cannot run this command from console") end
    local Target = Functions.GetPlayer(args[1])
    local WarnIdentifier = type(args[2]) == "string" and args[2] or false
    if WarnIdentifier == false then return TriggerClientEvent("WarnSystem:Notif", source, {
        type = "warning",
        msg = "Warn level must be string"
    })
    end
    if not Target.DoesWarnExist(WarnIdentifier) then return TriggerClientEvent("WarnSystem:Notif", source, {
        type = "warning",
        msg = "WarnIdentifier does not exist on this player"
    }) end
    local WarnInfo = Target.removeWarn(WarnIdentifier)
end)

AddEventHandler(Config.UnLoadEvent, function()
    local src = source
    players[tonumber(src)].save()
    players[tonumber(src)] = nil
end)


AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    for i, v in ipairs(GetPlayers()) do
        local Player = Functions.GetPlayer(v)
        if Player then
            Player.save()
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    for i, v in ipairs(GetPlayers()) do
        local Player = Functions.GetPlayer(v)
        if not Player then
            players[tonumber(v)] = CreatePlayer(v)
            Wait(math.random(1, 500))
            players[tonumber(v)].load()
            players[tonumber(v)].AutoSave()
        end
    end
end)