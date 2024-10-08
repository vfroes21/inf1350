require "love"
require "coroutine_aux"

FRUIT_STATE = {
    Alive = 1,
    Cutted = 2,
    Dead = 3
}

function newFruit()
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
    local state = FRUIT_STATE.Alive

    local co_table = {}

    co_table.alive = coroutine.create(function()
        while y <= love.graphics.getHeight() + radius do
            coroutine.yield()
        end
        state = FRUIT_STATE.Dead
    end)

    co_table.draw = coroutine.create(function()
        while state ~= FRUIT_STATE.Dead do
            love.graphics.setColor(color)
            if state == FRUIT_STATE.Alive then
                love.graphics.circle("fill", x, y, radius)
            elseif state == FRUIT_STATE.Cutted then
                love.graphics.arc("fill", x, y, radius, 0, math.pi)
            end
            coroutine.yield()
        end
    end)

    co_table.update = coroutine.create(function(dt)
        while state ~= FRUIT_STATE.Dead do
            x = x + xSpeed * dt
            y = y + ySpeed * dt
            ySpeed = ySpeed + 600 * dt
            dt = coroutine.yield()
        end
    end)

    co_table.collision_check = coroutine.create(function(mx, my)
        while state == FRUIT_STATE.Alive do
            local distance = math.sqrt((x - mx)^2 + (y - my)^2)
            if distance < radius then
                state = FRUIT_STATE.Cutted
            end
            mx, my = coroutine.yield(state)
        end
    end)

    return {
        update = function(dt)
            run_coroutine(co_table, "alive")
            run_coroutine(co_table, "update", dt)
        end,

        checkMouseCollision = function(mx, my)
            return run_coroutine(co_table, "collision_check", mx, my)
        end,

        draw = function()
            run_coroutine(co_table, "draw")
        end,
        getState = function()
            return state
        end,
        getScore = function()
            local value = math.floor(900/fruitsData[fruitType].radius)
            return value
        end
    }
end