require 'Rocket'
require 'Map'

Player = Class{}


-- initial function
function Player:init(x, y)
    self.x = x
    self.y = y
    self.width = 30
    self.height = 5
    self.dx = 0
    PADDLE_SPEED = 275

    --rocket information
    self.rocket = Rocket(self)

    -- number of item (max. 3)
    self.rocket_calling = 1
    self.ball_calling = 1
    self.big_paddle_calling = 1
end

-- update function
function Player:update(dt)
    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
    self.rocket:update(self.x, self.width, dt)

    for i = 1, 10 do
        for j = 1, 10 do
            self:collide(map.bricks[10 * i + j], dt)
        end
    end
end

-- item capsule collide with paddle
function Player:collide(capsule, dt)
    local collision = false
    -- verticle collision
    if (capsule.item_y > self.y + self.height and capsule.item_y + capsule.item_dy * dt > self.y + self.height) or
        (capsule.item_y + capsule.item_height < self.y and capsule.item_y + capsule.item_height + capsule.item_dy * dt < self.y) then

    -- horizontal collision
    elseif (capsule.item_x > self.x + self.width and capsule.item_x + capsule.item_dx * dt > self.x + self.width) or
        (capsule.item_x + capsule.item_width < self.x and capsule.item_x + capsule.item_width + capsule.item_dx * dt < self.x) then

    else
        collision = true
        -- set the item out of the height to make it disappear
        capsule.item_y = VIRTUAL_HEIGHT + 20
        sounds['item_get']:play()
        if capsule.item == 'Rocket' then
            self.rocket_calling = self.rocket_calling + 1
        elseif capsule.item == 'Ball' then
            self.ball_calling = self.ball_calling + 1
        end
    end
end

-- weapon creation
function Player:weapon()

end

-- render function
function Player:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end