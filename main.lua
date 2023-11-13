io.stdout:setvbuf("no")

function love.load()
  Object = require "classic"
  require "entity"
  require "fish"
  require "player"
  
  --Set backround to a sea color
  love.graphics.setBackgroundColor(.1, .5, 1)
  
  playAreaWidth = love.graphics.getWidth()
  playAreaHeight = love.graphics.getHeight()
  
  player = Player(playAreaWidth/2, playAreaHeight/2, 1)
  fishies = {}
  startingFishAmount = 25
  
  seaBedImages = {}
  seaBedImageCount = 16
  
  -- Insert images into seaBedTiles table
  for i = 1, seaBedImageCount do
    local image = love.graphics.newImage('images/PNG/Default size/fishTile_'..i..'.png')
    table.insert(seaBedImages, image)
  end
  
  seaBedHeight = seaBedImages[1]:getHeight()
  seaBedWidth = seaBedImages[1]:getWidth()
  
  seaBed = randomizeSeaBed()
  
  -- Populate game area with random fish
  for i = 1, startingFishAmount do
    table.insert(fishies, addRandomFish())
  end
end

function love.update(dt)
  player:update(dt)
  for fishIndex, fish in ipairs(fishies) do
    fish:update(dt)
  end
  
  -- Check for collisions between player and other fish
  for fishIndex, fish in ipairs(fishies) do
    if player:checkCollision(fish) then
      resolveCollision(player, fish, fishIndex)
    end
  end
end

function love.draw()
  -- Draw the player
  player:draw()
  
  -- Draw all other fish
  for i, v in ipairs(fishies) do
    v:draw()
  end
  
  -- Draw sea bed
  drawSeaBed(seaBed)
end

-- Generates a random fish to be added into the level
function addRandomFish()
  local fishX = love.math.random(playAreaWidth)
  local fishY = love.math.random(playAreaHeight)
  local fishSize = 1 + love.math.random()
  return Fish(fishX, fishY, fishSize, 'images/PNG/Default size/fishTile_075.png')
end

-- Print a single tile
function drawTile(image, x, y)
  love.graphics.draw(image, x, y)
end

-- Print out our previously generated list of sea bed tiles
function drawSeaBed(seaBed)
  local y = playAreaHeight - seaBedHeight

  for i,v in ipairs(seaBed) do
    drawTile(seaBedImages[v], seaBedWidth * (i - 1), y)
  end
end

-- Choose random sea bed tiles and insert them into a table which will reperesent our seabed
function randomizeSeaBed()
  local seaBed = {}
  
  -- Figure out how many tiles we need based on the size of our play area
  seaBedTilesNeeded = math.ceil(playAreaWidth / seaBedWidth)
  
  for i = 1, seaBedTilesNeeded do
    local rand = love.math.random(#seaBedImages)
    table.insert(seaBed, rand)
  end
  return seaBed
end

function resolveCollision(player, fish, fishIndex)
  -- If player is bigger, remove eaten fish and grow a little larger
  if player.realSize >= fish.realSize then
    table.remove(fishies, fishIndex)
    player:grow(0.03)
  -- If other fish is bigger, reset the game
  else
    love.load()
  end
end
    

-- Set player rotation back to zero whenever the w, s, down, or up keys are released
function love.keyreleased(key)
  if key == 'down' or key =='up' or key == 'w' or key == 's' then
    player.currentRotation = 0
  end
end