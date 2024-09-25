require "love"
require "coroutine"
require "coroutine_aux"

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
            local distance = math.sqrt((x - frame_mx)^2 + (y - frame_my)^2)
            if distance < radius then
                alive = false
                local result = true
            end
            local result = false
            coroutine.yield(result)
        end
    end)

    return {
        update = function(dt)
            frame_dt = dt
            run_coroutine(co_table, "alive")
            run_coroutine(co_table, "update")
        end,

        checkMouseCollision = function(mx, my)
            frame_mx = mx
            frame_my = my
            run_coroutine(co_table, "collision_check")
        end,

        draw = function()
            run_coroutine(co_table, "draw")
        end,
        isAlive = function()
            return alive
        end,
        getScoreValue = function()
            return love.math.floor(900/fruitsData[fruitType].radius)
        end
    }
end

--[[mouse = {}
circle = {}

function love.load()
	circle.x = 300
	circle.y = 300

	circle.speed = 300
end

function love.update(dt)
	mouse.x, mouse.y = love.mouse.getPosition()

	if circle.x < mouse.x then
		circle.x = circle.x + (circle.speed * 2.5 * dt)
	end
	if circle.x > mouse.x then
		circle.x = circle.x - (circle.speed * 2.5 * dt)
	end
	if circle.y < mouse.y then
		circle.y = circle.y + (circle.speed * 2.5 * dt)
	end
	if circle.y > mouse.y then
		circle.y = circle.y - (circle.speed * 2.5 * dt)
	end
end

function love.draw()
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", circle.x, circle.y, 50)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Mouse Coordinates: " .. mouse.x .. ", " .. mouse.y)
end ]]--
