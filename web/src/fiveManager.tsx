import ax from 'axios'

window.addEventListener("message",(event) => {
    const data = event.data;
    if (FMhandlers[data.manager]) {
        for (var i = 0; i < FMhandlers[data.manager].length; i++) {
            FMhandlers[data.manager][i](data)
        }
    }


})

export const FMhandlers : any = {}
export const gHandlers : any = {}

export const toFivem = (add : string, content : any) => { // Sends a message to the LUA code of the script
    return new Promise( async (solve,rej) => {
        var ret = await ax.post("https://red_lib/" + add, content)
        ret.data = JSON.parse(ret.data)
        solve(ret)
    })
}

export function listenFM(ev : string, callback : Function) { // Listens for a Nui message from FiveM
    if (FMhandlers[ev] == null) {
        FMhandlers[ev] = []
    }

    FMhandlers[ev].push(callback)
}

export function listenGlobal(ev : string, callback : Function) { // Listens for a global event
    if (gHandlers[ev] == null) {
        gHandlers[ev] = []
    }

    gHandlers[ev].push(callback)
}

export function trigger(ev : string, data : any) { // Triggers an internal event
    if (gHandlers[ev] == null) return false;

    for (var i in gHandlers[ev]) {
        var el = gHandlers[ev][i];

        el(data)
    }

    return true
}

toFivem("uiReady",{})