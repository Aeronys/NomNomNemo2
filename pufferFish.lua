PufferFish = Fish:extend()

function PufferFish:new(x, y, sizeMod)
  PufferFish.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_101.png')
  
  self.startPosition = self.x
  self.oscilTime = 3
  
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

function PufferFish:animateFish(dt)
  cycles = dt / self.oscilTime
  tau = math.pi * 2
  rawSinWave = math.sin(cycles * tau)
  
  movementFactor = (rawSinWave + 1) / 2
  
  self.x = self.startPosition + (100 * movementFactor)
end
