Modules = {
    loaded = {}
}

setmetatable(Modules, {
    __type = "RedModules",
    __call = function(self, name, func)
        self[name] = func
        table.insert(self.loaded, name)
    end
})

--//Classify ( Written by XenoS.exe, Inspired by https://github.com/PolySaken-I-Am/Oopl )

local function merge(...)
    local args = ({...})
    local merged = {}

    for i = 1, #args do
        for k,v in pairs(args[i]) do
            merged[k] = v
        end
    end
    return merged
end

function class(obj)
    obj.__type = "uClass"
    
    local class = {
        -- metamethods
        __add = obj.__add or obj._Add or nil,
        __sub = obj.__sub or obj._Sub or nil,
        __mul = obj.__mul or obj._Mul or nil,
        __div = obj.__div or obj._Div or nil,
        __idiv = obj.__idiv or obj._FloorDiv or nil,
        __mod = obj.__mod or obj._Mod or nil,
        __pow = obj.__pow or obj._Pow or nil,
        __unm = obj.__unm or obj._Neg or nil,
        __concat = obj.__concat or obj._Concat or nil,
        __index = obj.__index or obj._Index or nil,
        __len = obj.__len or obj._Len or obj.__len,
        
        __eq = obj.__eq or obj._IsEqual or nil,
        __lt = obj.__lt or obj._IsLessThan or nil,
        __le = obj.__le or obj._IsLessOrEqual or nil,
        
        __band = obj.__band or obj._And or nil,
        __bor = obj.__bor or obj._Or or nil,
        __bxor = obj.__bxor or obj._Xor or nil,
        __bnot = obj.__bnot or obj._Not or nil,
        
        __shl = obj.__shl or obj._LShift or nil,
        __shr = obj.__shr or obj._RShift or nil,
        
        __call = obj.__call or obj._Call or nil,
    }

    return function(...)
        local class = setmetatable(merge({},obj), class)

        if class._Init then
            class:_Init(...)
        end

        return class
    end
end

function extend(class, extension)
    if type(class) ~= 'function' then
        error("Cant extend a non uClass object")
    end
    
    return function(options)
        local a = class()
        
        local class = setmetatable(options and merge(options, extension, a) or merge(extension, a), a)

        if class._Init then
            class:_Init()
        end

        return class
    end
end

local _old_type = type

_G.type = function(subject)
    local check_type = function(subj)
        if _old_type(subj) == "table" then
            return subj.__type or "table"
        else return _old_type(subj) end
    end

    local no_error, ret_value = pcall(check_type, subject)
    if not no_error then --// happens when trying to index a funcref
        return "funcref"
    else
        return ret_value
    end
end

--//End

CreateThread(function()
    local Events = Common("Events")
    Events.Trigger("loaded", {})
end)

