require "fruit"
require "bomb"
require "coroutine_aux"

local fruits = {}
local bombs = {}

local score = 0
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
local state = GAME_STATE.Menu

function draw_logo()
    love.graphics.push() -- save transformation properties
    local img_w = logo_image:getWidth()
    local img_h = logo_image:getHeight()
    love.graphics.scale(0.5, 0.5) -- image is 500x500 so by scaling to 0.5 the scaled image becomes 256x256
    love.graphics.draw(logo_image, 2*love.graphics.getWidth()/2 - img_w/2, 2*love.graphics.getHeight()/3 - img_h/2) -- we multiply by 2 to compensate for the scaled graphics
    love.graphics.pop() -- load transformation properties

    local img_w = title_image:getWidth()
    local img_h = title_image:getHeight()
    love.graphics.draw(title_image, love.graphics.getWidth()/2 - img_w/2, 10)
    love.graphics.printf("Press 'S' to start", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
end

function print_lost_fruits()
  local font = love.graphics.newFont(32)
  love.graphics.setFont(font)
  
  if dead_seq == 0 then
    love.graphics.setColor(0, 0, 1, 1)
    
    love.graphics.print("X", 100, 30)
    love.graphics.print("X", 125, 30)
    love.graphics.print("X", 150, 30)
  end 
  
  if dead_seq == 1 then
    love.graphics.setColor (1, 0, 0, 1)
    love.graphics.print("X", 100, 30)
    
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.print("X", 125, 30)
    love.graphics.print("X", 150, 30)
  end
  
  if dead_seq == 2 then
    love.graphics.setColor (1, 0, 0, 1)
    love.graphics.print("X", 100, 30)
    love.graphics.print("X", 125, 30)
    
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.print("X", 150, 30)
  end
  
  if dead_seq == 3 then
    love.graphics.setColor (1, 0, 0, 1)
    love.graphics.print("X", 100, 30)
    love.graphics.print("X", 125, 30)
    love.graphics.print("X", 150, 30)
  end
  
end

function love.load()
    width, height = love.graphics.getDimensions()
    logo_image = love.graphics.newImage("logo.png")
    title_image = love.graphics.newImage("title.png")
    bg = love.graphics.newImage("Images/1318898.jpeg")
end


function love.update(dt)
    if state ~= GAME_STATE.Running then
        return
    end

    -- Run Scheduler tasks
    scheduler.setDt(dt)
    scheduler.executeComputation()

    spawnTimer = spawnTimer + dt
    difficulty_timer = difficulty_timer + dt
    
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
      spawnTimer = spawnTimer - spawnInterval
    end
end

function love.draw()
    if state == GAME_STATE.Menu then
        love.graphics.setBackgroundColor({117/255, 59/255, 0/255})
        draw_logo()
    elseif state == GAME_STATE.Running then
        
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(bg, 0, 0, 0, screenWidth / bg:getWidth(), screenHeight / bg:getHeight())
        print_lost_fruits()
        for _, fruit_instance in ipairs(fruits) do
            fruit_instance.draw()
        end
        for _, bomb_instance in ipairs(bombs) do
            bomb_instance.draw()
        end

        -- Execute Scheduler tasks
        scheduler.executePrint()

    elseif state == GAME_STATE.Over then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.printf("Game Over\nFinal Score: " .. score, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press 'R' to restart", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
        love.graphics.printf("Press 'M' to go to Menu", 0, love.graphics.getHeight() / 2 + 100, love.graphics.getWidth(), "center")

    end
end

function love.mousepressed(x, y, button)
    if button == 1 and state == GAME_STATE.Running then

        -- check fruit colision and add score
        for _, fruit_instance in ipairs(fruits) do
            if fruit_instance.checkMouseCollision(x, y) == FRUIT_STATE.Cutted then
                fruit_score =  fruit_instance.getScore()
                fruit_cut = {pos_x=x+20, pos_y=y-20}
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
    if key == "m" and state == GAME_STATE.Over then
        state = GAME_STATE.Menu
    end
end

-- COMPUTE TASKS
function compute_dead(dt)
    local dead_over = false
    while state == GAME_STATE.Running do
        for i = #fruits, 1, -1 do
            fruits[i].update(dt)
            if fruits[i].getState() == FRUIT_STATE.Dead then
                table.remove(fruits, i)
                if cutted_alive_count == 0 then
                    combo_seq = 0
                    dead_seq = dead_seq + 1
                    if dead_seq >= 3 then
                        state = GAME_STATE.Over -- replace for kill
                    end
                else
                    cutted_alive_count = cutted_alive_count - 1
                end
            end
        end
        for i = #bombs, 1, -1 do
            bombs[i].update(dt)
            if not bombs[i].isAlive() then
                table.remove(bombs, i)
            end
        end
        dt = coroutine.yield()
    end
end

function compute_combo()
    local combo_list = {1, 5, 10, 25, 100}
    while state == GAME_STATE.Running do
        if fruit_score ~= nil then -- detected fruit cut
            combo_seq = combo_seq + 1
            combo_mult = combo_list[math.floor(combo_seq / 5) + 1]
            dead_seq = 0
            cutted_alive_count = cutted_alive_count + 1
        elseif combo_seq == 0 then
            combo_mult = 1
        end
        coroutine.yield()
    end
    state = GAME_STATE.Over
end

function compute_score()
    while state == GAME_STATE.Running do
        if fruit_score ~= nil then
            local combo_score = fruit_score * combo_mult
            score = score + combo_score
            print_score(combo_score, fruit_cut)
            fruit_cut = nil
            fruit_score = nil
        end
        coroutine.yield()
    end
end

-- PRINT TASKS
function show_fixed_score()
    while state == GAME_STATE.Running do
        local font = love.graphics.newFont(18)
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Score: " .. score,     love.graphics.getWidth() - 100, 10)
        love.graphics.print("Combo: " .. combo_mult,     100, 10)
    
        coroutine.yield()
    end
end
function print_score(score, pos_print)
    function show_fruit_score(dt)
        local score_time = 2
        local font_value = 12
        while state == GAME_STATE.Running and score_time > 0 do
            love.graphics.setColor(1, 1, 1, 1)
            local font = love.graphics.newFont(font_value)
            love.graphics.setFont(font)
            love.graphics.print("" .. score, pos_print.pos_x, pos_print.pos_y)
            score_time = score_time - dt
            font_value = font_value + 3*dt
            dt = coroutine.yield()
        end
    end

    scheduler.addPrintTask(show_fruit_score)
end
function setGame()
    love.graphics.setBackgroundColor({117/255, 59/255, 0/255})
    math.randomseed(os.time())
    score = 0
    spawnTimer = 0 
    spawnInterval = 3 -- every 3 seconds
    difficulty_timer = 0
    difficulty_interval = 20 -- every 20 seconds
    difficulty_factor = 0  -- initially 0
    dead_seq = 0
    combo_mult = 1
    combo_seq = 0
    cutted_alive_count = 0
    
    scheduler = get_scheduler()

    scheduler.addComputationTask(compute_dead)
    scheduler.addComputationTask(compute_combo)
    scheduler.addComputationTask(compute_score)
    
    scheduler.addPrintTask(show_fixed_score)
    
    fruits = {}
    bombs = {}
    
    for i = 1, 2 do
        table.insert(fruits, newFruit())
    end
    for i = 1, 2 do
        table.insert(bombs, newBomb())
    end
    state = GAME_STATE.Running
end
