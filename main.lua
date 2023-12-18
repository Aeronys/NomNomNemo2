io.stdout:setvbuf("no")

function love.load()
  Object = require "classic"
  require "entity"
  require "fish"
  require "bigFish"
  require "greenFish"
  require "pufferFish"
  require "stealthFish"
  require "player"
  
  --Set gradient for our sea color
  sea = gradientMesh("vertical", 
        {.1, .5, 1},
        {0, .1, .17}
  )
  
  Font24 = love.graphics.newFont(24)
  Font15 = love.graphics.newFont(15)
  defaultFont = love.graphics.newFont(12)
  
  -- Level dimensions
  playAreaWidth = 5000
  playAreaHeight = 7000
  
  -- We set here our boundaries for where each type of fish can be spawned
  -- Order of fish types matters, as that's what's used by our random function to determine which fish to spawn
  fishTypes = {
    {['Type'] = 'Fish', ['upperBound'] = 0, ['lowerBound'] = 2500},
    {['Type'] = 'StealthFish', ['upperBound'] = 1000, ['lowerBound'] = 4000},
    {['Type'] = 'GreenFish', ['upperBound'] = 3000, ['lowerBound'] = 5500},
    {['Type'] = 'BigFish', ['upperBound'] = 4000, ['lowerBound'] = 7000},
    {['Type'] = 'PufferFish', ['upperBound'] = 1500, ['lowerBound'] = 5800}
    }
  
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()
  
  -- Set variables needed to draw our sky later
  sky = {
    ['height'] = screenHeight / 2,
    ['width'] = playAreaWidth,
    ['color'] = {.8, 1, 1}
    }
  
  -- Initialize seabed images
  seaBedImages = {}
  seaBedImageCount = 16
  
  -- Insert images into seaBedTiles table
  for i = 1, seaBedImageCount do
    local image = love.graphics.newImage('images/PNG/Default size/fishTile_'..i..'.png')
    table.insert(seaBedImages, image)
  end
  
  seaBedHeight = seaBedImages[1]:getHeight()
  seaBedWidth = seaBedImages[1]:getWidth()
  
  -- Set default starting values for player and enemy fish
  playerStartSize = 1
  startingFishAmount = 500
  maxFishAmount = 10000
  
  -- Does all the load actions that would need to be repeated upon the game reseting
  reset()
end

function love.update(dt)
  if not pause then
    gameTimer = gameTimer + dt
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
end

function love.draw()
  if not pauseDraw then
    --Draw 3 copies of everything so that we can continuously wrap around the screen without any gaps
    for i = -1, 1 do
      adjustCamera(i)
      
      --Draw the sea
      love.graphics.draw(sea, 0, 0, 0, playAreaWidth, playAreaHeight)
      
      -- Draw the sky
      drawSky()
    end
    
    -- We use separate for loops to make sure our background is drawn before player and fish, so that we don't get parts of the fish cut off at the edge of the screen overlaps
    for i = -1, 1 do
      adjustCamera(i)
      
      -- Draw the player
      player:draw()
      
      -- Draw all other fish
      for i, v in ipairs(fishies) do
        v:draw()
      end
      
      -- Draw sea bed
      drawSeaBed(seaBed)
      
      -- Shows player's current level and experience points
      drawPlayerTable()
      
      -- Draw upgrades table
      player.upgrades:draw()
    end
  end
end

-- Adjust camera to allow for scrolling
function adjustCamera(i)
  love.graphics.origin()
  love.graphics.translate(i * playAreaWidth, 0)
  
  -- Have the camera follow the fish, but don't have it go below our seabed
  if player.y <= screenHeight / 2 + (playAreaHeight - screenHeight)  then
    love.graphics.translate(-player.x + screenWidth / 2, -player.y + screenHeight / 2)
  else
    -- Fixed y-axis translation after a certain point so that we don't scroll below our seabed
    love.graphics.translate(-player.x + screenWidth / 2, -(playAreaHeight - screenHeight))
  end
end

