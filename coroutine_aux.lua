coroutine = require"coroutine"

function run_coroutine(co_table, co_name)
    if coroutine.status(co_table[co_name]) ~= "dead" then
        coroutine.resume(co_table[co_name])
    end 
end

