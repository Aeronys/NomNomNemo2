--This object will be used for all fish drawn
require "alert"
Fish = Entity:extend()
  
function Fish:new(x, y, sizeMod, imagePath)
  imagePath = imagePath or 'images/PNG/Retina/fishTile_075.png'
  Fish.super.new(self, x, y, imagePath)
  
  self.type = 'Fish'
  self.sizeModifier = sizeMod / 2
  self.currentRotation = 0
  self.moveRotation = 0.2
  self:updateDimensions()
  
  -- 1 represents facing right, -1 represents facing left
  self.faceDirection = 1
  -- 1 is normal, -1 is flipped
  self.yFlip = 1
  
  -- Move time is in milliseconds, which is why our divider is currently set to 100
  self.moveFrequency = 8    --Min 4, less means more frequent movement
  self.minMoveTime = 50
  self.maxMoveTime = 300
  self.moveTimeDivider = 100
  
  self.moveTime = love.math.random(self.minMoveTime, self.maxMoveTime)
  self.timer = self.moveTime
  
  self.detectDistance = 75
  self.escapeDistance = 150
  
  self.state = 'neutral'
  self.directions = {'left', 'right', 'up', 'down'}
  self.states = {
    ['neutral'] = {['moveSpeed'] = 50},
    ['retreat'] = {['moveSpeed'] = 135},
    ['attack'] = {['moveSpeed'] = 150},
    ['alert'] = {['moveSpeed'] = 0}
  }
  
  self.xp = 1
  self.xp = self.xp * (self.sizeModifier * 2)
  self.alertDuration = 1
end

function Fish:update(dt)
  self:animateFish(dt)
end

function Fish:draw()
  love.graphics.draw(self.image, self.x, self.y, self.currentRotation, self.sizeModifier * self.faceDirection, self.sizeModifier * self.yFlip, self.width / 2, self.height / 2)

  if self.state == 'alert' then
    love.graphics.draw(self.alert.image, self.alert.x, self.alert.y, 0, self.alert.sizeMod)
  end
end

-- Function to detect when player is within a certain distance, and alter state to either attack or retreat based on which fish is bigger
-- Will also set state back to neutral if player puts a certain amount of distance between them
function Fish:detectPlayer(player)
  if self.type ~= 'PufferFish' and self.type ~= 'Eel' then
    if self.state ~= 'alert' then
      self:getSides()
      player:getSides()
      -- Compare both left to right and right to left in case the two fish are on different "screens"
      self.xDistance = math.min(self:findXDistance(self.left, player.right), self:findXDistance(self.right, player.left))
      
      if self.top > player.bottom then
        self.yDistance = self.top - player.bottom
      elseif self.bottom < player.top then
        self.yDistance = player.top - self.bottom
      else
        self.yDistance = 0
      end
      
      local distance = math.sqrt(self.xDistance ^ 2 + self.yDistance ^ 2)
      if distance <= math.max(self.detectDistance - player.stealth, 30 * self.sizeModifier) then
        if player.realSize >= self.realSize then
          self.state = 'retreat'
        elseif player.realSize < self.realSize and self.state ~= 'alert' and self.state ~= 'attack' then
          self:setAlert()
        end
      -- If the player reaches a certain distance from the enemy fish, the enemy fish will stop chasing and go back to a neutral state
      elseif distance >= math.max(self.escapeDistance - (player.stealth / 2), 100 * self.sizeModifier) then
        self:setNeutral()
      end
    end
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
      self.moveDirection = love.math.random(self.moveFrequency)
      self.moveTime  = love.math.random(self.minMoveTime, self.maxMoveTime)
      self.timer = 0
    end
    
    -- Our random roll includes more possibilities than directions. If no valid direction is chosen then fish sits still until timer expires
    if self.moveDirection <= #self.directions then
      self:moveFish(self.directions[self.moveDirection], dt)
    end
  
  -- If the fish is in a retreat state, it will try to move away from the player
  -- TODO: Need to fix it so they still run away when they reach the "edge" of the playing area
  elseif self.state == 'retreat' then
    self:moveFish(self:findXDirection(self.x, player.x), dt)
    
  -- If the fish is in an attack state, it will try to pursue the player
  elseif self.state == 'attack' then
    -- Distance needs to be more than 1 to keep fish from constantly spinning in place when it lines up with player
    if self.xDistance > 0 then
      self:moveFish(self:findXDirection(player.x, self.x), dt)
    end
    
    if player.y >= self.y then
      self:moveFish('down', dt)
    -- Distance needs to be more than 1, to keep fish from constantly spinning in place when it lines up with player
    elseif self.yDistance > 0 then
      self:moveFish('up', dt)
    end
    
  elseif self.state == 'alert' then
     self.alert.timer = self.alert.timer + dt
    -- Have fish face the player when alerted to their presence
    if self:findXDirection(player.x, self.x) == 'right' then
      self.faceDirection = 1
    else
      self.faceDirection = -1
    end
    
    -- When alert timer is up, switch from alert to attack state
    if self.alert.timer >= self.alert.duration then
      self:setAttack()
    end
  end
