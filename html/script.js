function Show() {
    $("main").fadeIn(500)
}

function CloseButton() {
    $("main").fadeOut(500)
    $.post("https://Ai_WarnSystem/close", JSON.stringify({}))
}

function AddWarnBox(WarnLevel, reason, Warner, WarnId) {
    let color = {
        low : "#ff1414",
        medium : "#c7000c",
        high : "#4f0000"
    }
    let WarnBox = `<div class="panel-req-box" id="warn_${WarnId}" style="background: ${color[WarnLevel.toLowerCase()]};">
           <div class="Warner--box">
                 <p class="Warner"><span class="Warner--info">Warner:</span>${Warner}</p>
           </div>
          <div class="reason--box">
                <p class="reason">${reason}</p>
          </div>
    </div>`
    $('.body--main').append(WarnBox)
}

function RemoveBox(WarnId) {
    $(`#warn_${WarnId}`).remove()
}

function ShowNotif(ty, msg) {
    let color = {
        success : "#12ff00",
        warning : "#ff8437",
        info : "#c5ff21",
        notif : "#797878",
    }
    $("#message").css({
        'display' : 'flex',
        "background-color": color[ty.toLowerCase()],
    })
    $("#message").html(String(msg))
    setTimeout(() => {
        $("#message").fadeOut();
    }, 3000);
}

window.addEventListener('message', function (event) {
    let data = event.data;
    switch (data.event) {
        case 'show':
            Show()
        break;
        case 'hide':
            CloseButton()
        break;
        case "addwarn" :
            AddWarnBox(data.warnlevel, data.reason, data.warner, data.warnid)
        break;
        case "removewarn" :
            RemoveBox(data.warnid)
        break;
        case "setName" :
            $("#player__name p").html(data.name)
        break;
        case "ShowNotif" :
            ShowNotif(data.typ, data.msg)
        break;
    }
});