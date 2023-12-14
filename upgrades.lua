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
  
  upgrading = false
  upgradeTypes = {'Size Up', 'Speed Up', 'Stealth Up'}
  --upgradeFunctions = {self:grow()
  self.buttons = {}
  for i = 1, self.numOfButtons do
    table.insert(self.buttons, {['xPos'] = self.xPos + ((self.width / (self.numOfButtons + 1)) * i) - (self.buttonWidth / 2), ['Type'] = upgradeTypes[i]})
  end
end

function Upgrades:draw()
  if upgrading then
    love.graphics.setColor(.5, .5, .5)
    love.graphics.rectangle('fill', self.xPos, self.yPos, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('Level up!', Font24, self.xPos, self.yPos + 20, self.width, 'center')
    love.graphics.printf('Choose your upgrade:', Font15, self.xPos, self.yPos + 70, self.width, 'center')
    
    
    for i, v in ipairs(self.buttons) do
      love.graphics.setColor(.3, .3, .3)
      love.graphics.rectangle('fill', v['xPos'], self.buttonYPos, self.buttonWidth, self.buttonHeight)
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(v['Type'], v['xPos'], (self.buttonYPos + self.buttonHeight / 2) - 10, self.buttonWidth, 'center')
    end
    love.graphics.setColor(1, 1, 1)
  end
end

function Upgrades:grow(fish)
  fish.sizeModifier = fish.sizeModifier + .25
  
  -- New size means real and sized dimensions need to be updated
  fish:updateDimensions()
end

function Upgrades:speedUp(fish)
  fish.moveSpeed = fish.moveSpeed + 70
end

function Upgrades:stealthUp(fish)
  fish.stealth = fish.stealth + 40
end

function Upgrades:chooseUpgrade(fish)
  pause = true
  upgrading = true
end

function Upgrades:selectUpgrade(mouseX, mouseY, fish)
  for i, v in ipairs(self.buttons) do
    if mouseX >= v['xPos'] and 
    mouseX <= v['xPos'] + self.buttonWidth and 
    mouseY >= self.buttonYPos and 
    mouseY <= self.buttonYPos + self.buttonHeight then
      
      if i == 1 then
        self:grow(fish)
      elseif i == 2 then
        self:speedUp(fish)
      else
        self:stealthUp(fish)
      end
      
      upgrading = false
      pause = false
      break
    end
  end
end