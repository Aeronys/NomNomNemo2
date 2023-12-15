PufferFish = Fish:extend()

function PufferFish:new(x, y, sizeMod)
  PufferFish.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_101.png')
  
  self.startPosition = self.y
  
  -- Randomize oscillation time and distance
  self.oscilTime = love.math.random(5, 10)
  self.oscilDistance = love.math.random(150, 1200)
  
  self.minMoveTime = 50
  self.maxMoveTime = 500
  self.detectDistance = 0
  self.escapeDistance = 0
  
  self.xp = 0
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 50, ['color'] = {1, 1, 1, 1}},
    ['retreat'] = {['moveSpeed'] = 50, ['color'] = {1, 1, 1, 1}},
    ['attack'] = {['moveSpeed'] = 50, ['color'] = {1, 0, 0, 1}},
    ['alert'] = {['moveSpeed'] = 50, ['color'] = {1, 1, 1, 1}}
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
