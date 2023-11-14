--This object will be used for all fish drawn
Fish = Entity:extend()

function Fish:new(x, y, sizeMod, imagePath)
  Fish.super.new(self, x, y, imagePath)
  
  self.sizeModifier = sizeMod
  self.currentRotation = 0
  self.moveRotation = 0.2
  self:updateDimensions()
  
  -- 1 represents facing right, -1 represents facing left
  self.faceDirection = 1
  
  -- Move time is in milliseconds, which is why our divider is currently set to 100
  self.minMoveTime = 50
  self.maxMoveTime = 300
  self.moveTimeDivider = 100
  
  self.moveTime = love.math.random(self.minMoveTime, self.maxMoveTime)
  self.timer = self.moveTime
  
  self.detectDistance = 100
  self.escapeDistance = 300
  
  self.state = 'neutral'
  self.directions = {'left', 'right', 'up', 'down'}
  self.states = {
    ['neutral'] = {['moveSpeed'] = 50, ['direction'] = 0},
    ['retreat'] = {['moveSpeed'] = 150, ['direction'] = 0},
    ['attack'] = {['moveSpeed'] = 100, ['direction'] = 1}
  }
end

function Fish:update(dt)
  self:animateFish(dt)
end

function Fish:draw()
  love.graphics.draw(self.image, self.x, self.y, self.currentRotation, self.sizeModifier * self.faceDirection, self.sizeModifier, self.width / 2, self.height / 2)
end

function Fish:detectPlayer(player)
  local xDistance = self.x - player.x
  local yDistance = self.y - player.y
  local distance = math.sqrt(xDistance ^ 2 + yDistance ^ 2)
  if distance <= self.detectDistance then
    if player.realSize >= self.realSize then
      self.state = 'retreat'
    elseif player.realSize < self.realSize then
      self.state = 'attack'
    end
  elseif distance >= self.escapeDistance then
    self.state = 'neutral'
  end
end
  
function Fish:animateFish(dt)
  
  self.moveSpeed = self.states[self.state]['moveSpeed']
  
  -- Random fish movements only apply if the fish is in a neutral state
  if self.state == 'neutral' then
    -- Constantly increment timer
    self.timer = self.timer + dt
    
    -- Whenever timer expires, choose new fish direction and move time, and reset timer
    if self.timer > self.moveTime / self.moveTimeDivider then
      self.currentRotation = 0
      self.moveDirection = love.math.random(8)
      self.moveTime  = love.math.random(self.minMoveTime, self.maxMoveTime)
      self.timer = 0
    end
    
    -- Our random roll includes more possibilities than directions. If no valid direction is chosen then fish sits still until timer expires
    if self.moveDirection <= #self.directions then
      self:moveFish(self.directions[self.moveDirection], dt)
    end
  
  -- If the fish is in a retreat state, it will try to move away from the player
  elseif self.state == 'retreat' then
    if player.x >= self.x then
      self:moveFish('left', dt)
    else
      self:moveFish('right', dt)
    end
    
  -- If the fish is in an attack state, it will try to pursue the player
  elseif self.state == 'attack' then
    if player.x >= self.x then
      self:moveFish('right', dt)
    else
      self:moveFish('left', dt)
    end
    
    if player.y >= self.y then
      self:moveFish('down', dt)
    else
      self:moveFish('up', dt)
    end
  end
end
  
function Fish:moveFish(direction, dt)
  if direction == 'left' then
    -- Have fish face left if moving left
    self.faceDirection = -1
    self.x = self.x - self.moveSpeed * dt
  end
  
  if direction == 'right' then
    -- Have player face right if moving right
    self.faceDirection = 1
    self.x = self.x + self.moveSpeed * dt
  end
  
  if direction == 'up' then
    -- Have fish point up a bit when moving up
    self.currentRotation = -self.moveRotation * self.faceDirection
    self.y = self.y - self.moveSpeed * dt
  end
  
  if direction == 'down' then
    -- Have fish point down a bit when moving down
    self.currentRotation = self.moveRotation * self.faceDirection
    self.y = self.y + self.moveSpeed * dt
  end
  
  -- Have fish wrap around screen to other side if they reach the end of the play area
  if self.x > playAreaWidth then
      self.x = 0
  elseif self.x < 0 then
    self.x = playAreaWidth
  end
  
  -- Keep fish from being able to go outside of vertical boundaries
  if self.y < 0 + self.sizedHeight - self.realHeight - self.realY then
    self.y = 0 + 0 + self.sizedHeight - self.realHeight - self.realY
  elseif self.y > playAreaHeight - seaBedHeight - (self.sizedHeight - self.realHeight - self.realY) then
    self.y = playAreaHeight - seaBedHeight - (self.sizedHeight - self.realHeight - self.realY)
  end
end

function Fish:getRealDimensions()
  local minX = self.width - 1
  local maxX = 0
  local minY = self.height - 1
  local maxY = 0
  local realSize = 0
  
  for y = 0, self.height - 1 do
    for x = 0, self.width - 1 do
      local r, g, b, a = self.imageData:getPixel(x, y)
      -- If a pixel has no color applied to it, we ignore it for the sake of our real dimesions
      -- If it does have color, we compare its location to see if it's at a more extreme boundary than any of our other pixels found
      -- Also keeps track of how many pixels the fish is made up of, which is how we'll determine fish size
      if not (r == 0 and g == 0 and b == 0 and a == 0) then
        if x < minX then
          minX = x
        elseif x > maxX then
          maxX = x
        end
        if y < minY then
          minY = y
        elseif y > maxY then
          maxY = y
        end
      end
    end
  end
  
  -- Factor in any size modifications made. This is necessary because the actual image variable's data never changes
  -- Rather, we apply changes to that data while keeping the original data static
  minX = minX * self.sizeModifier
  maxX = maxX * self.sizeModifier
  minY = minY * self.sizeModifier
  maxY = maxY * self.sizeModifier
  
  -- Simple length * width to determine size
  -- Tried using pixel counts, but this created results that didn't always feel right in-game
  realSize = (maxX - minX) * (maxY - minY)
  
  -- return real width and height of image after removing the blank space
  return maxX - minX, maxY - minY, minX, minY, realSize
end

function Fish:updateDimensions()
  self.realWidth, self.realHeight, self.realX, self.realY, self.realSize = self:getRealDimensions()
  self.sizedWidth = self.width * self.sizeModifier
  self.sizedHeight = self.height * self.sizeModifier
end