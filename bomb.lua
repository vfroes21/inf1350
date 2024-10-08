require "love"
require "coroutine_aux"

function newBomb()
    local x = love.math.random(50, love.graphics.getWidth() - 50)
    local y = love.graphics.getHeight() - 50
    local xSpeed = love.math.random(-200, 200)
    local ySpeed = love.math.random(-700, -500)
    local bombTypes = {"small", "medium", "large"}
    local bombType = bombTypes[math.random(#bombTypes)]
    local alive = true

    local bombsData = {
        small = {
            radius = 15,
            yVariation = 1.6
        },
        medium = {
            radius = 30,
            yVariation = 1
        },
        large = {
            radius = 45,
            yVariation = 0.8
        }
    }

    local radius = bombsData[bombType].radius
    local yVariation = bombsData[bombType].yVariation
    y = y * yVariation

    local co_table = {}

    co_table.alive = coroutine.create(function()
        while y <= love.graphics.getHeight() + radius do
            coroutine.yield()
        end
        alive = false
    end)

    co_table.draw = coroutine.create(function()
        while alive do
            love.graphics.setColor({0,0,0})
            love.graphics.circle("fill", x, y, radius)
            love.graphics.setColor({.7,0,0})
            love.graphics.circle("fill", x, y, radius-radius/10)
            coroutine.yield()
        end
    end)

    co_table.update = coroutine.create(function(dt)
        while alive do
            x = x + xSpeed * dt
            y = y + ySpeed * dt * yVariation
            ySpeed = ySpeed + 600 * dt
            dt = coroutine.yield()
        end
    end)

    co_table.collision_check = coroutine.create(function(mx, my)
        while alive do
            local result = false
            local distance = math.sqrt((x - mx)^2 + (y - my)^2)
            if distance < radius then
                alive = false
                result = true
            end
            mx, my = coroutine.yield(result)
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
        isAlive = function()
            return alive
        end,
    }
end