-- Generates a random fish to be added into the level
function addRandomFish()
  local fishType = love.math.random(#fishTypes)
  local fishSize = 1 + love.math.random()
  local fishX = love.math.random(playAreaWidth)
  local fishY = love.math.random(fishTypes[fishType]['upperBound'], fishTypes[fishType]['lowerBound'])
  
  -- We call different classes based on which fish we randomized
  if fishType == 1 then
    return Fish(fishX, fishY, fishSize)
  elseif fishType == 2 then
    return StealthFish(fishX, fishY, fishSize)
  elseif fishType == 3 then
    return GreenFish(fishX, fishY, fishSize)
  elseif fishType == 4 then
    return BigFish(fishX, fishY, fishSize)
  elseif fishType == 5 then
    return PufferFish(fishX, fishY, fishSize)
  end
end
  
function drawPlayerTable()
  local tableXPos = 10
  
  -- Reset origin so table will always be in same spot on screen
  love.graphics.origin()
  --love.graphics.setColor(0, 0, 0)
  --love.graphics.print('player x: '..player.x..' fish x '..fishies[1].x, 0, 0)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('Level: '..player.level, 10, screenHeight - 40)
  love.graphics.print('XP: '..math.floor(player.xp)..'/'..player.levelUps[player.level], 10, screenHeight - 20)
end
    
-- Draws a rectangle at the top of the screen, representing the sky
function drawSky()
  love.graphics.setColor(sky['color'])
  love.graphics.rectangle("fill", 0, -screenHeight / 2, sky['width'], sky['height'])
  love.graphics.setColor(1, 1, 1, 1)
end

-- Print a single tile
function drawTile(image, x, y)
  love.graphics.draw(image, x, y)
end

-- Print out our previously generated list of sea bed tiles
function drawSeaBed(seaBed)
  -- Determines y location of where we will draw our seabed tiles
  local y = playAreaHeight - seaBedHeight

  for i,v in ipairs(seaBed) do
    drawTile(seaBedImages[v], seaBedWidth * (i - 1), y)
  end
end

-- Choose random sea bed tiles and insert them into a table which will represent our seabed
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

-- Resets the game to starting values and creates new fish and seabed tables
function reset()
   -- Randomly pick seabed images to make up our seabed
  seaBed = randomizeSeaBed()
  
  -- Initialize game timer and pause status
  gameTimer = 0
  pause = false
  
  -- Initialize player
  player = Player(playAreaWidth / 2, 200, playerStartSize)
  
  -- Create enemy fish table and set fish amounts
  fishies = {}
  
  -- Populate game area with random fish
  for i = 1, startingFishAmount do
    table.insert(fishies, addRandomFish())
  end
  
  -- Makes stealth fish difficult to see again
  StealthFish:stealthOn()
end

function resolveCollision(player, fish, fishIndex)
  -- Check first if the fish is a puffer or if puffers are edible
  if fish.type ~= 'Puffer' or player.pufferEdible then
    -- If player is bigger, remove eaten fish and gain xp
    if player.realSize >= fish.realSize then
      table.remove(fishies, fishIndex)
      player:processXP(fish)
      
      -- Every time we eat a fish, we add two more in its place
      -- This keeps player from being able to focus too much on smaller fish
      -- We put a max amount just to make sure we don't completely break the game
      if #fishies < maxFishAmount then
        table.insert(fishies, addRandomFish())
        table.insert(fishies, addRandomFish())
      end
    -- If other fish is bigger, reset the game
    else
      reset()
    end
  else
    reset()
  end
end
    

-- Set player rotation back to zero whenever the w, s, down, or up keys are released
function love.keyreleased(key)
  if key == 'down' or key =='up' or key == 'w' or key == 's' then
    player.currentRotation = 0
  end
  
  -- p will be our pause button
  -- Check if we're upgrading so player can't unpause during upgrade screen
  if key == 'p' and not player.upgrades.upgrading then
    pause = not pause
  end
end

-- Select upgrades with left mouse button
function love.mousereleased(mouseX, mouseY, button)
  if player.upgrades.upgrading then
    if button == 1 then
      if player.upgrades.specializing then
        player.upgrades:selectUpgrade(mouseX, mouseY, player, player.upgrades.spButtons)
      else
        player.upgrades:selectUpgrade(mouseX, mouseY, player, player.upgrades.buttons)
      end
    end
  end
end


-- gradientMesh code taken from https://love2d.org/wiki/Gradients
local COLOR_MUL = love._version >= "11.0" and 1 or 255

function gradientMesh(dir, ...)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = select("#", ...)
    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
            meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
            meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
        end
    end

    -- Resulting Mesh has 1x1 image size
    return love.graphics.newMesh(meshData, "strip", "static")
end