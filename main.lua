Class = require 'class'
push = require 'push'

require 'Ball'
require 'Map'
require 'Player'
require 'Rocket'

-- close resolution to NES but 16:9
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- set font 
font = love.graphics.newFont('fonts/font.ttf', 16)

font_explain = love.graphics.newFont('fonts/font.ttf', 8)

-- actual window resolution
WINDOW_WIDTH = 720
WINDOW_HEIGHT = 405

-- seed RNG
math.randomseed(os.time())

-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')


function love.load()
    -- set up virtual screen resolution for an authentic retro feel
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })

    love.window.setTitle('Paddle')

    -- system function, autometically called whenever window resized
    function love.resize(w, h)
        push:resize(w, h)
    end    

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['explode'] = love.audio.newSource('sounds/explode.wav', 'static'),
        ['lose'] = love.audio.newSource('sounds/lose.wav', 'static'),
        ['win'] = love.audio.newSource('sounds/win.wav', 'static'),
        ['rocket_shoot'] = love.audio.newSource('sounds/rocket_shoot.wav', 'static'),
        ['slow_motion'] = love.audio.newSource('sounds/slow_motion.wav', 'static'),
        ['big_paddle'] = love.audio.newSource('sounds/big_paddle.wav', 'static'),
        ['clone'] = love.audio.newSource('sounds/clone.wav', 'static'),
        ['block_breaks'] = love.audio.newSource('sounds/block_breaks.wav', 'static'),
        ['item_get'] = love.audio.newSource('sounds/item_get.wav', 'static'),
        ['play_mode'] = love.audio.newSource('sounds/play_mode.wav', 'static')
    }
    -- set volume of a sound track
    --sounds['slow_motion']:setVolume(1)

    gameState = 'start'

    -- slow motion controller
    time_constant = 1

    cursor = '1'

    difficulty = '1'

    -- slow motion indicator
    slow = false
    remain_time = 10

    slow_coolDown = 0

    -- an object to contain our map data
    map = Map()

    player1 = Player((VIRTUAL_WIDTH - 25) / 2, VIRTUAL_HEIGHT - 25)

    BALL = {}
    for i = 1, 10 do
        BALL[i] = nil
    end

    -- player 1 serve the ball
    serve = false

    BALL[1] = Ball(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 5, 5)
    BALL[1].dx, BALL[1].dy = 0, 0

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end


