require"fruit"

fruits = {}
score = 0

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
    print("SCORE: ", score)
end

function love.draw()
    for _, fruit_instance in ipairs(fruits) do
        fruit_instance.draw()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then

        -- check fruit colision and add score
        for _, fruit_instance in ipairs(fruits) do
            if fruit_instance.checkMouseCollision(x, y) then
                score = score + fruit_instance.getScore()
            end
        end
    end
end
