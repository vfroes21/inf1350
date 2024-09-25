coroutine = require "coroutine"

function run_coroutine(co_table, co_name, arg1, arg2)
    if coroutine.status(co_table[co_name]) ~= "dead" then
        local _, value = coroutine.resume(co_table[co_name], arg1, arg2)
        return value
    end 
end