-- update function
function love.update(dt)
    -- update the map
    map:update(dt)

    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
    
    if cursor == '1' then
        player1:update(dt)
    elseif cursor == '2' then
        if math.random(2) == 1 then
            player1:update(dt)
            player2:update(dt)
        else
            player2:update(dt)
            player1:update(dt)
        end
    end
    -- update paddle move
    PlayerMove(dt)

    if serve == true then
        BALL[1].x = player1.x + player1.width / 2 - BALL[1].width / 2
        BALL[1].y = player1.y - BALL[1].width - 5
    end
    
    if gameState == 'play' then
        -- update ball
        for i = 1, 10 do
            if BALL[i] then
                BALL[i]:update(dt)
            end
        end
        
        -- collide with brick check
        for i = 1, 10 do
            for j = 1, 10 do
                for k = 1, 10 do
                    if BALL[k] ~= nil and BALL[k]:collides(map.bricks[10 * i + j], dt) then
                        map.bricks[10 * i + j].hp = map.bricks[10 * i + j].hp - 1
                        if BALL[k].collide == true then
                            sounds['block_breaks']:play()
                        else 
                            sounds['block_breaks']:stop()
                        end
                    end
                end
            end
        end

    end

     -- check colliding with walls
    for k = 1, 10 do 
        if BALL[k] == nil then

        elseif BALL[k].x > VIRTUAL_WIDTH - 5 or BALL[k].x < 0 then
            sounds['wall_hit']:play()
            if BALL[k].x > VIRTUAL_WIDTH - 5 then
                BALL[k].x = VIRTUAL_WIDTH - 5
            elseif BALL[k].x < 0 then
                BALL[k].x = 5
            end
            BALL[k].dx = -BALL[k].dx
        elseif BALL[k].y < 0 then 
            sounds['wall_hit']:play()
            BALL[k].y = 5
            BALL[k].dy = -BALL[k].dy
        end
    end

    -- paddle ball collision
    for i = 1, 10 do
        if BALL[i] == nil then

        else
            BALL[i]:PaddleCollide(player1, dt)
            if cursor == '2' then
                BALL[i]:PaddleCollide(player2, dt)
            end
        end
    end

    
    for i = 1, 10 do
        -- delete outrange balls
        if BALL[i] ~= nil then
            if BALL[i].y > VIRTUAL_HEIGHT then
                BALL[i] = nil
            end
        end
    end

    -- winning / losing boolean
    WinningLosing()

    if slow == true and gameState == 'play' then
        sounds['slow_motion']:play()
    else
        sounds['slow_motion']:stop()
    end

    if remain_time > 0 then
        remain_time = remain_time - dt
    elseif remain_time - dt <= 0 then
        remain_time = 0
        slow = false
        time_constant = 1
    end

    if slow_coolDown > 0 and slow == false then
        slow_coolDown = slow_coolDown - dt
    elseif slow_coolDown < 0 then
        slow_coolDown = 0
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    -- set up game state
    if gameState == 'start' and (key == 'enter' or key == 'return') then
        WinningStatus = ''
        sounds['play_mode']:play()
        gameState = 'play'
        serve = true
    elseif gameState == 'finish' and (key == 'enter' or key == 'return') then
        love.load()
        gameState = 'start'
        cursor = '1'
    end

    -- select single player or double players
    if gameState == 'start' then
        if key == 'up' then
            sounds['paddle_hit']:play()
            cursor = tostring((tonumber(cursor) % 2 + 1))
            if cursor == '2' then
                player1 = Player(VIRTUAL_WIDTH / 2 - 50 - 25, VIRTUAL_HEIGHT - 25)
                player2 = Player(VIRTUAL_WIDTH / 2 + 50, VIRTUAL_HEIGHT - 25)
            end

        elseif key == 'down' then
            sounds['paddle_hit']:play()
            cursor = tostring((tonumber(cursor) % 2 + 1))
            if cursor == '2' then
                player1 = Player(VIRTUAL_WIDTH / 2 - 50 - 25, VIRTUAL_HEIGHT - 25)
                player2 = Player(VIRTUAL_WIDTH / 2 + 50, VIRTUAL_HEIGHT - 25)
            end
        end

        if key  == 'left' then
            sounds['paddle_hit']:play()
            difficulty = tostring((tonumber(difficulty - 1) % 3))
            if difficulty == '0' then
                difficulty = '3'
            end

            if difficulty == '1' then
                map.hp = 1
            elseif difficulty == '2' then
                map.hp = 3
            elseif difficulty == '3' then
                map.hp = 5
            end
            map:bricksGenerate()

        elseif key == 'right' then
            sounds['paddle_hit']:play()
            difficulty = tostring((tonumber(difficulty) % 3 + 1))

            if difficulty == '1' then
                map.hp = 1
            elseif difficulty == '2' then
                map.hp = 3
            elseif difficulty == '3' then
                map.hp = 5
            end
            map:bricksGenerate()
        end
    end

    -- special function key
    if gameState == 'play' and serve == false then
        if key == 's' then
            sounds['big_paddle']:play()
            player1.width = 60
        end

        if cursor == '2' and key == 'down' then
            sounds['big_paddle']:play()
            player2.width = 60
        end

        -- ####
        if key == 'n' then
            player1.width = 30
            if cursor == '2' then
                player2.width = 30
            end
        end

        -- slow motion
        if key == 'space' and slow == false and slow_coolDown == 0 then
            slow = true
            slow_coolDown = 10
            remain_time = 10
            time_constant = 1/2
        end

        -- summand the balls
        if key == 'lshift' and player1.ball_calling > 0 then
            sounds['clone']:play()
            summandBall()
            player1.ball_calling = player1.ball_calling - 1
        end

        if key == 'rshift' and player2.ball_calling > 0 then
            sounds['clone']:play()
            summandBall()
            player2.ball_calling = player2.ball_calling - 1
        end

        -- summand rocket
        if key == 'w' and player1.rocket.timer >= 1 then
            if player1.rocket_calling > 0 then
                sounds['rocket_shoot']:play()
                -- reset summand
                summandRocket(player1)
                player1.rocket_calling = player1.rocket_calling - 1
            end
        end

        -- the player2.rocket.timer >= 1 is for summanding 
            -- the rocket after the explosion effect finished 
        if key == 'up' and cursor == '2' and
                            player2.rocket.timer >= 1 then
            if player2.rocket_calling > 0 then
                sounds['rocket_shoot']:play()
                -- summand rocket
                summandRocket(player2)
                player2.rocket_calling = player2.rocket_calling - 1
            end
        end
    end

    -- start the game
    if serve == true and gameState == 'play' then
        if key == 'space' then
            BALL[1].dx = (math.random(2) == 1 and math.random(100, 160) or - math.random(100, 160))
            BALL[1].dy = -math.random(140, 180)
            serve = false
        end
    end
end

