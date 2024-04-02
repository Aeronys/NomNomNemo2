io.stdout:setvbuf("no")

function love.load()
  Object = require "classic"
  require "entity"
  require "fish"
  require "bigFish"
  require "eel"
  require "greenFish"
  require "pufferFish"
  require "stealthFish"
  require "player"
  require "window"
  
  -- Set up audio files
  chomps = {}
  chompCount = 5
  for i = 1, chompCount do
    local sfx = love.audio.newSource('audio/soundEffects/nemoChomp'..i..'.wav', 'static')
    table.insert(chomps, sfx)
  end
  
  pop = love.audio.newSource('audio/soundEffects/pufferPop.wav', 'static')
  
  buttonClick = love.audio.newSource('audio/soundEffects/buttonClick.wav', 'static')
  buttonClick:setVolume(0.25)
  gulp = love.audio.newSource('audio/soundEffects/nemoGulp1.wav', 'static')
  waves = love.audio.newSource('audio/soundEffects/waves.wav', 'stream')
  waves:setLooping(true)
  
  bgm = love.audio.newSource('audio/music/aquarium-fish-132518.mp3', 'stream')
  bgmVolume = 0.1
  bgmOn = true
  bgm:setVolume(bgmVolume)
  bgm:setLooping(true)
  
  -- Play waves and background music
  waves:play()
  bgm:play()
  
  -- Set gradient for our sea color
  sea = gradientMesh("vertical", 
        {.1, .5, 1},
        {0, .1, .17}
  )
  
  -- Set fonts
  font24 = love.graphics.newFont(24)
  font21 = love.graphics.newFont(21)
  font18 = love.graphics.newFont(18)
  font15 = love.graphics.newFont(15)
  defaultFont = love.graphics.newFont(12)
  
  -- Level dimensions
  playAreaWidth = 5500
  playAreaHeight = 12000
  
  -- Get screen dimensions
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()
  
  -- Set up pause/victory screen and buttons
  mainScreen = Window(700, 500)
  mainButtonWidth = 128
  mainButtonHeight = 80
  mainButtonYOffset = 500
  mainButtonYPos = mainScreen.yPos + mainButtonYOffset
  
  mainButtonInfo = {
    {['uText'] = 'Reset Game',  ['sound'] = seeStealthSE},
    {['uText'] = 'Continue', ['sound'] = eatPufferSE}
  }
  mainButtons = mainScreen:prepareButtons(mainButtonInfo, mainButtonWidth)
  
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
  startingFishAmount = 350
  
  -- Does all the load actions that would need to be repeated upon the game reseting
  reset()
end

