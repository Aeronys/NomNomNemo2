StealthFish = Fish:extend()

-- Stealth fish are usually hard to see, but reveal themselves when you get close  
stealthColors = {
  ['neutral'] = {1, 1, 1, .1},
  ['retreat'] = {1, 1, 1, .05},
  ['attack'] = {1, 1, 1, 1},
  ['alert'] = {1, 1, 1, 1}
}
  
function StealthFish:new(x, y, sizeMod)
  StealthFish.super.new(self, x, y, sizeMod, 'images/PNG/Default size/fishTile_077.png')
  self.xp = self.xp * 10
  
  self.minMoveTime = 100
  self.maxMoveTime = 700
  self.detectDistance = 160
  self.escapeDistance = 190
  
  -- Stealth fish are usually hard to see, but reveal themselves when you get close  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 100, ['color'] = {1, 1, 1, .1}},
    ['retreat'] = {['moveSpeed'] = 220, ['color'] = {1, 1, 1, .05}},
    ['attack'] = {['moveSpeed'] = 240, ['color'] = {1, 1, 1, 1}},
    ['alert'] = {['moveSpeed'] = 0, ['color'] = {1, 1, 1, 1}}
  }
end

function StealthFish:draw()
  love.graphics.setColor(stealthColors[self.state])
  StealthFish.super.draw(self)
  love.graphics.setColor(1, 1, 1, 1)
end

function StealthFish:stealthOn()
  stealthColors['neutral'] = {1, 1, 1, .1}
  stealthColors['retreat'] = {1, 1, 1, .05}
end

function StealthFish:stealthOff()
  stealthColors['neutral'] = {1, 1, 1, .5}
  stealthColors['retreat'] = {1, 1, 1, .3}
end