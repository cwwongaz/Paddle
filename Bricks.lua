Bricks = Class{}

NUMBER_OF_ITEM = 2

function Bricks:init(width, height, hp, x, y)
    -- brick parameters
    self.width = width
    self.height = height
    self.hp = hp
    self.x = x
    self.y = y

    -- item parameters
    self.item = ''
    self.item_x = self.x
    self.item_y = self.y
    self.item_width = 5
    self.item_height = 5
    self.item_dx = 0
    self.item_dy = 50
    self.item_isCalled = false
    self.item_drop = false
end

function Bricks:update(dt)
    -- drop item at a possibility
    if self.hp <= 0 and self.item_isCalled == false then
        if math.random(20) == 5 then
            self.item_drop = true

            -- Decide which item to drop 
            local num = math.random(NUMBER_OF_ITEM)

            if num == 1 then
                self.item = 'Rocket'
            elseif num == 2 then
                self.item = 'Ball'
            end
        end
        self.item_isCalled = true
    end

    if self.item_isCalled == true and self.item_drop == true then
        self.item_y = self.item_y + self.item_dy * dt * time_constant
    end

    if self.item_y > VIRTUAL_HEIGHT then
        self.drop = false
    end

end


function Bricks:render()
    if self.item_drop == true then
        love.graphics.setColor(255/255, 255/255, 255/255)
        if self.item == 'Ball' then
            love.graphics.printf('B', self.item_x, self.item_y, VIRTUAL_WIDTH)
        elseif self.item == 'Rocket' then
            love.graphics.printf('R', self.item_x, self.item_y, VIRTUAL_WIDTH)
        end
    end
end