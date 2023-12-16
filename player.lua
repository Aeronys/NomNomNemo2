-- Player is a fish, so we will extend this class
Player = Fish:extend()
require "upgrades"

function Player:new(x, y, sizeMod)
  Player.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_081.png')
  self.moveSpeed = 200
  self.level = 1
  self.xp = 0
  self.max = 'MAX LEVEL'
  self.levelUps = {3, 10, 25, 50, 100, 150, 250, 500, 1500, 3000, 8000, 15000, 25000, 35000, 60000, 100000, self.max}
  self.stealth = 0
  self.pufferEdible = false
  self.stealthDetection = 1
  self.upgrades = Upgrades()
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
  self:getSides()
  other:getSides()

  return self.right > other.left
  and self.left < other.right
  and self.top < other.bottom
  and self.bottom > other.top
end

function Player:processXP(other)
  self.xp = self.xp + other.xp
  
  -- While loop is used in case multiple level ups occur at once, although this should never occur
  while self.levelUps[self.level] ~= self.max and self.xp >= self.levelUps[self.level] do
    self:levelUp()
  end
end

function Player:levelUp()
  self.level = self.level + 1
  self.upgrades:chooseUpgrade(self)
end
  