function love.update(dt)
  if not pause then
    gameTimer = gameTimer + dt
    formattedTimer = convertTimer()
    
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
    
    --Draw window based on game state
    --Priority goes victory > upgrade > pause
    if victory then
      drawVictory()
    elseif player.upgrades.upgrading then 
      player.upgrades:draw()
    elseif pause then
      drawPause()
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
  local fishType = fishTypesAllowed[love.math.random(#fishTypesAllowed)]
  local fishSize = 1 + love.math.random()
  local fishX = love.math.random(playAreaWidth)
  local fishY
  
  -- With 'BigFish' we make a special effort to spawn the smaller ones higher up and the big ones lower down
  if fishType == 'BigFish' then
    fishY = love.math.random(fishTypes[fishType]['upperBound'], fishTypes[fishType]['lowerBound']) + (1000 * fishSize)
  else
    fishY = love.math.random(fishTypes[fishType]['upperBound'], fishTypes[fishType]['lowerBound'])
  end
  
  -- Makes sure that new fish aren't spawned too close to the player
  while math.abs(player.x - fishX) <= fishTypes[fishType]['spawnBuffer'] and math.abs(player.y - fishY) <= fishTypes[fishType]['spawnBuffer'] do
    fishX = love.math.random(fishTypes[fishType]['upperBound'], fishTypes[fishType]['lowerBound'])
  end
    
  -- We call different classes based on which fish we randomized
  if fishType == 'Fish' then
    return Fish(fishX, fishY, fishSize)
  elseif fishType == 'StealthFish' then
    return StealthFish(fishX, fishY, fishSize)
  elseif fishType == 'GreenFish' then
    return GreenFish(fishX, fishY, fishSize)
  elseif fishType == 'BigFish' then
    return BigFish(fishX, fishY, fishSize)
  elseif fishType == 'PufferFish' then
    return PufferFish(fishX, fishY, fishSize)
  elseif fishType == 'Eel' then
    return Eel(fishX, fishY, fishSize)
  end
end
  
function convertTimer()
  -- Convert gamer timer into minutes, seconds, and milliseconds
  local gameMinutes = math.floor(gameTimer / 60)
  local gameSeconds = gameTimer % 60
  local gameMS = (gameSeconds * 100) % 100
  
  -- Format game time to look nicer on screen
  return string.format('%02i:%02i:%02i', gameMinutes, gameSeconds, gameMS)
end

function drawPlayerTable()
  local tableXPos = 10
  
  -- Reset origin so table will always be in same spot on screen
  love.graphics.origin()
  love.graphics.setColor(1, 1, 1)
  
  -- Print game time, player level, and xp
  love.graphics.print('Time Elapsed: '..formattedTimer, tableXPos, screenHeight - 60)
  love.graphics.print('Level: '..player.level, tableXPos, screenHeight - 40)
  love.graphics.print('XP: '..math.floor(player.xp)..'/'..player.levelUps[player.level], tableXPos, screenHeight - 20)
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

-- Draw pause screen
function drawPause()
  mainScreen.bgColor = {.5, .5, .5, .3}
  mainScreen:draw()
  mainScreen:drawLine('Game Paused', font24, 30)
  mainScreen:drawLine('Eat smaller fish, while avoiding the bigger fish!', font18, 80)
  mainScreen:drawLine('Current level: '..player.level, font15, 120, mainScreen.lvlColor)
  
  -- Display current upgrade levels
  for i,v in ipairs(player.upgrades.upgradeList) do
    mainScreen:drawLine(v['name']..': '..v['level'], defaultFont, 150 + ((i-1) * 20), mainScreen.lvlColor)
  end
  
  -- If player has specializations display them here
  if player.upgradeTracker then
    mainScreen:drawLine('Upgrades: '..player.upgradeTracker, font18, 315, mainScreen.lvlColor)
  end
  
  -- Reset and Continue buttons
  mainScreen:drawButtons(mainButtons, mainButtonWidth, mainButtonHeight, mainButtonYOffset, font15)
end

-- Draw victory screen
function drawVictory()
  pause = true
    
  mainScreen:draw()
  mainScreen:drawLine('Victory!', font24, 30, {0, 1, .9, 1})
  mainScreen:drawLine("By eating an eel, you've proven yourself ruler of the sea!", font18, 80)
  mainScreen:drawLine('Time taken: '..formattedTimer, font21, 140)
  mainScreen:drawLine('Fish eaten: '..player.eatCount, font21, 170)
  mainScreen:drawLine('Continue playing?', font21, 310)
  mainScreen:drawButtons(mainButtons, mainButtonWidth, mainButtonHeight, mainButtonYOffset, font15)
end

function eatFish(player, fish, fishIndex)
  -- Pufferfish make a popping sound when eaten, all other fish use the default chomping sound
  if fish.type == 'PufferFish' then
    pop:play()
  else
    local chomp = love.math.random(chompCount)
    chomps[chomp]:play()
  end
  
  player.eatCount = player.eatCount + 1
  table.remove(fishies, fishIndex)
  player:processXP(fish)
  
  if fish.type == 'Eel' and player.eelEaten == false then
    player.eelEaten = true
    victory = true
  end
  
  --Replace the fish we've just eaten
  table.insert(fishies, addRandomFish())
end
  
function eatPlayer()
  gulp:play()
  reset()
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
  -- We set here our boundaries for where each type of fish can be spawned
  -- Names need to match type of each fish class
  fishTypes = {
    ['Fish'] = {['upperBound'] = 0, ['lowerBound'] = 3000, ['spawnBuffer'] = 150, ['edible'] = true},
    ['StealthFish'] = {['upperBound'] = 2000, ['lowerBound'] = 7000, ['spawnBuffer'] = 300, ['edible'] = true},
    ['GreenFish'] = {['upperBound'] = 4500, ['lowerBound'] = 8000, ['spawnBuffer'] = 500, ['edible'] = true},
    ['BigFish'] = {['upperBound'] = 6000, ['lowerBound'] = 10000, ['spawnBuffer'] = 800, ['edible'] = true},
    ['PufferFish'] = {['upperBound'] = 3300, ['lowerBound'] = 11000, ['spawnBuffer'] = 1000, ['edible'] = false},
    ['Eel'] = {['upperBound'] = 0, ['lowerBound'] = playAreaHeight, ['spawnBuffer'] = 3000, ['edible'] = false}
    }
  
   -- Order of fish types matters, as that's what's used by our random function to determine which fish to spawn
  fishTypesAllowed = {'Fish', 'StealthFish', 'GreenFish', 'PufferFish'}
  
   -- Randomly pick seabed images to make up our seabed
  seaBed = randomizeSeaBed()
  
  -- Initialize game timer and pause status
  gameTimer = 0
  pause = false
  victory = false
  
  -- Initialize player
  player = Player(playAreaWidth / 2, 200, playerStartSize)
  
  -- Create enemy fish table and set fish amounts
  fishies = {}
  
  -- Populate game area with random fish
  for i = 1, startingFishAmount do
    table.insert(fishies, addRandomFish())
  end
  
  -- BigFish are now included in initial spawn
  table.insert(fishTypesAllowed, 'BigFish')
  
  -- Makes stealth fish difficult to see again
  -- This is done to keep the bottom of the ocean from being too overrun with BigFish by the time you're a high enough level to get there
  StealthFish:stealthOn()
end

function resolveCollision(player, fish, fishIndex)
  -- If fish is edible and player is bigger, then eat the fish, otherwise, eat the player
  if fishTypes[fish.type]['edible'] and player.realSize >= fish.realSize then
    eatFish(player, fish, fishIndex)
  else
    eatPlayer()
  end
end
    
function toggleBGM()
  if bgmOn then
    bgm:setVolume(0)
    bgmOn = false
  else
    bgm:setVolume(bgmVolume)
    bgmOn = true
  end
end

-- Simple returns true or false based on whether a mouse click has landed on a button
function buttonClicked(mouseX, mouseY, buttonX, buttonY, buttonWidth, buttonHeight)
  if mouseX >= buttonX and 
    mouseX <= buttonX + buttonWidth and 
    mouseY >= buttonY and 
    mouseY <= buttonY + buttonHeight then
      
    return true
  else
    return false
  end
end

-- Set player rotation back to zero whenever the w, s, down, or up keys are released
function love.keyreleased(key)
  if key == 'down' or key =='up' or key == 'w' or key == 's' then
    player.currentRotation = 0
  end
  
  -- Cheat to grow player's fish
  if key == 'g' and love.keyboard.isDown('lctrl') then
    player.upgrades:grow(player)
  end
  
   
  -- Cheat to increase player's speed
  if key == 's' and love.keyboard.isDown('lctrl') then
    player.upgrades:speedUp(player)
  end
  
  -- Cheat to instantly level up
  if key == 'l' and love.keyboard.isDown('lctrl') then
    if player.level < #player.levelUps then
      player.xp = player.levelUps[player.level]
      player:levelUp()
    end
  end
  
  -- p will be our pause button
  -- Check if we're upgrading so player can't unpause during upgrade screen
  if (key == 'p' or key == 'space' or key == 'escape') and not (player.upgrades.upgrading or victory) then
    pause = not pause
  end
  
  if key == 'm' then
    toggleBGM()
  end
end

-- Select upgrades with left mouse button
function love.mousereleased(mouseX, mouseY, button)
  if victory or (pause and not player.upgrades.upgrading) then
    -- First button is our reset button
    if buttonClicked(mouseX, mouseY, mainButtons[1]['xPos'], mainButtonYPos, mainButtonWidth, mainButtonHeight) then
      buttonClick:play()
      reset()
    -- Second button is the continue button
    elseif buttonClicked(mouseX, mouseY, mainButtons[2]['xPos'], mainButtonYPos, mainButtonWidth, mainButtonHeight) then
      buttonClick:play()
      victory = false
      -- Game should stay paused if player is upgrading
      if not player.upgrades.upgrading then
        pause = false
      end
    end
        
  elseif player.upgrades.upgrading then
    if button == 1 then
      -- Upgrades class handles processing of button clicks while upgrading
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