GreenFish = Fish:extend()

function GreenFish:new(x, y, sizeMod)
  sizeMod = sizeMod + .2
  GreenFish.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_073.png')
  
  self.minMoveTime = 50
  self.maxMoveTime = 300
  
  self.detectDistance = 50
  self.escapeDistance = 300
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 150, ['color'] = {1, 1, 1, 1}},
    ['retreat'] = {['moveSpeed'] = 200, ['color'] = {1, 1, 1, 1}},
    ['attack'] = {['moveSpeed'] = 400, ['color'] = {1, 0, 0, 1}},
    ['alert'] = {['moveSpeed'] = 0, ['color'] = {1, 1, 1, 1}}
  }
end