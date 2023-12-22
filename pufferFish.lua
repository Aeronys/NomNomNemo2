PufferFish = Fish:extend()

function PufferFish:new(x, y, sizeMod)
  PufferFish.super.new(self, x, y, sizeMod, 'images/PNG/Retina/fishTile_101.png')
  
  self.type = 'PufferFish'
  self.xp = self.xp * 20
  self.startPosition = self.y
  
  -- Puffer fish are a litter more forgiving with their size
  self.realSize = self.realSize * .9
  
  -- Randomize oscillation time and distance
  self.oscilTime = love.math.random(5, 10)
  self.oscilDistance = love.math.random(150, 550)
  
  self.detectDistance = 0
  self.escapeDistance = 0
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 50},
    ['retreat'] = {['moveSpeed'] = 50},
    ['attack'] = {['moveSpeed'] = 50},
    ['alert'] = {['moveSpeed'] = 50}
  }
end

-- Pufferfish don't chase the player, they just oscillate back and forth
function PufferFish:animateFish(dt)
  
  cycles = gameTimer / self.oscilTime
  tau = math.pi * 2
  rawSinWave = math.sin(cycles * tau)
  
  -- Has the fish move back and forth based off of sin wave
  movementFactor = (rawSinWave + 1) / 2
  
  self.y = self.startPosition + (self.oscilDistance * movementFactor)
end