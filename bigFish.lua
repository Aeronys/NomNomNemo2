BigFish = Fish:extend()

function BigFish:new(x, y, sizeMod)
  -- Big fish are big, so increase their sizeMod by 1
  sizeMod = sizeMod + .8
  BigFish.super.new(self, x, y, sizeMod, 'images/PNG/Retina/fishTile_079.png')
  
  self.type = 'BigFish'
  self.xp = self.xp * 2000
  
  self.moveFrequency = 10
  self.minMoveTime = 50
  self.maxMoveTime = 500
  
  self.detectDistance = 480
  self.escapeDistance = 530
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 60},
    ['retreat'] = {['moveSpeed'] = 430},
    ['attack'] = {['moveSpeed'] = 375},
    ['alert'] = {['moveSpeed'] = 0}
  }
end
