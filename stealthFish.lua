StealthFish = Fish:extend()

function StealthFish:new(x, y, sizeMod)
  self.xp = 10
  StealthFish.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_077.png')
  
  self.minMoveTime = 100
  self.maxMoveTime = 700
  self.detectDistance = 100
  self.escapeDistance = 180
  
  -- Stealth fish are usually hard to see, but reveal themselves when you get close  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 100, ['color'] = {1, 1, 1, .1}},
    ['retreat'] = {['moveSpeed'] = 220, ['color'] = {1, 1, 1, .05}},
    ['attack'] = {['moveSpeed'] = 260, ['color'] = {1, 1, 1, 1}},
    ['alert'] = {['moveSpeed'] = 0, ['color'] = {1, 1, 1, 1}}
  }
end

function StealthFish:draw()
  love.graphics.setColor(self.states[self.state]['color'])
  StealthFish.super.draw(self)
  love.graphics.setColor(1, 1, 1, 1)
end