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
  
  -- Lists text and corresponding functions for upgrade buttons
  self.upgrading = false
  upgradeList = {
    {['uText'] = 'Size Up', ['uFunction'] = self.grow},
    {['uText'] = 'Speed Up', ['uFunction'] = self.speedUp},
    {['uText'] = 'Stealth Up', ['uFunction'] = self.stealthUp}
  }
  

  -- Lists text and corresponding functions for specialization buttons
  self.specializing = false
  self.numOfSpecials = 2
  specialList = {
    {['uText'] = 'See Stealth Fish', ['uFunction'] = self.seeStealth},
    {['uText'] = 'Eat Puffer Fish', ['uFunction'] = self.eatPuffer},
  }
  
  --upgradeFunctions = self.grow
  self.buttons = {}
  for i = 1, self.numOfButtons do
    table.insert(self.buttons, {['xPos'] = self.xPos + ((self.width / (self.numOfButtons + 1)) * i) - (self.buttonWidth / 2), ['Type'] = upgradeList[i]['uText']})
  end
  
  self.spButtons = {}
  for i = 1, self.numOfSpecials do
    table.insert(self.spButtons, {['xPos'] = self.xPos + ((self.width / (self.numOfSpecials + 1)) * i) - (self.buttonWidth / 2), ['Type'] = specialList[i]['uText']})
  end
end

function Upgrades:draw()
  if self.upgrading then
    love.graphics.setColor(.5, .5, .5)
    love.graphics.rectangle('fill', self.xPos, self.yPos, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('Level up!', Font24, self.xPos, self.yPos + 20, self.width, 'center')
    love.graphics.printf('Choose your upgrade:', Font15, self.xPos, self.yPos + 70, self.width, 'center')
    
    if self.specializing then
      self:drawButtons(self.spButtons)
    else
      self:drawButtons(self.buttons)
    end
  end
end

function Upgrades:drawButtons(buttons)
  -- Draw buttons from buttons list
  for i, v in ipairs(buttons) do
      love.graphics.setColor(.3, .3, .3)
      love.graphics.rectangle('fill', v['xPos'], self.buttonYPos, self.buttonWidth, self.buttonHeight)
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(v['Type'], v['xPos'], (self.buttonYPos + self.buttonHeight / 2) - 15, self.buttonWidth, 'center')
  end
  love.graphics.setColor(1, 1, 1)
end

function Upgrades:eatPuffer(fish)
  fish.pufferEdible = true
end

function Upgrades:grow(fish)
  fish.sizeModifier = fish.sizeModifier + .25
  
  -- New size means real and sized dimensions need to be updated
  fish:updateDimensions()
end

function Upgrades:seeStealth(fish)
  StealthFish:stealthOff()
end

function Upgrades:speedUp(fish)
  fish.moveSpeed = fish.moveSpeed + 70
end

function Upgrades:stealthUp(fish)
  fish.stealth = fish.stealth + 40
end

function Upgrades:chooseUpgrade(fish)
  pause = true
  self.upgrading = true
  
  if fish.level == 5 then
    self.specializing = true
  end
end

function Upgrades:selectUpgrade(mouseX, mouseY, fish, buttons)
  for i, v in ipairs(buttons) do
    if mouseX >= v['xPos'] and 
      mouseX <= v['xPos'] + self.buttonWidth and 
      mouseY >= self.buttonYPos and 
      mouseY <= self.buttonYPos + self.buttonHeight then
      
      if self.specializing then
        --Selects specialization from special list
        specialList[i]['uFunction'](self, fish)
        self.specializing = false
      else
        -- Selects upgrade from ordered upgrade list
        upgradeList[i]['uFunction'](self, fish)
      end
      
      -- Ends upgrading phase and resumes gameplay
      self.upgrading = false
      pause = false
      break
    end
  end
end