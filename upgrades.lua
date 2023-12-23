Upgrades = Object:extend()

function Upgrades:new()
  -- Create window for upgrades, along with button parameters
  upgradeScreen = Window(500, 300)
  
  self.buttonWidth = 64
  self.buttonHeight = 64
  self.buttonYOffset = 125
  self.buttonYPos = upgradeScreen.height + self.buttonYOffset
  
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
    {['uText'] = 'Size Up', ['uFunction'] = self.grow, ['sound'] = sizeUpSE, ['level'] = 1},
    {['uText'] = 'Speed Up', ['uFunction'] = self.speedUp, ['sound'] = speedUpSE, ['level'] = 1},
    {['uText'] = 'Stealth Up', ['uFunction'] = self.stealthUp, ['sound'] = stealthUpSE, ['level'] = 1}
  }

  -- Lists text and corresponding functions for specialization buttons
  self.specializing = false
  self.specialList = {
    {['uText'] = 'See Stealth Fish', ['uFunction'] = self.seeStealth, ['sound'] = seeStealthSE},
    {['uText'] = 'Eat Puffer Fish', ['uFunction'] = self.eatPuffer, ['sound'] = eatPufferSE},
    {['uText'] = 'Eat Bigger Fish (+10%)', ['uFunction'] = self.predatorOn, ['sound'] = eatPufferSE}
  }
  
  self.eelUpgrade = {['uText'] = 'Eat Eels (Any Size)', ['uFunction'] = self.eatEel, ['sound'] = eatPufferSE}

  self.buttons = {}
  for i = 1, #self.upgradeList do
    table.insert(self.buttons, {['xPos'] = upgradeScreen.xPos + ((upgradeScreen.width / (#self.upgradeList + 1)) * i) - (self.buttonWidth / 2), ['Type'] = self.upgradeList[i]['uText']})
  end
  
  self.spButtons = {}
  for i = 1, #self.specialList do
    table.insert(self.spButtons, {['xPos'] = upgradeScreen.xPos + ((upgradeScreen.width / (#self.specialList + 1)) * i) - (self.buttonWidth / 2), ['Type'] = self.specialList[i]['uText']})
  end
end

function Upgrades:draw()
  if self.upgrading then
    upgradeScreen:draw()
    upgradeScreen:drawLine('Level up!', font24, 20)
    love.graphics.setColor(lvlColor)
    upgradeScreen:drawLine('Level '..player.level, font21, 55)
    love.graphics.setColor(1, 1, 1)
    upgradeScreen:drawLine('Choose your upgrade:', font18, 90)
    
    if self.specializing then
      upgradeScreen:drawButtons(self.spButtons, self.buttonWidth, self.buttonHeight, self.buttonYOffset)
    else
      upgradeScreen:drawButtons(self.buttons, self.buttonWidth, self.buttonHeight, self.buttonYOffset)
    end
  end
end

--[[function Upgrades:drawButtons(buttons)
  -- Draw buttons from buttons list
  for i, v in ipairs(buttons) do
      love.graphics.setColor(buttonColor)
      love.graphics.rectangle('fill', v['xPos'], self.buttonYPos, self.buttonWidth, self.buttonHeight)
      if not self.specializing then
        love.graphics.setColor(lvlColor)
        love.graphics.printf('Lvl '..self.upgradeList[i]['level'], font15, v['xPos'], (self.buttonYPos - 20), self.buttonWidth, 'center')
      end
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.printf(v['Type'], v['xPos'], (self.buttonYPos + self.buttonHeight / 2) - 15, self.buttonWidth, 'center')
  end
end]]--

function Upgrades:eatPuffer(fish)
  fishTypes['PufferFish']['edible'] = true
end

function Upgrades:eatEel(fish)
  fishTypes['Eel']['edible'] = true
end

function Upgrades:grow(fish)
  fish.sizeModifier = fish.sizeModifier + .125
  
  -- New size means real and sized dimensions need to be updated
  fish:updateDimensions()
end

function Upgrades:predatorOn(fish)
  fish.predator = true
  fish:updateDimensions()
end

function Upgrades:seeStealth(fish)
  StealthFish:stealthOff()
end

function Upgrades:speedUp(fish)
  fish.moveSpeed = fish.moveSpeed + 55
end

function Upgrades:stealthUp(fish)
  fish.stealth = fish.stealth + 85
end

function Upgrades:chooseUpgrade(fish)
  pause = true
  self.upgrading = true
  
  if fish.level % 5 == 0 and fish.level <= 20 then
    self.specializing = true
    if fish.level == 20 then
      table.insert(self.specialList, self.eelUpgrade)
      table.insert(self.spButtons, {['xPos'] = upgradeScreen.xPos + ((upgradeScreen.width / (#self.specialList + 1))) - (self.buttonWidth / 2), ['Type'] = self.specialList[1]['uText']})
    end
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
        self.upgradeList[i]['level'] = self.upgradeList[i]['level'] + 1
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