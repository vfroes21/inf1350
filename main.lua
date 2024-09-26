require "fruit"
require "bomb"

fruits = {}
bombs = {}

score = 0
GAME_STATE = {
    Menu = 1,
    Running = 2,
    Over = 3
}

local spawnTimer = 0 
local spawnInterval = 3 -- every 3 seconds
local difficulty_timer = 0
local difficulty_interval = 20 -- every 20 seconds
local difficulty_factor = 0  -- initially 0

state = GAME_STATE.Menu

function draw_logo()
    love.graphics.push() -- save transformation properties
    local img_w = logo_image:getWidth()
    local img_h = logo_image:getHeight()
    love.graphics.scale(0.5, 0.5) -- image is 500x500 so by scaling to 0.5 the scaled image becomes 256x256
    love.graphics.draw(logo_image, 2*width/2 - img_w/2, 2*height/3 - img_h/2) -- we multiply by 2 to compensate for the scaled graphics
    love.graphics.pop() -- load transformation properties

    local img_w = title_image:getWidth()
    local img_h = title_image:getHeight()
    love.graphics.draw(title_image, width/2 - img_w/2, 10)
    love.graphics.printf("Press 'S' to start", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
end
function love.load()
    width, height = love.graphics.getDimensions()
    logo_image = love.graphics.newImage("logo.png")
    title_image = love.graphics.newImage("title.png")
    --setGame()
end

function love.update(dt)
    spawnTimer = spawnTimer + dt
    difficulty_timer = difficulty_timer + dt
    
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
    
    if difficulty_timer >= difficulty_interval then
      difficulty_factor = difficulty_factor + 1
      
      difficulty_timer = difficulty_timer - difficulty_interval
    end
    
    if spawnTimer >= spawnInterval then
      for i = 1, 2 + difficulty_factor do
        table.insert(fruits, newFruit())
      end
      for i = 1, 2 + difficulty_factor  do
        table.insert(bombs, newBomb())
      end
      spawnTimer = spawnTimer - spawnInterval -- Reset timer (can subtract to allow for slightly over 5 seconds)
    end
end

function love.draw()
    if state == GAME_STATE.Menu then
        love.graphics.setBackgroundColor({117/255, 59/255, 0/255})
        draw_logo()
    elseif state == GAME_STATE.Running then
        for _, fruit_instance in ipairs(fruits) do
            fruit_instance.draw()
        end
        for _, bomb_instance in ipairs(bombs) do
            bomb_instance.draw()
        end
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Score: " .. score,     love.graphics.getWidth() - 100, 10)
    elseif state == GAME_STATE.Over then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.printf("Game Over\nFinal Score: " .. score, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press 'R' to restart", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and state == GAME_STATE.Running then

        -- check fruit colision and add score
        for _, fruit_instance in ipairs(fruits) do
            if fruit_instance.checkMouseCollision(x, y) then
                score = score + fruit_instance.getScore()
            end
        end
        for _, bomb_instance in ipairs(bombs) do
            if bomb_instance.checkMouseCollision(x, y) then
                state = GAME_STATE.Over
                break
            end
        end
    end
end

function love.keypressed(key)
    if key == "r" and state == GAME_STATE.Over then
        setGame()
    end
    if key == "s" and state == GAME_STATE.Menu then
        setGame()
    end
end

function setGame()
    love.graphics.setBackgroundColor({117/255, 59/255, 0/255})
    math.randomseed(os.time())
    score = 0
    state = GAME_STATE.Running

    fruits = {}
    bombs = {}

    for i = 1, 2 do
        table.insert(fruits, newFruit())
    end
    for i = 1, 2 do
        table.insert(bombs, newBomb())
    end
end
