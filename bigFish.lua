BigFish = Fish:extend()

function BigFish:new(x, y, sizeMod)
  -- Big fish are big, so increase their sizeMod by 1
  sizeMod = sizeMod + 1
  BigFish.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_079.png')
  self.xp = self.xp * 1000
  
  self.minMoveTime = 50
  self.maxMoveTime = 500
  
  self.detectDistance = 500
  self.escapeDistance = 700
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 70, ['color'] = {1, 1, 1, 1}},
    ['retreat'] = {['moveSpeed'] = 500, ['color'] = {1, 1, 1, 1}},
    ['attack'] = {['moveSpeed'] = 500, ['color'] = {1, 0, 0, 1}},
    ['alert'] = {['moveSpeed'] = 0, ['color'] = {1, 1, 1, 1}}
  }
end
