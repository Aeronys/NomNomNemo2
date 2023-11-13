-- Player is a fish, so we will extend this class
Player = Fish:extend()

function Player:new(x, y)
  Player.super.new(self, x, y, 'images/PNG/Default size/fishTile_081.png')
  self.moveSpeed = 200
end

function Player:update(dt)
  self:controlPlayer(dt)
end

function Player:controlPlayer(dt)
  -- Basic wasd and arrow controls for movement
  if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
    self:moveFish('left', dt)
  end
  
  if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
    self:moveFish('right', dt)
  end
  
  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
    self:moveFish('up', dt)
  end
  
  if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    self:moveFish('down', dt)
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