-- Classify
function merge(...)local a={...}local b={}for c=1,#a do for d,e in pairs(a[c])do b[d]=e end end;return b end;function class(f)f.__type=f.__type or"rClass"local class={__add=f.__add or f._Add or nil,__sub=f.__sub or f._Sub or nil,__mul=f.__mul or f._Mul or nil,__div=f.__div or f._Div or nil,__idiv=f.__idiv or f._FloorDiv or nil,__mod=f.__mod or f._Mod or nil,__pow=f.__pow or f._Pow or nil,__unm=f.__unm or f._Neg or nil,__concat=f.__concat or f._Concat or nil,__index=f.__index or f._Index or nil,__len=f.__len or f._Len or f.__len,__eq=f.__eq or f._IsEqual or nil,__lt=f.__lt or f._IsLessThan or nil,__le=f.__le or f._IsLessOrEqual or nil,__band=f.__band or f._And or nil,__bor=f.__bor or f._Or or nil,__bxor=f.__bxor or f._Xor or nil,__bnot=f.__bnot or f._Not or nil,__shl=f.__shl or f._LShift or nil,__shr=f.__shr or f._RShift or nil,__call=f.__call or f._Call or nil}local g={}return setmetatable(g,{__call=function(self,...)local class=setmetatable(merge({},f),class)if class._Init then class:_Init(...)end;return class end,__index=function(h,i)return f[i]end})end;function extend(class,j)if type(class)~='function'then error("Cant extend a non uClass object")end;return function(k)local l=class()local class=setmetatable(k and merge(k,j,l)or merge(j,l),l)if class._Init then class:_Init()end;return class end end;local m=type;_G.type=function(n)local o=function(p)if m(p)=="table"then return p.__type or"table"else return m(p)end end;local q,r=pcall(o,n)if not q then return"funcref"else return r end end

-- Debug

function debugPrint(...)
    if IsDuplicityVersion() or isDev then
        return print(...)
    end
end

-- Replaces

local _print = print
function rPrint(...)
    local args = { ... }
    local nargs = {}
    for k,e in pairs(args) do
        local add
        if type(e) == "table" then
            local f, keys = pairs(args)
            if type(next(keys)) == "string" then
                add = json.encode(k)
            else
                for i=1,#e do
                    _print(e[i])
                end
            end
            
            
        else
            add = e
        end

        if add then
            table.insert(nargs, add)
        end
    end

    _print(table.unpack(nargs))
end

-- Libraries

function encodeIndexes(indexes)
    local str = ""
    for k,e in pairs(indexes) do
        str = str .. ":" .. e
    end
    
    return str:sub(2)
end

function string.split (inputstr, sep, as_multiple)
    if sep == nil then
        sep = "%s"
    end

    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end

    if as_multiple then
        return table.unpack(t)
    end

    return t
end

function table.merge(t, separator)
    local s = ""
    for _,e in pairs(t) do
        if type(e) == "string" then
            s = s .. (separator or "") .. e
        end
    end

    s = s:sub(2)

    return s
end

