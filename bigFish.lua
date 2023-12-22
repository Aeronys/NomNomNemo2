BigFish = Fish:extend()

function BigFish:new(x, y, sizeMod)
  -- Big fish are big, so increase their sizeMod by 1
  sizeMod = sizeMod + 1
  BigFish.super.new(self, x, y, sizeMod, 'images/PNG/Retina/fishTile_079.png')
  self.xp = self.xp * 1000
  
  self.moveFrequency = 10
  self.minMoveTime = 50
  self.maxMoveTime = 500
  
  self.detectDistance = 450
  self.escapeDistance = 500
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 60},
    ['retreat'] = {['moveSpeed'] = 450},
    ['attack'] = {['moveSpeed'] = 395},
    ['alert'] = {['moveSpeed'] = 0}
  }
end
