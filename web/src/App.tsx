import React, { useEffect, useState } from 'react';

import * as FiveManager from './fiveManager'

import { Interactions } from './views/Interactions';

import './App.css';

interface setEnabled {
  manager : string,
  what : string,
  enabled : boolean
}

function App() {

  //let Enabled : any = {}

  let [Enabled,setEnabled] : [any,Function] = useState({})

  useEffect(() => {
    FiveManager.listenFM("setEnabled", (data : setEnabled) => {
      console.log("Enable: ", JSON.stringify(data))
      setEnabled({
        ...Enabled,
        [data.what] : data.enabled
      })
    })
  }, [Enabled])

  const getStyle = (what : string) => {
    if (Enabled[what] == null) return {}

    if (process.env.NODE_ENV === 'development' && !Enabled[what]) {
      setEnabled({...Enabled, Interactions : true})
    }

    return {
      display : Enabled[what] ? "block" : "none"
    }
  }

  return (
    <div className="App">
      <Interactions style={getStyle("Interactions")} />
    </div>
  );
}

export default App;
