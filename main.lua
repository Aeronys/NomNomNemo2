io.stdout:setvbuf("no")

function love.load()
  Object = require "classic"
  require "fish"
  require "player"
  
  --Set backround to a sea color
  love.graphics.setBackgroundColor(.1, .5, 1)
  
  playAreaWidth = love.graphics.getWidth()
  playAreaHeight = love.graphics.getHeight()
  
  player = Player(playAreaWidth/2, playAreaHeight/2)
  fish = {}
  startingFishAmount = 10
  
  -- Populate game area with random fish
  for i = 1, startingFishAmount do
    table.insert(fish, addRandomFish())
  end
end

function love.update(dt)
  player:update(dt)
  for i, v in ipairs(fish) do
    v:update(dt)
  end
end

function love.draw()
  for i,v in ipairs(fish) do
    if player:checkCollision(v) then
      table.remove(fish, i)
    end
  end
  
  player:draw()
  for i, v in ipairs(fish) do
    v:draw()
  end
end

-- Generates a random fish to be added into the level
function addRandomFish()
  local fishX = love.math.random(playAreaWidth)
  local fishY = love.math.random(playAreaHeight)
  return Fish(fishX, fishY, 'images/PNG/Default size/fishTile_074.png')
end