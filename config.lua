Config = {
    Debug = true,
    Groups = {
        -- qb-core
        "god",
        --esx
        "superadmin",
        --shared
        "admin"
    },
    ---@param player number id of player to check can use
    ---@return string get license 2 player
    GetIdenifier = function(player)
        for i, v in ipairs(GetPlayerIdentifier(player)) do
            if string.match(v, "license2") then
                return v
            end
        end
    end,

    WebHooks = {
        addwarn = "",
        removewarn = "",

    },

    OnLoadEvent = 'playerDropped', -- fivem def

    AutoSavePerPlayer = true
}