Eel = Fish:extend()

function Eel:new(x, y, sizeMod)
  -- Big fish are big, so increase their sizeMod by 1
  sizeMod = 2.5
  BigFish.super.new(self, x, y, sizeMod, 'images/PNG/Retina/fishTile_128.png')
  self.xp = self.xp * 10000
  
  self.moveFrequency = 4
  self.minMoveTime = 1
  self.maxMoveTime = 300
  
  self.detectDistance = 0
  self.escapeDistance = 0
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 800},
    ['retreat'] = {['moveSpeed'] = 500},
    ['attack'] = {['moveSpeed'] = 395},
    ['alert'] = {['moveSpeed'] = 0}
  }
end
