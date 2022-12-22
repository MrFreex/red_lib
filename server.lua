local logo_rows = { 
"            ...::$$$$$$:.           .                                      ",
"            $$$$$$$$$$$$$$~^.   .~$$$$~~~$~~~~~^:~~~~^^^$$$$$$$$$$$^.      ",
"           .:^~$$^..  :^$$$$~:. .~$$$$$$$$$$$$$$$$~^^....^$$$$$$$$$$~.     ",
"           .~~$$$$^      .~$$$$~    ^$$$$$$:..            ^$$$$$$$$$$$$~.  ",
"           $$$$$$~.       .$$$$$^   ^$$$$$$              .$$$$$$~.^$$$$$$: ",
"          ^$$$$$~.         $$$$$^   $$$$$~.              ^$$$$$^    ~$$$$$^",
"          ~$$$$$.        .~$$$$^   :$$$$$.              .$$$$$$.     $$$$$^",
"       :~~$$$$$^      .:^$$$$$^. ..~$$$$$               ~$$$$$      .$$$$$ ",
"      ^$$$$$$$~.  ..:~$$$$$$^. .^$$$$$$$$$~~$$$~^.     ~$$$$$:     :$$$$$^ ",
"    .:$$$$$$$$$$$$$$$$$$$~:      ^$$$$$$$~~~~^:..      $$$$$~    .~$$$$$^  ",
"      ^~$$$$$$$$$$$$$~~:.        ^$$$$^.              ^$$$$~   .$$$$$$$:   ",
"       ^$$$$$$$$$$$$~.          .$$$~:               :$$$$. .:~$$$$$~:     ",
"      .$$$$: .:~$$$$$$~:       .$$$$.     .......   :$$$$~:~$$$$$~^.       ",
"      $$$$:     .:~$$$$$$^..:^~$$$$$~~$$$$$$$$$$$$$$$$$$$$$$$~~:.          ",
"      $$$$^        .::~$$$$~$$$$$$$$$$$$$$$$$$~^^~$$$$$$$$^.               ",
"     .$$$~              :~$$$$$$~$~^^::..      .^~$$$$~^:.                 ",
"     .$$:                 ..^~$$:           .:~$~^^~:                      ",
"     .:.                     ...:.        ...:.    .                       ",
"     .                            .    ..                                  ",
"                                                                           " 
}

rPrint(logo_rows)

local Events = Common("Events")
local Arrays = Common("Arrays")

local Identifiers = {}



exports("Identifiers", function(whose)
    return whose and Identifiers[whose] or Identifiers
end)

Events.Register("client-ready", function()
    Identifiers[source] = {}
    for k,e in pairs(GetPlayerIdentifiers(source)) do
        local prefix,identifier = string.split(e, ":", true)
        Identifiers[source][prefix] = identifier
    end

    if Arrays.find(Config.debug.identifiers, GetPlayerIdentifier(source, 0)) ~= nil then
        Events.TriggerClient("is-dev", source, {  }, "red_lib")
    end
end)