require "fruit"
require "bomb"

fruits = {}
bombs = {}

score = 0
gameOver = false

function love.load()
    setGame()
end

function love.update(dt)
    for i = #fruits, 1, -1 do
        fruits[i].update(dt)
        if not fruits[i].isAlive() then
            table.remove(fruits, i)
        end
    end
    for i = #bombs, 1, -1 do
        bombs[i].update(dt)
        if not bombs[i].isAlive() then
            table.remove(bombs, i)
        end
    end
    print("SCORE: ", score)
end

function love.draw()
    if not gameOver then
        for _, fruit_instance in ipairs(fruits) do
            fruit_instance.draw()
        end
        for _, bomb_instance in ipairs(bombs) do
            bomb_instance.draw()
        end
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Score: " .. score,     love.graphics.getWidth() - 100, 10)
    else
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.printf("Game Over\nFinal Score: " .. score, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press 'R' to restart", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and not gameOver then

        -- check fruit colision and add score
        for _, fruit_instance in ipairs(fruits) do
            if fruit_instance.checkMouseCollision(x, y) then
                score = score + fruit_instance.getScore()
            end
        end
        for _, bomb_instance in ipairs(bombs) do
            if bomb_instance.checkMouseCollision(x, y) then
                gameOver = true
                break
            end
        end
    end
end

function love.keypressed(key)
    if key == "r" and gameOver then
      setGame()
    end
end

function setGame()
    love.graphics.setBackgroundColor({117/255, 59/255, 0/255})
    math.randomseed(os.time())
    score = 0
    gameOver = false

    fruits = {}
    bombs = {}

    for i = 1, 5 do
        table.insert(fruits, newFruit())
    end
    for i = 1, 5 do
        table.insert(bombs, newBomb())
    end
end