end

-- Makes sure that fish don't travel outside the game boundaries
function Fish:checkBoundaries()
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

-- Finds direction of fish1x in relation to fish2x
-- i.e. if fish1x is to the left of fish 2x then this function will return 'left'
function Fish:findXDirection(fish1x, fish2x)
  -- First check which fish has the greater x position
  if fish1x >= fish2x then
    -- Check whether or not both fish are on the same "screen" by measuring whether the distance between them is shorter if you try to wrap around the screen
    if fish1x - fish2x < fish2x + playAreaWidth - fish1x then
      return 'right'
    else
      return 'left'
    end
  else
    if fish2x - fish1x < fish1x + playAreaWidth - fish2x then
      return 'left'
    else
      return 'right'
    end
  end
end

function Fish:findXDistance(fish1x, fish2x)
  if fish1x > fish2x then
    return math.min(fish1x - fish2x, fish1x + playAreaWidth - fish2x, fish2x + playAreaWidth - fish1x)
  elseif fish2x > fish1x then
    return math.min(fish2x - fish1x, fish1x + playAreaWidth - fish2x, fish2x + playAreaWidth - fish1x)
  end
end
  
-- Puts fish into alert state and sets necessary parameters
function Fish:setAlert()
  self.state = 'alert'
  self.alert = Alert(self.x - 10, self.top - 25, self.alertDuration)
end

-- Puts fish into neutral state and sets necessary parameters
function Fish:setNeutral()
  self.state = 'neutral'
end

-- Puts fish into attack state and sets necessary parameters
function Fish:setAttack()
  self.state = 'attack'
  self.alert.timer = 0
end
  
function Fish:moveFish(direction, dt)
  if direction == 'left' then
    -- Have fish face left if moving left
    self.faceDirection = -1
    self.x = self.x - self.moveSpeed * dt
  elseif direction == 'right' then
    -- Have player face right if moving right
    self.faceDirection = 1
    self.x = self.x + self.moveSpeed * dt
  end
  
  if direction == 'up' then
    -- Have fish point up a bit when moving up
    self.currentRotation = -self.moveRotation * self.faceDirection
    self.y = self.y - self.moveSpeed * dt
  elseif direction == 'down' then
    -- Have fish point down a bit when moving down
    self.currentRotation = self.moveRotation * self.faceDirection
    self.y = self.y + self.moveSpeed * dt
  else
    self.currentRotation = 0
  end
  
  self:checkBoundaries()
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
  
  -- Increase realSize if player has the predator upgrade
  if self.predator then
    realSize = realSize * 1.1
  end
  
  -- return real width and height of image after removing the blank space
  return maxX - minX, maxY - minY, minX, minY, realSize
end

function Fish:updateDimensions()
  self.realWidth, self.realHeight, self.realX, self.realY, self.realSize = self:getRealDimensions()
  self.sizedWidth = self.width * self.sizeModifier
  self.sizedHeight = self.height * self.sizeModifier
end

function Fish:getSides()
  self.left = self.x - self.realWidth / 2
  self.right = self.x + self.realWidth / 2
  self.top = self.y - self.realHeight / 2
  self.bottom = self.y + self.realHeight / 2
end