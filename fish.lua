--This object will be used for all fish drawn
Fish = Entity:extend()

function Fish:new(x, y, imagePath)
  Fish.super.new(self, x, y, imagePath)
  
  self.moveSpeed = 50
  self.size = 1
  self.currentRotation = 0
  self.moveRotation = 0.2
  self.realWidth, self.realHeight, self.realX, self.realY = self:getRealDimensions()
  
  -- 1 represents facing right, -1 represents facing left
  self.faceDirection = 1
  
  self.moveTime = love.math.random(5, 30)
  self.timer = self.moveTime
end

function Fish:update(dt)
  self:moveFish(dt)
end

function Fish:draw()
  love.graphics.draw(self.image, self.x, self.y, self.currentRotation, self.size * self.faceDirection, self.size, self.width / 2, self.height / 2)
end
  
function Fish:moveFish(dt)
  self.timer = self.timer + dt
  
  if self.timer > self.moveTime / 10 then
    self.currentRotation = 0
    self.moveDirection = love.math.random(5)
    self.moveTime  = love.math.random(5, 30)
    self.timer = 0
  end
  
  if self.moveDirection == 1 then
    -- Have fish face left if moving left
    self.faceDirection = -1
    self.x = self.x - self.moveSpeed * dt
  end
  
  if self.moveDirection == 2 then
    -- Have player face right if moving right
    self.faceDirection = 1
    self.x = self.x + self.moveSpeed * dt
  end
  if self.moveDirection == 3 then
    self.currentRotation = -self.moveRotation * self.faceDirection
    self.y = self.y - self.moveSpeed * dt
  end
  if self.moveDirection == 4 then
    self.currentRotation = self.moveRotation * self.faceDirection
    self.y = self.y + self.moveSpeed * dt
  end
  if self.moveDirection == 5 then
    self.currentRotation = 0
  end
end

function Fish:getRealDimensions()
  local minX = self.width - 1
  local maxX = 0
  local minY = self.height - 1
  local maxY = 0
  
  for y = 0, self.height - 1 do
    for x = 0, self.width - 1 do
      local r, g, b, a = self.imageData:getPixel(x, y)
      if not (r == 0 and g == 0 and b == 0 and a == 0) then
        if x < minX then
          minX = x
        elseif x > maxX then
          maxX = x
        end
        if y < minY then
          minY = y
        elseif y > maxY then
          maxY = y
        end
      end
    end
  end
  -- return real width and height of image after removing the blank space
  return maxX - minX, maxY - minY, minX, minY
end