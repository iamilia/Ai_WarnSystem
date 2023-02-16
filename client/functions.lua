local display = false
Functions = {
    Notifaction = function(category, msg)
        SendNuiMessage(json.encode({
            event = "ShowNotif",
            typ = tostring(category),
            msg = tostring(msg)
        }))
    end,
    ShowUi = function()
        if not display then
            display = not display
            SendNuiMessage(json.encode({
                event = "show"
            }))
            SetNuiFocus(display, display)
        else
            Functions.ClosUi()
        end
    end,
    ClosUi = function()
        if display then
            display = not display
            SendNuiMessage(json.encode({
                event = "hide"
            }))
            SetNuiFocus(display, display)
        else
            Functions.ShowUi()
        end
    end
}