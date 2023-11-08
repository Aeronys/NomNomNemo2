-- Player is a fish, so we will extend this class
Player = Fish:extend()

function Player:new(x, y)
  Player.super.new(self, x, y, 'images/PNG/Default size/fishTile_080.png')
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
  if not love.keyboard.isDown('up', 'down', 'w', 's') then
    self.currentRotation = 0
  end
end