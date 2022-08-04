import Style from './css/Interactions.module.css'
import Five from '../fiveManager'
import { useEffect, useState, createRef, cloneElement, Key } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import * as Icons from '@fortawesome/free-solid-svg-icons'
import * as BrandIcons from '@fortawesome/free-brands-svg-icons'

interface InteractionsProps {
    style : any
}

interface SubInteractionI {
    label: string,
    id : string,
    icon : string
}

interface InteractionI {
    id: string,
    pos?: [number, number],
    inside: SubInteractionI[] | SubInteractionI,
    close? : boolean
}

const Placing_Order = [ 3, 5, 1, 7, 0, 8, 2, 6 ]

interface RadialBlockI {
    label : string, id : string, icon : string, onClick : Function, key: Key, style? : React.CSSProperties
}

const RadialBlock = (props: RadialBlockI) => {
    return <div style={props.style} className={Style.radialBlockC}>
        <div onClick={() => props.onClick(props.id)} className={Style.radialBlock}>
            <div><FontAwesomeIcon icon={(Icons[props.icon as keyof typeof Icons] || BrandIcons[props.icon as keyof typeof BrandIcons]) as any} /></div>
            <div><span>{props.label}</span></div>
        </div>
    </div>
}

let hideActive : Function = () => {};

const Radial = (props: any) => {

    let finalArray = [];

    hideActive = props.hide

    for (let i = 0; i < Placing_Order.length; i++) {
        finalArray[i] = null;
    }

    finalArray[4] = <div onClick={props.hide} className={Style.idot}></div>

    if (props.children.length === undefined) {
        finalArray[Placing_Order[0]] = props.children;
    }

    for (let i = 0; i < props.children.length; i++) {
        finalArray[Placing_Order[i]] = props.children[i];
    }

    return <div className={Style.interaction} style={props.style}>
        { finalArray.map((v,key) => {
            if (v === null) return <div/>

            return v
        }) }
    </div>
}

const IDot = (props: { children : any, style : any }) => {
    let dot : any = createRef()
    let [hovered, setHov] = useState(false)

    return <>
        <div onClick={() => { hideActive(); setHov(true) }} style={{...props.style, position: "absolute", transform: "translate(calc(calc(45vh/2) - 50%), calc(calc(45vh/2) - 50%))"}}  ref={dot} className={Style.idot}></div>
        { hovered && cloneElement(props.children, { hide: () => setHov(false) }) }
    </>
}

const Interactions = (props : InteractionsProps) => {
    let [interactions, setInteractions] = useState<InteractionI[]>(process.env.NODE_ENV === "development" ? 
        [{
            id: "ped_500",
            inside : [{
                label : "Kill The dude",
                id : "ped_500",
                icon : "faPersonWalking"
            }]
        }, {
            id: "ped_501",
            inside : {
                label : "Pedestrian",
                id : "ped_500",
                icon : "faPersonWalking"
            }
        }] 
    : [])

    const [position, setPosition] = useState<any>({ "ped_500" : [1250,1100], "ped_501" : [1300,1400]})
    const [visible, setVisible] = useState(process.env.NODE_ENV === "development")

    useEffect(() => {
        Five.listenFM("interactions", (data : { manager: string, interactions: InteractionI[] | undefined, positions:([Number,Number][]) | null }) => {
            //console.log("Ints: ", JSON.stringify(data.interactions))
            if (data.positions) {
                setPosition(data.positions)
            }

            data.interactions && setInteractions(data.interactions)
        })

        Five.listenFM("positions", (data: { manager: string, positions:[Number,Number][] }) => {
            //console.log("Pos: ", JSON.stringify(data.positions))
            setPosition(data.positions)
        })

        Five.listenFM("toggle", (data: { manager: string, toggle : boolean }) => {
            console.log("SetVisible: ", data.toggle)
            setVisible(data.toggle)
        })

        Five.listenFM("closeActive", (data: { manager: string }) => {
            if (hideActive) {
                hideActive()
            }
        })
    }, [])

    return <div style={{...props.style, display: visible ? "block" : "none"}} className={Style.main}>
        {
            interactions.map((el : InteractionI) => {
                if (!position[el.id]) return <></> // Interaction not active ATM
                const onClick = (id : string) => {
                    if (el.close && hideActive) {
                        hideActive()
                    }

                    Five.toFivem("interaction", { 
                        category: el.id,
                        id: id
                    })
                }

                const calcPos = {
                    left: `calc(${position[el.id][0]}px - calc(45vh/2))`,
                    top: `calc(${position[el.id][1]}px - calc(45vh/2))`
                }

                return Array.isArray(el.inside) ? <IDot key={el.id} style={calcPos}><Radial style={calcPos}>
                    {
                        
                        el.inside.map((sub : SubInteractionI, index : number) => {
                            return <RadialBlock key={index} label={sub.label} id={sub.id} icon={sub.icon} onClick={onClick} />
                        })
                    }
                </Radial></IDot> : <div className={Style.singleinteraction} style={calcPos}><RadialBlock key={0} label={el.inside.label} id={el.inside.id} icon={el.inside.icon} onClick={onClick} /></div>
            })
        }
    </div>
}

export { Interactions }