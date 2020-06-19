Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.dx = (math.random(2) == 1 and math.random(100, 160) or - math.random(100, 160))
    self.dy = -math.random(140, 180)
    self.width = width
    self.height = height
end

-- block collide
function Ball:collides(block, dt)
    self.collide = false
    if block.hp > 0 then
        if (self.y > block.y + block.height and self.y + self.dy * dt > block.y + block.height) or
        (self.y + self.height < block.y and self.y + self.height + self.dy * dt < block.y) then

        elseif (self.x > block.x + block.width and self.x + self.dx * dt > block.x + block.width) or
        (self.x + self.width < block.x and self.x + self.width + self.dx * dt < block.x) then

        else
            self.collide = true
            
            -- case of ball coming from down to up
            if (self.y > block.y + block.height and 
                    self.y + self.dy * dt <= block.y + block.height) then
                self.dy = -self.dy
                self.y = block.y + 5

            -- case of ball coming from up to down
            elseif  (self.y + self.height < block.y and 
            self.y + self.height + self.dy * dt >= block.y) then
                self.dy = -self.dy
                self.y = block.y - 5
            elseif  (self.x <= block.x + block.width or 
                    self.x + self.dx * dt <= block.x + block.width) then
                self.dx = - self.dx
                
            end
        end
        return self.collide
    end
end


-- paddle collide (special variables added to adjust the angle)
function Ball:PaddleCollide(player, dt)
    self.paddleCollide = false
    -- verticle collision
    if (self.y > player.y + player.height and self.y + self.dy * dt > player.y + player.height) or
        (self.y + self.height < player.y and self.y + self.height + self.dy * dt < player.y) then

    -- horizontal collision
    elseif (self.x > player.x + player.width and self.x + self.dx * dt > player.x + player.width) or
        (self.x + self.width < player.x and self.x + self.width + self.dx * dt < player.x) then

    else
        sounds['paddle_hit']:play()
        self.ran = math.random(20)
        self.ran = self.ran - 10
        if (self.y <= player.y + player.height or self.y + self.dy * dt <= player.y + player.height) then
            if self.dy > 0 then
                self.dy = -self.dy
            end
            -- divide by time constant here compensate the bug that 
                -- the ball's y position is too close to the paddle
            self.y = player.y + math.min(-5, self.dy / 30)
            self.dx = 200 * time_constant * math.sin(((self.x - (player.x + player.width / 2) + self.ran) / math.abs(player.width / 2 + 10)) * math.pi / 2)
             
            -- may be a bug here when 2 players overlap their paddles
                -- and if the ball collides on it, may pass through
        elseif (self.x <= player.x + player.width or self.x + self.dx * dt <= player.x + player.width) then
            self.dx = -self.dx
        end
    end
end

function Ball:update(dt)
        self.x = self.x + self.dx * dt * time_constant
        self.y = self.y + self.dy * dt * time_constant
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end