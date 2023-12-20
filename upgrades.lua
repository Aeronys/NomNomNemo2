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
  
  -- Upgrade Sound Effects
  sizeUpSE = love.audio.newSource('audio/soundEffects/sizeUp.wav', 'static')
  speedUpSE = love.audio.newSource('audio/soundEffects/speedUp.wav', 'static')
  stealthUpSE = love.audio.newSource('audio/soundEffects/stealthUp.wav', 'static')
  seeStealthSE = love.audio.newSource('audio/soundEffects/seeStealth.wav', 'static')
  eatPufferSE = love.audio.newSource('audio/soundEffects/eatPuffer.wav', 'static')
  
  -- Speed sound effect is so loud, save our ears
  speedUpSE:setVolume(.2)
  
  -- Lists text and corresponding functions for upgrade buttons
  self.upgrading = false
  self.upgradeList = {
    {['uText'] = 'Size Up', ['uFunction'] = self.grow, ['sound'] = sizeUpSE},
    {['uText'] = 'Speed Up', ['uFunction'] = self.speedUp, ['sound'] = speedUpSE},
    {['uText'] = 'Stealth Up', ['uFunction'] = self.stealthUp, ['sound'] = stealthUpSE}
  }
  

  -- Lists text and corresponding functions for specialization buttons
  self.specializing = false
  self.specialList = {
    {['uText'] = 'See Stealth Fish', ['uFunction'] = self.seeStealth, ['sound'] = seeStealthSE},
    {['uText'] = 'Eat Puffer Fish', ['uFunction'] = self.eatPuffer, ['sound'] = eatPufferSE},
  }
  
  self.buttons = {}
  for i = 1, #self.upgradeList do
    table.insert(self.buttons, {['xPos'] = self.xPos + ((self.width / (#self.upgradeList + 1)) * i) - (self.buttonWidth / 2), ['Type'] = self.upgradeList[i]['uText']})
  end
  
  self.spButtons = {}
  for i = 1, #self.specialList do
    table.insert(self.spButtons, {['xPos'] = self.xPos + ((self.width / (#self.specialList + 1)) * i) - (self.buttonWidth / 2), ['Type'] = self.specialList[i]['uText']})
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
  fish.sizeModifier = fish.sizeModifier + .125
  
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
  fish.stealth = fish.stealth + 70
end

function Upgrades:chooseUpgrade(fish)
  pause = true
  self.upgrading = true
  
  if fish.level == 5 or fish.level == 10 then
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
        self.specialList[i]['uFunction'](self, fish)
        self.specialList[i]['sound']:play()
        table.remove(self.spButtons, i)
        table.remove(self.specialList, i)
        self.specializing = false
      else
        -- Selects upgrade from ordered upgrade list
        self.upgradeList[i]['uFunction'](self, fish)
        self.upgradeList[i]['sound']:play()
      end
      
      -- Ends upgrading phase and resumes gameplay
      self.upgrading = false
      pause = false
      
      -- Call levelUp() again in case we've leveled up multiple times at once
      fish:levelUp()
      break
    end
  end
end