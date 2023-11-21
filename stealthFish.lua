StealthFish = Fish:extend()

function StealthFish:new(x, y, sizeMod)
  StealthFish.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_077.png')
  
  self.minMoveTime = 100
  self.maxMoveTime = 700
  
  self.detectDistance = 100
  self.escapeDistance = 180
  
  -- Stealth fish are usually hard to see, but reveal themselves when you get close
  self.stealthColor = {1, 1, 1, .1}
  self.visibleColor = {1, 1, 1, 1}
  self.currentColor = self.stealthColor
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 100},
    ['retreat'] = {['moveSpeed'] = 220},
    ['attack'] = {['moveSpeed'] = 260},
    ['alert'] = {['moveSpeed'] = 0}
  }
end

function StealthFish:draw()
  love.graphics.setColor(self.currentColor)
  StealthFish.super.draw(self)
  love.graphics.setColor(self.visibleColor)
end

function StealthFish:setAlert()
  StealthFish.super.setAlert(self)
  self.currentColor = self.visibleColor
end

function StealthFish:setNeutral()
  StealthFish.super.setNeutral(self)
  self.currentColor = self.stealthColor
end