local events = {}
local function mark(label, value)
    table.insert(events, { label, value })
    return value
end
local function scalar(v)
    local t = type(v)
    if t == "string" then
        return string.format("%q", v)
    elseif t == "number" or t == "boolean" then
        return tostring(v)
    elseif v == nil then
        return "nil"
    else
        return tostring(v)
    end
end
local function render(values)
    local parts = {}
    for i, v in ipairs(values) do
        parts[i] = scalar(v)
    end
    return table.concat(parts, ", ")
end
local function control(seed)
    local acc = seed
    for i = 1, 10 do
        if acc % 2 == 0 then
            acc = acc / 2 + i
        else
            acc = acc * 3 + 1 - i
        end
    end
    return acc
end
local function makeClosures(initial)
    local state = initial
    local function read()
        return state
    end
    local function mutate(delta)
        state = state + delta
        return state
    end
    local function replace(nextVal)
        local prev = state
        state = nextVal
        return prev
    end
    return {
        read = read,
        mutate = mutate,
        replace = replace
    }
end
local function createProxy(target)
    local proxy = {}
    local meta = {
        __index = function(_, k)
            mark("index", k)
            return target[k]
        end,
        __newindex = function(_, k, v)
            mark("newindex", k)
            target[k] = v
        end,
        __call = function(_, ...)
            mark("call", select("#", ...))
            return target(...)
        end
    }
    return setmetatable(proxy, meta)
end
local function runCoroutines()
    local co = coroutine.create(function(start)
        local val = start
        for i = 1, 3 do
            val = coroutine.yield(val * 2 + i)
        end
        return val
    end)
    local ok, res = coroutine.resume(co, 5)
    while coroutine.status(co) ~= "dead" do
        ok, res = coroutine.resume(co, res + 1)
    end
    return res
end
local function testErrors()
    local ok1, err1 = pcall(function()
        error("intentional error")
    end)
    local ok2, err2 = xpcall(function()
        return 42
    end, function(e)
        return "handled: " .. tostring(e)
    end)
    return not ok1 and ok2 and err2 == 42
end
mark("init", 1)
local cRes = control(7)
mark("control", cRes)
local clos = makeClosures(10)
clos.mutate(5)
mark("closure_read", clos.read())
clos.replace(100)
mark("closure_replace", clos.read())
local pTarget = { count = 0 }
local proxy = createProxy(pTarget)
proxy.count = 42
local pVal = proxy.count
mark("proxy", pVal)
local coRes = runCoroutines()
mark("coroutine", coRes)
local errRes = testErrors()
mark("errors", errRes)
local output = render(events)
return {
    events = events,
    output = output,
    control = cRes,
    coroutine = coRes,
    errors = errRes
}
