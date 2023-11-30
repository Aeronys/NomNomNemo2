PufferFish = Fish:extend()

function PufferFish:new(x, y, sizeMod)
  PufferFish.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_101.png')
  
  self.minMoveTime = 50
  self.maxMoveTime = 500
  self.detectDistance = 50
  self.escapeDistance = 50
  
  self.xp = 0
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 50, ['color'] = {1, 1, 1, 1}},
    ['retreat'] = {['moveSpeed'] = 50, ['color'] = {1, 1, 1, 1}},
    ['attack'] = {['moveSpeed'] = 50, ['color'] = {1, 0, 0, 1}},
    ['alert'] = {['moveSpeed'] = 50, ['color'] = {1, 1, 1, 1}}
  }
end
