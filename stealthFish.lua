StealthFish = Fish:extend()

-- Stealth fish are usually hard to see, but reveal themselves when you get close  
stealthColors = {
  ['neutral'] = {1, 1, 1, .1},
  ['retreat'] = {1, 1, 1, .05},
  ['attack'] = {1, 1, 1, 1},
  ['alert'] = {1, 1, 1, 1}
}
  
function StealthFish:new(x, y, sizeMod)
  StealthFish.super.new(self, x, y, sizeMod, 'images/PNG/Retina/fishTile_077.png')
  
  self.type = 'StealthFish'
  self.xp = self.xp * 10
  
  self.minMoveTime = 100
  self.maxMoveTime = 700
  self.detectDistance = 160
  self.escapeDistance = 190
  
  -- Stealth fish are usually hard to see, but reveal themselves when you get close  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 100, ['color'] = {1, 1, 1, .1}},
    ['retreat'] = {['moveSpeed'] = 200, ['color'] = {1, 1, 1, .05}},
    ['attack'] = {['moveSpeed'] = 215, ['color'] = {1, 1, 1, 1}},
    ['alert'] = {['moveSpeed'] = 0, ['color'] = {1, 1, 1, 1}}
  }
end

function StealthFish:draw()
  love.graphics.setColor(stealthColors[self.state])
  StealthFish.super.draw(self)
  love.graphics.setColor(1, 1, 1, 1)
end

-- Stealth on when player doesn not have the Observant upgrade
function StealthFish:stealthOn()
  stealthColors['neutral'] = {1, 1, 1, .1}
  stealthColors['retreat'] = {1, 1, 1, .05}
end

-- Stealth off after the player has acquired the Observant upgrade
function StealthFish:stealthOff()
  stealthColors['neutral'] = {1, 1, 1, .5}
  stealthColors['retreat'] = {1, 1, 1, .3}
end