local jc = jrequire 'jc'

local ostim = {}

-- returns a jcontainers object containing all objects with key value pair
-- JValue.evalLuaObj(animations, "return ostim.getAnimationsKeyValuePair(jobject,'animclass', 'Sx', 1, 0)")
-- papyrus bool to lua bool is an absolute pita, so just gonna use 1 and 0. if somebody works out something neater feel free to change.
function ostim.getAnimationsKeyValuePair(collection, key, value, allowPartialString, negativePartial)
    return jc.filter(collection, function(x)
        if allowPartialString == 1 then
            local ret = true
            if negativePartial == 1 then ret = false end
            if ((x[key]):lower()):find((value):lower(), 1, true) then return ret else return not ret end
        else
            return x[key] == value
        end
    end)
end

return ostim