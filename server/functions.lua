local Charset = {}
local SetTimeout = SetTimeout

for i = 48,  57 do table.insert(Charset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

Functions = {
    ---@param player number id of player to check can use
    ---@param Name string name of your cmd to check
    ---@return boolean|string if return string it means have error and check it
    IsPlayerAllowedToUseCommand = function(player, Name)
        if Config.Debug then
            return pcall(IsPlayerAceAllowed(tostring((player), ("command.%s"):format(Name))))
        end
        return IsPlayerAceAllowed(tostring((player), ("command.%s"):format(Name)))
    end,
    ---@param Name string name of command to Create
    ---@param cb function handler of your command
    ---@return boolean
    CreateCommand = function(Name, cb)
        RegisterCommand(Name, cb, true)
        for i, v in ipairs(Config.Groups) do
            ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, Name))
        end
        return true
    end,
    ---@param player number id of player to check can use
    ---@return string get license player
    GetIdentifier = function(player)
        for i, v in ipairs(GetPlayerIdentifiers(player)) do
            if string.match(v, "license") then
                return v
            end
        end
    end,
    GetRandomString = function(length)
        math.randomseed(GetGameTimer())
        return CreateIdentifier(length - 1) .. Charset[math.random(1, #Charset)]
    end,
    ---@return string get Identifier
    CreateIdentifier = function()
        return string.format("Warn:%s", GetRandomString(3)):lower()
    end,
    ---@param field string - field to send
    ---@param content string
    ---@return void
    SendToDiscord = function(field, content)
        PerformHttpRequest(Config.WebHooks[field:lower()], function(Error, Content, Head) end, {
            json.encode({
                username = "WarnSystem-"..field:upper().."",
                content = content
            }),
            { ['Content-Type'] = 'application/json' }
        })
    end,
    ---@param src number -- id of player
    ---@return userdata? -- return player data
    GetPlayer = function(src)
        return players[tonumber(src)]
    end,
    ---@param src number -- id of player
    ---@return boolean -- if true it mean player register in resource
    DoesPlayerExist = function(src)
        return players[tonumber(src)] ~= nil
    end,
    ---@param inputstr string -- string for split
    ---@param sep string? -- split for
    ---@return table -- turn your string in table
    split = function(inputstr, sep)
        if sep == nil then
            sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
        end
        return t
    end


}

---@param player number id of player to check can use
---@return self -- return player
CreatePlayer = function(player)
    local self = {}
    self.PlayerID = player
    self.identifier = Functions.GetIdentifier(self.PlayerID)
    local warn = {}

    -- function
    self.load = function()
        local IsHaveData = MySQL.scalar.await('SELECT 1 FROM players_warning WHERE identifier = ?', { self.identifier })
        if IsHaveData then
            local WarnData = MySQL.prepare.await("SELECT `warns` FROM `players_warning` WHERE identifier = ?" , { self.identifier })
            warn = WarnData.warns
            for i, v in pairs(warn) do
                local Warner = Functions.split(v.reason, " from : ")[2] ~= nil and Functions.split(v.reason, " from : ")[2] or "unknown"
                TriggerClientEvent("WarnSystem:addWarn", self.PlayerID, {
                    warnIdentifier = i,
                    WarnLevel = v.WarnLevel,
                    reason = v.reason,
                    Warner = Warner
                })
            end
        else
            MySQL.insert.await('INSERT INTO players_warning (identifier, warns) VALUES (?, ?)', { self.identifier , json.encode({})})
        end
    end

    ---@param WarnLevel string --level of warn "low", "medium", "high"
    ---@param reason string --reason why are you warn player
    ---@param Warner number --staff PlayerID warn
    ---@return table --return some value : "warnIdentifier", "WarnLevel", "reason", "Warner"
    self.AddWarn = function(WarnLevel, reason, Warner)
        local warnIdentifier = CreateIdentifier()
        if warn[warnIdentifier] then
            return self.AddWarn(WarnLevel, reason, Warner)
        end
        warn[warnIdentifier] = {}
        table.insert(warn[warnIdentifier], {
            WarnLevel = WarnLevel,
            reason = string.format("%s - from : %s", reason, GetPlayerName(Warner))
        })
        Functions.SendToDiscord("addwarn", string.format("%s - from : %s_%s", reason, GetPlayerName(Warner), GetPlayerIdentifier(Warner, 1)))
        TriggerClientEvent("WarnSystem:addWarn", self.PlayerID, {
            warnIdentifier = warnIdentifier,
            WarnLevel = WarnLevel,
            reason = reason,
            Warner = GetPlayerName(Warner)
        })
        return {
            warnIdentifier = warnIdentifier,
            WarnLevel = WarnLevel,
            reason = reason,
            Warner = Warner
        }
    end

    ---Remove Warn from player with self warnIdentifier
    ---@param warnIdentifier string - identifier of warn to remove from player
    self.removeWarn = function(warnIdentifier)
        if not warn[(warnIdentifier):lower()] then return print(("warn with iden : %s Does Not Exist"):format(warnIdentifier)) end
        warn[(warnIdentifier):lower()] = nil
        TriggerClientEvent("WarnSystem:removeWarn", self.PlayerID, {
            warnid = (warnIdentifier):lower()
        })
    end

    ---Check Does Warn Exist on Player or not
    ---@param warnIdentifier string - identifier of warn to remove from player
    ---@return boolean
    self.DoesWarnExist = function(warnIdentifier)
        return warn[(warnIdentifier):lower()] ~= nil
    end

    ---@return table, number -return two parameter of warn
    self.getWarns = function()
        local New_tab = {}
        for i, v in pairs(warn) do
            table.insert(New_tab, {
                warnIdentifier = i,
                WarnLevel = v.WarnLevel,
                reason = v.reason
            })
        end
        return New_tab, #New_tab
    end
    ---Save Warn Data From Player
    self.save = function()
        MySQL.prepare("UPDATE `players_warning` SET `warns` = ? WHERE `identifier` = ?", {
            json.encode(warn),
            self.identifier
        }, function(results)
            if Config.Debug then
                if results then
                    print(('[^2INFO^7] Saved ^5%s^7 over ^5%s^7 ms'):format(GetPlayerName(self.PlayerID), math.floor((((os.time() - time) / 1000000) * 10^2) + 0.5) / (10^2)))
                end
            end
        end)
    end

    self.AutoSave = function()
        if Config.AutoSavePerPlayer then
            SetTimeout((9.5 * 60 * 1000), function()
                self.save()
                self.AutoSave()
            end)
        end
    end

    return self
end