function WinningLosing()
    WinningStatus = ''
    BALL_NUM = 0
    for i = 1, 10 do
        if BALL[i] ~= nil then
            BALL_NUM = BALL_NUM + 1
        end
    end

    if map.numBrickBroken >= 100 then
        WinningStatus = 'win'
        gameState = 'finish'
    elseif BALL_NUM == 0 then
        WinningStatus = 'lose'
        gameState = 'finish'
    end
end

-- summand rocket to hit the bricks (only 1 roctket on the map)
function summandRocket(player)
    if player.rocket.hitting == true then
        player.rocket.x, player.rocket.y = 
            (player.x + (player.width) / 2 - player.rocket.width), player.y - player.rocket.height
        player.rocket.hitting = false
    end
end

function summandBall()
    for i = 1, 10 do
        if BALL[i] == nil then
            BALL[i] = Ball(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 5, 5)
        end
    end
end


-- move function
function PlayerMove(dt)
    if gameState == 'play' then
        -- player 1 movement
        if love.keyboard.isDown('a') then
            player1.dx = -PADDLE_SPEED * time_constant
            player1.x = player1.x + player1.dx * dt
        elseif love.keyboard.isDown('d') then
            player1.dx = PADDLE_SPEED * time_constant
            player1.x = player1.x + player1.dx * dt
        else
            player1.dx = 0
        end

        -- player 2 movement
        if cursor == '2' then
            if love.keyboard.isDown('left') then
                player2.dx = -PADDLE_SPEED * time_constant
                player2.x = player2.x + player2.dx * dt
            elseif love.keyboard.isDown('right') then
                player2.dx = PADDLE_SPEED * time_constant
                player2.x = player2.x + player2.dx * dt
            else
                player2.dx = 0
            end
        end
    end
end



