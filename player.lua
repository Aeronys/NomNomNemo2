-- Player is a fish, so we will extend this class
Player = Fish:extend()
require "upgrades"

function Player:new(x, y, sizeMod)
  Player.super.new(self, x, y, sizeMod, 'images/PNG/Retina/fishTile_081.png')
  self.moveSpeed = 190
  self.level = 1
  self.xp = 0
  self.max = 'MAX LEVEL'
  self.levelUps = {3, 8, 20, 35, 60, 95, 150, 225, 350, 520, 750, 1100, 1800, 3200, 5700, 10000, 15000, 27000, 45000, 70000, 110000, 160000, 225000, 300000, self.max}
  self.stealth = 0
  self.pufferEdible = false
  self.upgrades = Upgrades()
  self.predator = false
  self.eelEaten = false
  self.eatCount = 0
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
  self:levelUp()
end

function Player:levelUp()
  -- We check for level up here instead of processXP because it allows us to call this function again after upgrading, in case multiple levels occur at once
  if self.levelUps[self.level] ~= self.max and self.xp >= self.levelUps[self.level] then
    self.level = self.level + 1
    self.upgrades:chooseUpgrade(self)
    
    -- At level 10 stop spawning basic fish
    if self.level == 10 then
      table.remove(fishTypesAllowed, 1)
      
    -- At level 18 we will start spawning eels into the sea
    elseif self.level == 17 then
      table.insert(fishTypesAllowed, 'Eel')
    end
  end
end
  
