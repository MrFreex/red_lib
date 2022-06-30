import ax from 'axios'

window.addEventListener("message",(event) => {
    const data = event.data;
    if (exporting.FMhandlers[data.manager]) {
        for (var i = 0; i < exporting.FMhandlers[data.manager].length; i++) {
            exporting.FMhandlers[data.manager][i](data)
        }
    }


})



const exporting : any = {
    toFivem(add : string, content : any) { // Sends a message to the LUA code of the script
        return new Promise( async (solve,rej) => {
            var ret = await ax.post("https://red_lib/" + add, content)
            ret.data = JSON.parse(ret.data)
            solve(ret)
        })
    },

    FMhandlers : { // Object containing arrays of functions

    },

    gHandlers : { // Object containing arrays of functions

    },

    listenFM(ev : string, callback : Function) { // Listens for a Nui message from FiveM
        if (exporting.FMhandlers[ev] == null) {
            exporting.FMhandlers[ev] = []
        }

        exporting.FMhandlers[ev].push(callback)
    },

    listenGlobal(ev : string, callback : Function) { // Listens for a global event
        if (exporting.gHandlers[ev] == null) {
            exporting.gHandlers[ev] = []
        }

        exporting.gHandlers[ev].push(callback)
    },

    trigger(ev : string, data : any) { // Triggers an internal event
        if (exporting.gHandlers[ev] == null) return false;

        for (var i in exporting.gHandlers[ev]) {
            var el = exporting.gHandlers[ev][i];

            el(data)
        }

        return true
    }

    
}

exporting.toFivem("uiReady",{})

export default exporting