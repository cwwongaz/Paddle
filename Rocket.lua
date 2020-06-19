require 'love.timer'
Rocket = Class{}

function Rocket:init(Player)
    self.spritesheet = love.graphics.newImage('graphics/rocket.png')
    self.explosion = love.graphics.newImage('graphics/bang.png')
    self.player = Player
    -- rocket parameters
    self.x = self.player.x
    self.y = self.player.y
    self.dx = 0
    self.dy = -150
    self.width = 8
    self.height = 15
    -- explosion effect parameters
    self.explodeX = 0
    self.explodeY = 0
    self.explode_width = 125
    self.explode_height = 109
    self.hitting = true
    self.timer = 1
end

function Rocket:update(x, width, dt)

    if self.hitting == false then
        -- update y coordinate of rocket
        self.y = self.y + self.dy * dt

        -- check whether the rocket hit the bricks
        for i = 1, 10 do
            for j = 1, 10 do
                if map.bricks[10 * i + j] ~= nil then
                    self:hit(map.bricks, map.bricks[10 * i + j], dt)
                end
            end
        end
    end


    -- check the rocket hit the upper wall
    if self.y < 0 then
        self.hitting = true
        self.explodeX, self.explodeY = self.x, self.y
        self:explode(map.bricks, self.x + self.width / 2, self.y + self.width / 2)
        -- reset rocket position to prevent the hit function keep triggering
        self:reset()
    end

    --count timer
    if self.timer < 1 then
        self.timer = (self.timer + dt)
    else
        self.timer = 1
    end
end

function Rocket:hit(bricks, block, dt)
    if block.hp > 0 then
        if self.x < block.x and self.x + self.width < block.x then
        elseif self.x > block.x and self.x > block.x + block.width then
        else
            if self.y >= block.y + block.height and self.y + self.dy * dt < block.y + block.height then
                self.hitting = true
                self.explodeX, self.explodeY = self.x, self.y
                self:explode(bricks, self.x + self.width / 2, self.y + self.width / 2)
                self:reset()
            end
        end
    end
end

function distant(block, x, y)
    dist = math.sqrt((block.x + map.brickWidth / 2 - x) * (block.x + map.brickWidth / 2 - x) 
                + (block.y + map.brickHeight / 2 - y) * (block.y + map.brickHeight / 2 - y))
    return dist
end

function Rocket:explode(bricks, x, y)
    local range = 75

    for i = 1, 10 do
        for j = 1, 10 do
            if distant(bricks[10 * i + j], x, y) <= range then
                bricks[10 * i + j].hp = 0
            end
        end
    end
end


function Rocket:reset()
    self.x, self.y = 
            (self.player.x + (self.player.width) / 2 - self.width), self.player.y - self.height
end

function Rocket:explosionEffect()
    -- to make explosion effect when entering the screen
    local t = self.timer
    return math.exp(-12 * (t - 0.5) * (t - 0.5)) / 6
end

function Rocket:render()

    if self.hitting == false then
        love.graphics.setColor(255/255, 255/255, 255/255)
        love.graphics.draw(self.spritesheet,
                    self.x, self.y, 0, 0.02, 0.02)
        self.timer = 0
        self.exploded = false

    elseif self.hitting == true then
        -- self.exploded is used to make the sound trigger once
        if self.exploded == false then
            sounds['explode']:play()
        end
        self.exploded = true

        -- render the explosion effect
        local stopTimer = 0.75
        love.graphics.setColor(255/255, 255/255, 255/255)
        if self.timer < stopTimer then
            -- draw the explosion icon, set the scale to be x, y = 0.1, 0.1 at the maximal
                -- and start to draw the icon from its center point
                love.graphics.draw(self.explosion,
                    self.explodeX, self.explodeY,
                        0, self:explosionEffect(), self:explosionEffect(),
                        self.explosion:getWidth() / 2, self.explosion:getHeight() / 2)
        end
    end
end