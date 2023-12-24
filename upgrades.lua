Upgrades = Object:extend()

function Upgrades:new()
  -- Create window for upgrades, along with button parameters
  self.upgradeScreen = Window(500, 300)
  
  self.buttonWidth = 64
  self.buttonHeight = 64
  self.buttonYOffset = 200
  self.buttonYPos = self.upgradeScreen.yPos + self.buttonYOffset
  
  -- Upgrade Sound Effects
  sizeUpSE = love.audio.newSource('audio/soundEffects/sizeUp.wav', 'static')
  speedUpSE = love.audio.newSource('audio/soundEffects/speedUp.wav', 'static')
  stealthUpSE = love.audio.newSource('audio/soundEffects/stealthUp.wav', 'static')
  seeStealthSE = love.audio.newSource('audio/soundEffects/seeStealth.wav', 'static')
  eatPufferSE = love.audio.newSource('audio/soundEffects/pufferPop.wav', 'static')
  eatEelSE = love.audio.newSource('audio/soundEffects/eelSlurper.wav', 'static')
  predatorSE = love.audio.newSource('audio/soundEffects/predator.wav', 'static')
  
  
  -- Speed sound effect is so loud, save our ears
  speedUpSE:setVolume(.2)
  
  -- Lists text and corresponding functions for upgrade buttons
  self.upgrading = false
  self.upgradeList = {
    {['name'] = 'Size', ['uText'] = 'Size Up', ['uFunction'] = self.grow, ['sound'] = sizeUpSE, ['level'] = 1},
    {['name'] = 'Speed', ['uText'] = 'Speed Up', ['uFunction'] = self.speedUp, ['sound'] = speedUpSE, ['level'] = 1},
    {['name'] = 'Stealth', ['uText'] = 'Stealth Up', ['uFunction'] = self.stealthUp, ['sound'] = stealthUpSE, ['level'] = 1}
  }

  -- Lists text and corresponding functions for specialization buttons
  self.specializing = false
  self.specialList = {
    {['name'] = 'Observant', ['uText'] = 'See Stealth Fish', ['uFunction'] = self.seeStealth, ['sound'] = seeStealthSE},
    {['name'] = 'Puffer Popper', ['uText'] = 'Eat Puffer Fish', ['uFunction'] = self.eatPuffer, ['sound'] = eatPufferSE},
    {['name'] = 'Predator', ['uText'] = 'Eat Bigger Fish (+10%)', ['uFunction'] = self.predatorOn, ['sound'] = predatorSE}
  }
  
  -- Eel upgrade doesn't unlock until level 20
  self.eelUpgrade = {['name'] = 'Eel Slurper', ['uText'] = 'Eat Eels (Any Size)', ['uFunction'] = self.eatEel, ['sound'] = eatEelSE}
  
  -- Prepare buttons for our upgrades
  self.buttons = self.upgradeScreen:prepareButtons(self.upgradeList, self.buttonWidth)
  self.spButtons = self.upgradeScreen:prepareButtons(self.specialList, self.buttonWidth)
end

function Upgrades:draw()
  self.upgradeScreen:draw()
  self.upgradeScreen:drawLine('Level up!', font24, 20)
  self.upgradeScreen:drawLine('Level '..player.level, font21, 55, self.upgradeScreen.lvlColor)
  self.upgradeScreen:drawLine('Choose your upgrade:', font18, 90)
  
  if self.specializing then
    self.upgradeScreen:drawButtons(self.spButtons, self.buttonWidth, self.buttonHeight, self.buttonYOffset, defaultFont)
  else
    -- Prepare our lvl headings over each of our buttons
    local buttonHeadings = {}
    for i,v in ipairs(self.upgradeList) do
      table.insert(buttonHeadings, 'Lvl '..v['level'])
    end
    self.upgradeScreen:drawButtons(self.buttons, self.buttonWidth, self.buttonHeight, self.buttonYOffset, defaultFont, true, buttonHeadings, self.upgradeScreen.lvlColor)
  end
end

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
  fish.stealth = fish.stealth + 90
end

function Upgrades:chooseUpgrade(fish)
  pause = true
  self.upgrading = true
  
  if fish.level % 5 == 0 and fish.level <= 20 then
    self.specializing = true
    if fish.level == 20 then
      table.insert(self.specialList, self.eelUpgrade)
      table.insert(self.spButtons, {['xPos'] = self.upgradeScreen.xPos + ((self.upgradeScreen.width / (#self.specialList + 1))) - (self.buttonWidth / 2), ['Type'] = self.specialList[1]['uText']})
    end
  end
end

function Upgrades:selectUpgrade(mouseX, mouseY, fish, buttons)
  for i, v in ipairs(buttons) do
    if buttonClicked(mouseX, mouseY, v['xPos'], self.buttonYPos, self.buttonWidth, self.buttonHeight) then
      if self.specializing then
        --Selects specialization from special list
        self.specialList[i]['uFunction'](self, fish)
        self.specialList[i]['sound']:play()
        if fish.upgradeTracker == nil then
          fish.upgradeTracker = self.specialList[i]['name']
        else
          fish.upgradeTracker = fish.upgradeTracker..', '..self.specialList[i]['name']
        end
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