-- called each frame, used to render to the screen
function love.draw()
    -- begin virtual resilution drawing
    push:apply('start')
    love.graphics.clear(45/255, 45/255, 45/255, 255/255)
    love.graphics.setFont(font)

    if gameState == 'start' then
        love.graphics.setColor(255/255, 255/255, 255/255)
        love.graphics.printf('Welcome to Paddle!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to continue!', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('1 Player', 0, VIRTUAL_HEIGHT / 2 + 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('2 Players', 7, VIRTUAL_HEIGHT / 2 + 50, VIRTUAL_WIDTH, 'center')
        if difficulty == '1' then
            love.graphics.printf('Easy', 0, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
        elseif difficulty == '2' then
            love.graphics.printf('Normal', 0, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
        elseif difficulty == '3' then
            love.graphics.printf('Hard', 0, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
        end

        -- triangles on indigatinf difficulty
        love.graphics.polygon('fill', VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 + 17 - 2.89,
                VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 + 17 + 2.89, VIRTUAL_WIDTH / 2 - 55, VIRTUAL_HEIGHT / 2 + 17)
        love.graphics.polygon('fill', VIRTUAL_WIDTH / 2 + 50, VIRTUAL_HEIGHT / 2 + 17 - 2.89,
                VIRTUAL_WIDTH / 2 + 50, VIRTUAL_HEIGHT / 2 + 17 + 2.89, VIRTUAL_WIDTH / 2 + 55, VIRTUAL_HEIGHT / 2 + 17)


        -- cursor of player selection
        if cursor == '1' then
            love.graphics.polygon('fill', VIRTUAL_WIDTH / 2 - 55, VIRTUAL_HEIGHT / 2 + 37 - 2.89,
                VIRTUAL_WIDTH / 2 - 55, VIRTUAL_HEIGHT / 2 + 37 + 2.89, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 + 37)
        elseif cursor == '2' then
            love.graphics.polygon('fill', VIRTUAL_WIDTH / 2 - 55, VIRTUAL_HEIGHT / 2 + 57 - 2.89,
                VIRTUAL_WIDTH / 2 - 55, VIRTUAL_HEIGHT / 2 + 57 + 2.89, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 + 57)
        end

        -- explain the game control

        -- player 1
        love.graphics.setFont(font_explain)
        love.graphics.printf('A --- left', 10, 150, VIRTUAL_WIDTH)
        love.graphics.printf('D --- right', 10, 160, VIRTUAL_WIDTH)
        local str1 = ' --- Rocket Summand: ' .. tostring(player1.rocket_calling)
        love.graphics.printf('W'..str1, 10, 170, VIRTUAL_WIDTH)
        love.graphics.printf('S --- Big Paddle', 10, 180, VIRTUAL_WIDTH)
        local str2 = ' --- Ball Summand: ' .. tostring(player1.ball_calling)
        love.graphics.printf('Left Shift'..str2, 10, 190, VIRTUAL_WIDTH)
        love.graphics.printf('Space --- slow motion: ', VIRTUAL_WIDTH / 2 - 60, 190, VIRTUAL_WIDTH)
        love.graphics.printf('cd: '..tostring(slow_coolDown - slow_coolDown % 0.01), VIRTUAL_WIDTH / 2 + 40, 190, VIRTUAL_WIDTH)


        -- player 2
        love.graphics.printf('left key --- left', -10, 150, VIRTUAL_WIDTH, 'right')
        love.graphics.printf('right key --- right', -10, 160, VIRTUAL_WIDTH, 'right')
        love.graphics.printf('up key --- Rocket Summand: 1', -10, 170, VIRTUAL_WIDTH, 'right')
        love.graphics.printf('down key --- Big Paddle', -10, 180, VIRTUAL_WIDTH, 'right')
        love.graphics.printf('Right Shift --- Ball Summand: 1', -10, 190, VIRTUAL_WIDTH, 'right')

    elseif gameState == 'play' then
        -- explain how to start the game
        if serve == true then
            love.graphics.printf('Press Space to Serve', 10, 150, VIRTUAL_WIDTH, 'center')
        end

        if slow == true then
            love.graphics.printf('Remain time: ', VIRTUAL_WIDTH / 2 - 65, 150, VIRTUAL_WIDTH)
            love.graphics.printf(tostring(remain_time - remain_time % 0.01 > 0 and remain_time - remain_time % 0.01 or 0), VIRTUAL_WIDTH / 2 + 45, 150, VIRTUAL_WIDTH)
        end


        -- explain the game control
        -- player 1
        love.graphics.setFont(font_explain)
        love.graphics.printf('A --- left', 10, 150, VIRTUAL_WIDTH)
        love.graphics.printf('D --- right', 10, 160, VIRTUAL_WIDTH)
        local str1 = ' --- Rocket Summand: ' .. tostring(player1.rocket_calling)
        love.graphics.printf('W'..str1, 10, 170, VIRTUAL_WIDTH)
        love.graphics.printf('S --- Big Paddle', 10, 180, VIRTUAL_WIDTH)
        local str2 = ' --- Ball Summand: ' .. tostring(player1.ball_calling)
        love.graphics.printf('Left Shift'..str2, 10, 190, VIRTUAL_WIDTH)
        love.graphics.printf('Space --- slow motion: ', VIRTUAL_WIDTH / 2 - 60, 190, VIRTUAL_WIDTH)
        love.graphics.printf('cd: '..tostring(slow_coolDown - slow_coolDown % 0.01), VIRTUAL_WIDTH / 2 + 40, 190, VIRTUAL_WIDTH)


        -- player 2
        if cursor == '2' then
            love.graphics.printf('left key --- left', -10, 150, VIRTUAL_WIDTH, 'right')
            love.graphics.printf('right key --- right', -10, 160, VIRTUAL_WIDTH, 'right')
            local str3 = ' --- Rocket Summand: ' .. tostring(player2.rocket_calling)
            love.graphics.printf('up key'..str3, -10, 170, VIRTUAL_WIDTH, 'right')
            love.graphics.printf('down key --- Big Paddle', -10, 180, VIRTUAL_WIDTH, 'right')
            local str4 = ' --- Ball Summand: ' .. tostring(player2.ball_calling)
            love.graphics.printf('Right Shift'..str4, -10, 190, VIRTUAL_WIDTH, 'right')
        end

        -- ending_sound_played is used to make the sound only play once since the draw function in Lua keeps updating
        ending_sound_played = false

        for i = 1, 10 do
            if BALL[i] ~= nil then
                BALL[i]:render()
            end
        end
        map:render()
        if cursor == '1' then
            love.graphics.setColor(255/255, 255/255, 255/255)
            player1:render()
            player1.rocket:render()
        elseif cursor == '2' then
            love.graphics.setColor(255/255, 100/255, 150/255)
            player1:render()
            player1.rocket:render()
            love.graphics.setColor(100/255, 150/255, 255/255)
            player2:render()
            player2.rocket:render()
        end

    elseif gameState == 'finish' then
        love.graphics.setFont(font)
        -- ending_sound_played is used to make the sound only play once since the draw function in Lua keeps updating
        if WinningStatus == 'win' then
            if ending_sound_played == false then
                sounds['win']:play()
            end
            ending_sound_played = true

            love.graphics.printf('Congratulations, You Win the Game', 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to go back to continue' , 0, 50, VIRTUAL_WIDTH, 'center')
        elseif WinningStatus == 'lose' then
            if ending_sound_played == false then
                sounds['lose']:play()
            end
            ending_sound_played = true

            love.graphics.printf('You Lose the Game', 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to go back to continue' , 0, 50, VIRTUAL_WIDTH, 'center')
        end
    end

    -- end virtual resolution
    push:apply('end')

end