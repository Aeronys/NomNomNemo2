Upgrades = Object:extend()

function Upgrades:new()
   -- Dimensions and positioning of level up window
  self.width = 500
  self.height = 300
  self.xPos = screenWidth / 2 - self.width / 2
  self.yPos = screenHeight / 2 - self.height / 2
  
  -- Dimensions and positions of level up buttons
  self.numOfButtons = 3
  self.buttonWidth = 64
  self.buttonHeight = 64
  self.buttonYPos = self.yPos + 150
  
  self.buttons = {}
  for i = 1, self.numOfButtons do
    table.insert(self.buttons, {['xPos'] = self.xPos + ((self.width / (self.numOfButtons + 1)) * i) - (self.buttonWidth / 2)})
  end
end

function Upgrades:draw()
  love.graphics.setColor(.5, .5, .5)
  love.graphics.rectangle('fill', self.xPos, self.yPos, self.width, self.height)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf('Level up!', Font24, self.xPos, self.yPos + 20, self.width, 'center')
  love.graphics.printf('Choose your upgrade:', Font15, self.xPos, self.yPos + 70, self.width, 'center')
  
  love.graphics.setColor(.3, .3, .3)
  for i, v in ipairs(self.buttons) do
    love.graphics.rectangle('fill', v['xPos'], self.buttonYPos, self.buttonWidth, self.buttonHeight)
  end
  love.graphics.setColor(1, 1, 1)
end

function Upgrades:grow(fish)
  fish.sizeModifier = fish.sizeModifier * 1.25
  
  -- New size means real and sized dimensions need to be updated
  fish:updateDimensions()
end

function Upgrades:speedUp(fish)
  fish.moveSpeed = fish.moveSpeed + 70
end

function Upgrades:stealthUp(fish)
  fish.stealth = fish.stealth + 30
end

function Upgrades:chooseUpgrade(fish)
  pause = true
  upgrading = true
end