GreenFish = Fish:extend()

function GreenFish:new(x, y, sizeMod)
  sizeMod = sizeMod + .2
  GreenFish.super.new(self, x, y, sizeMod, 'images/PNG/Retina/fishTile_073.png')
  
  self.xp = self.xp * 100
  self.moveFrequency = 5
  self.minMoveTime = 50
  self.maxMoveTime = 300
  self.detectDistance = 300
  self.escapeDistance = 400
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 150},
    ['retreat'] = {['moveSpeed'] = 310},
    ['attack'] = {['moveSpeed'] = 290},
    ['alert'] = {['moveSpeed'] = 0}
  }
end
