-- Player is a fish, so we will extend this class
Player = Fish:extend()

function Player:new(x, y)
  Player.super.new(self, x, y, 'images/PNG/Default size/fishTile_081.png')
  self.moveSpeed = 200
  self.width, self.height = self:getRealDimensions()
end

function Player:update(dt)
   self:movePlayer(dt)
end

function Player:movePlayer(dt)
  -- Basic wasd and arrow controls for movement
  if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
    -- Have fish face left if moving left
    self.faceDirection = -1
    self.x = self.x - self.moveSpeed * dt
  end
  if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
    -- Have player face right if moving right
    self.faceDirection = 1
    self.x = self.x + self.moveSpeed * dt
  end
  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
    self.currentRotation = -self.moveRotation * self.faceDirection
    self.y = self.y - self.moveSpeed * dt
  end
  if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    self.currentRotation = self.moveRotation * self.faceDirection
    self.y = self.y + self.moveSpeed * dt
  end
  
  if self.x > playAreaWidth then
      self.x = 0
  elseif self.x < 0 then
    self.x = playAreaWidth
  end
  
  if self.y < 0 + self.height / 2 then
    self.y = 0 + self.height / 2
  elseif self.y > playAreaHeight - seaBedHeight - self.height / 2 then
    self.y = playAreaHeight - seaBedHeight - self.height /2
  end
    
  if not love.keyboard.isDown('up', 'down', 'w', 's') then
    self.currentRotation = 0
  end
end

-- The player is the only one we care about having collisions for now
function Player:checkCollision(other)
  self.left = self.x
  self.right = self.x + self.width
  self.top = self.y
  self.bottom = self.y + self.height
  
  other.left = other.x
  other.right = other.x + other.width
  other.top = other.y
  other.bottom = other.y + other.height
  
  return self.right > other.left
  and self.left < other.right
  and self.top < other.bottom
  and self.bottom > other.top
end

function Player:getRealDimensions()
  local minX = self.width - 1
  local maxX = 0
  local minY = self.height - 1
  local maxY = 0
  
  for y = 0, self.height - 1 do
    for x = 0, self.width - 1 do
      local r, g, b, a = self.imageData:getPixel(x, y)
      if not (r == 0 and g == 0 and b == 0 and a == 0) then
        if x < minX then
          --print(x, y)
          --print("Changing from "..minX.." to "..x)
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
  -- return real width and height of image after removing the blank space
  return maxX - minX, maxY - minY
end