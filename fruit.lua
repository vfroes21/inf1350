require "love"
require "coroutine"
require "coroutine_aux"

local function newFruit()
    local x = love.math.random(50, love.graphics.getWidth() - 50)
    local y = love.graphics.getHeight() - 50
    local xSpeed = love.math.random(-200, 200)
    local ySpeed = love.math.random(-700, -500)
    local fruitTypes = {"watermelon", "apple", "orange", "grapes"}
    local fruitType = fruitTypes[math.random(#fruitTypes)]

    local fruitsData = {
        watermelon = {color = {0, 1, 0, 1}, radius = 30},
        apple = {color = {1, 0, 0, 1}, radius = 20},
        orange = {color = {1, 0.5, 0, 1}, radius = 25},
        grapes = {color = {0.5, 0, 0.5, 1}, radius = 15}
    }
    local color = fruitsData[fruitType].color
    local radius = fruitsData[fruitType].radius
    local alive = true

    local frame_dt = -1 -- global dt value for coroutines
    local frame_mx = -1 -- global mx value for coroutines
    local frame_my = -1 -- global my value for coroutines

    local co_table = {}

    co_table.alive = coroutine.create(function()
        while y <= love.graphics.getHeight() + radius do
            coroutine.yield()
        end
        alive = false
    end)

    co_table.draw = coroutine.create(function()
        while alive do
            love.graphics.setColor(color)
            love.graphics.circle("fill", x, y, radius)
            coroutine.yield()
        end
    end)

    co_table.update = coroutine.create(function()
        while alive do
            x = x + xSpeed * frame_dt
            y = y + ySpeed * frame_dt
            ySpeed = ySpeed + 600 * frame_dt
            coroutine.yield()
        end
    end)

    co_table.collision_check = coroutine.create(function()
        while alive do
            local distance = math.sqrt((x - mx)^2 + (y - my)^2)
            if distance < radius then
                alive = false
                return true
            end
            return false
        end
    end)

    local function run_coroutine(co_name)
        if co_table[co_name] == nil then
            return nil
        end

        if coroutine.status(co_table[co_name]) ~= "dead" then
            coroutine.resume(co_table[co_name])
        end
        
    end

    return {
        update = function(dt)
            frame_dt = dt
            run_coroutine("alive")
            run_coroutine("update")
        end,

        checkMouseCollision = function(mx, my)
            frame_mx = mx
            frame_my = my
            run_coroutine("collision_check")
        end,

        draw = function()
            run_coroutine("draw")
        end,
        isAlive = function()
            return alive
        end
    }
end