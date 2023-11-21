io.stdout:setvbuf("no")

function love.load()
  require "entity"
  require "fish"
  require "stealthFish"
  require "player"
  
  --Set backround to a sea color
  love.graphics.setBackgroundColor(.1, .5, 1)
  
  playAreaWidth = 5000
  playAreaHeight = 1000
  
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()
  
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
    
  playerStartSize = 1
  player = Player(playAreaWidth / 2, playAreaHeight - seaBedHeight - 200, playerStartSize)
  fishies = {}
  startingFishAmount = 50
  
  -- Populate game area with random fish
  for i = 1, startingFishAmount do
    table.insert(fishies, addRandomFish())
  end
end

function love.update(dt)
  player:update(dt)
  
  -- Check for collisions between player and other fish
  for fishIndex, fish in ipairs(fishies) do
    if player:checkCollision(fish) then
      resolveCollision(player, fish, fishIndex)
    end
  end
  
  for fishIndex, fish in ipairs(fishies) do
    fish:detectPlayer(player)
    fish:update(dt)
  end
end

function love.draw()
  --Draw 3 copies of everything so that we can continuously wrap around the screen without any gaps
  for i = -1, 1 do
    love.graphics.origin()
    love.graphics.translate(i * playAreaWidth, 0)
    
    -- Have the camera follow the fish, but don't have it go below our seabed
    if player.y <= screenHeight / 2 + (playAreaHeight - screenHeight)  then
      love.graphics.translate(-player.x + screenWidth / 2, -player.y + screenHeight / 2)
    else
      -- Fixed y-axis translation after a certain point so that we don't scroll below our seabed
      love.graphics.translate(-player.x + screenWidth / 2, -(playAreaHeight - screenHeight))
    end

    -- Draw the player
    player:draw()
    
    -- Draw all other fish
    for i, v in ipairs(fishies) do
      v:draw()
    end
    
    -- Draw sea bed
    drawSeaBed(seaBed)
  end
end

-- Generates a random fish to be added into the level
function addRandomFish()
  local fishType = love.math.random(2)
  local fishX = love.math.random(playAreaWidth)
  local fishY = love.math.random(playAreaHeight - seaBedHeight - 20)
  local fishSize = 1 + love.math.random()
  if fishType == 1 then
    return Fish(fishX, fishY, fishSize)
  elseif fishType == 2 then
    return StealthFish(fishX, fishY, fishSize)
  end
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