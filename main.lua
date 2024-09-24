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

    local co = coroutine.create(function()
        while y <= love.graphics.getHeight() + radius do
            coroutine.yield()
        end
        alive = false
    end)

    return {
        update = function(dt)
            x = x + xSpeed * dt
            y = y + ySpeed * dt
            ySpeed = ySpeed + 600 * dt
            if coroutine.status(co) ~= "dead" then
                coroutine.resume(co)
            end
        end,

        checkMouseCollision = function(mx, my)
            local distance = math.sqrt((x - mx)^2 + (y - my)^2)
            if distance < radius then
                alive = false
                return true
            end
            return false
        end,

        draw = function()
            if alive then
                love.graphics.setColor(color)
                love.graphics.circle("fill", x, y, radius)
            end
        end,

        isAlive = function()
            return alive
        end
    }
end

fruits = {}

function love.load()
    math.randomseed(os.time())
    for i = 1, 5 do
        table.insert(fruits, newFruit())
    end
end

function love.update(dt)
    for i = #fruits, 1, -1 do
        fruits[i].update(dt)
        if not fruits[i].isAlive() then
            table.remove(fruits, i)
        end
    end
end

function love.draw()
    for _, fruit in ipairs(fruits) do
        fruit.draw()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        for _, fruit in ipairs(fruits) do
            fruit.checkMouseCollision(x, y)
        end
    end
end
