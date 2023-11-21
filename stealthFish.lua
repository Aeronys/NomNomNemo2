StealthFish = Fish:extend()

function StealthFish:new(x, y, sizeMod)
  StealthFish.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_077.png')
  
  self.minMoveTime = 100
  self.maxMoveTime = 700
  
  self.detectDistance = 100
  self.escapeDistance = 180
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 100},
    ['retreat'] = {['moveSpeed'] = 220},
    ['attack'] = {['moveSpeed'] = 260},
    ['alert'] = {['moveSpeed'] = 0}
  }
end
  