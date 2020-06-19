Map = Class{}

require 'Bricks'

BRICK_WIDTH = 30
BRICK_HEIGHT = 5

function Map:init()
    self.bricks = {}
    self.brickWidth = 30
    self.brickHeight = 5
    self.hp = 1
    self.numBrickBroken = 0
    self:bricksGenerate()
end

function Map:bricksGenerate()
    for i = 1, 10 do
        for j = 1, 10 do
            self.bricks[10 * i + j] = Bricks(BRICK_WIDTH, BRICK_HEIGHT, self.hp, 5 + 35 * j, 15 + 10 * i)
        end
    end
end

function Map:update(dt)
    self.numBrickBroken = 0
    for i = 1, 10 do
        for j = 1, 10 do
            -- update bricks
            self.bricks[10 * i + j]:update(dt)

            -- update broken bricks to detect victory
            if self.bricks[10 * i + j].hp <= 0 then
                self.numBrickBroken = self.numBrickBroken + 1
            end
        end
    end
end

function Map:render()
    love.graphics.setColor(255/255, 255/255, 255/255)
    -- bricks render
    for i = 1, 10 do
        for j = 1, 10 do
            self.bricks[10 * i + j]:render()
            -- draw rectangle
            if self.bricks[10 * i + j].hp > 0 then
                love.graphics.setColor(255/255, 255/255, 255/255, self.bricks[10 * i + j].hp * 51 / 255)
                love.graphics.rectangle('fill', self.bricks[10 * i + j].x, 
                    self.bricks[10 * i + j].y, BRICK_WIDTH, BRICK_HEIGHT)
            end
        end
    end
end