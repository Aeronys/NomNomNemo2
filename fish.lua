--This object will be used for all fish drawn
Fish = Object:extend()

function Fish:new(x, y, image_path)
  self.x = x
  self.y = y
  self.image = love.graphics.newImage(image_path)
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
  
  self.moveSpeed = 50
  self.size = 1
  self.currentRotation = 0
  self.moveRotation = 0.2
  
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
  
  --[[self.x = x
  self.y = y
  self.image = love.graphics.newImage(image_path)
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
  
  self.last = {}
  self.last.x = self.x
  self.last.y = self.y
  
  self.strength = 0
  self.tempStrength = 0
  
  -- Add the gravity and weight properties
  self.gravity = 0
  self.weight = 400 ]]--