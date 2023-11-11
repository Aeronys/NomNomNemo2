-- Player is a fish, so we will extend this class
Player = Fish:extend()

function Player:new(x, y)
  Player.super.new(self, x, y, 'images/PNG/Default size/fishTile_081.png')
  self.moveSpeed = 200
end

function Player:update(dt)
   self:movePlayer(dt)
end

function Player:movePlayer(dt)
  -- Basic wasd and arrow controls for movement
  if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
    -- Have fish face left if moving left
    self.faceDirection = -1
    self.x = self.x - self.moveSpeed * dt
  end
  if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
    -- Have player face right if moving right
    self.faceDirection = 1
    self.x = self.x + self.moveSpeed * dt
  end
  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
    self.currentRotation = -self.moveRotation * self.faceDirection
    self.y = self.y - self.moveSpeed * dt
  end
  if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    self.currentRotation = self.moveRotation * self.faceDirection
    self.y = self.y + self.moveSpeed * dt
  end
  
  if self.x > playAreaWidth then
      self.x = 0
  elseif self.x < 0 then
    self.x = playAreaWidth
  end
  
  if self.y < 0 + self.height - self.realHeight - self.realY then
    self.y = 0 + 0 + self.height - self.realHeight - self.realY
  elseif self.y > playAreaHeight - seaBedHeight - (self.height - self.realHeight - self.realY) then
    self.y = playAreaHeight - seaBedHeight - (self.height - self.realHeight - self.realY)
  end
    
  if not love.keyboard.isDown('up', 'down', 'w', 's') then
    self.currentRotation = 0
  end
end

-- The player is the only one we care about having collisions for now
function Player:checkCollision(other)
  self.left = self.x + self.realX
  self.right = self.x + self.realX + self.realWidth
  self.top = self.y + self.realY
  self.bottom = self.y + self.realY + self.realHeight
  
  other.left = other.x + other.realX
  other.right = other.x + other.realX + other.realWidth
  other.top = other.y + other.realY
  other.bottom = other.y + other.realY + other.realHeight
  
  return self.right > other.left
  and self.left < other.right
  and self.top < other.bottom
  and self.bottom > other.top
end