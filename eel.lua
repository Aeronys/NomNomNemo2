Eel = Fish:extend()

function Eel:new(x, y, sizeMod)
  sizeMod = sizeMod + 1
  Eel.super.new(self, x, y, sizeMod, 'images/PNG/Retina/fishTile_128.png')
  
  self.type = 'Eel'
  self.xp = self.xp * 4000
  
  -- The only condition to be able to eat eels is that you have the eat eels upgrade
  self.realSize = 1
  
  self.moveFrequency = 4
  self.minMoveTime = 20
  self.maxMoveTime = 200
  
  self.detectDistance = 0
  self.escapeDistance = 0
  
  self.states = {
    ['neutral'] = {['moveSpeed'] = 800}
  }
end

function Eel:animateFish(dt)
  -- Constantly increment timer
  self.timer = self.timer + dt
  
  -- Whenever timer expires, choose new fish direction and move time, and reset timer
  if self.timer > self.moveTime / self.moveTimeDivider then
    
    -- Limiting the angle the eel can move at, we do not want it moving too vertically
    self.moveAngle = love.math.random(-80, 80)
    self.moveAngle = self.moveAngle / 100
    self.horizontalDirection = math.random(0, 1)
    
    -- If horizontalDirection is 0, we will subract from 0 and thus move right
    -- If horizontalDirection is 1, we will subract from pi and thus move left
    self.moveDirection = (math.pi * self.horizontalDirection)  - self.moveAngle
    self.moveTime  = love.math.random(self.minMoveTime, self.maxMoveTime)
    self.timer = 0
  end
  
   -- Orient eel correctly
  if self.horizontalDirection == 1 then
    self.yFlip = -1
  else
    self.yFlip = 1
  end
  self.currentRotation = self.moveDirection
  
  self:moveFish(self.moveDirection, dt)
end

function Eel:moveFish(direction, dt)
  self.x = (self.x + math.cos(direction) * self.states['neutral']['moveSpeed'] * dt)
  self.y = (self.y + math.sin(direction) * self.states['neutral']['moveSpeed'] * dt)
  self:checkBoundaries()
end