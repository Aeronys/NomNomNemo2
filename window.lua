Window = Object:extend()

function Window:new(width, height)
   -- Dimensions and positioning of level up window
  self.width = width
  self.height = height
  self.xPos = screenWidth / 2 - self.width / 2
  self.yPos = screenHeight / 2 - self.height / 2
  
  --Color schemes
  lvlColor = {1, 1, .4, 1}
  bgColor = {.5, .5, .5, .2}
  buttonColor = {.3, .3, .3, .3}
end

function Window:draw()
  love.graphics.setColor(bgColor)
  love.graphics.rectangle('fill', self.xPos, self.yPos, self.width, self.height)
  love.graphics.setColor(1, 1, 1)
end

function Window:drawButtons(buttons, buttonWidth, buttonHeight, buttonYOffset)
  -- Draw buttons from buttons list
  local buttonYPos = self.height + buttonYOffset
  for i, v in ipairs(buttons) do
      love.graphics.setColor(buttonColor)
      love.graphics.rectangle('fill', v['xPos'], buttonYPos, buttonWidth, buttonHeight)
      --[[if not self.specializing then
        love.graphics.setColor(lvlColor)
        love.graphics.printf('Lvl '..self.upgradeList[i]['level'], font15, v['xPos'], (self.buttonYPos - 20), self.buttonWidth, 'center')
      end--]]
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.printf(v['Type'], v['xPos'], (buttonYPos + buttonHeight / 2) - 15, buttonWidth, 'center')
  end
end

function Window:drawLine(text, font, yOffset)
  love.graphics.printf(text, font, self.xPos, self.yPos + yOffset, self.width, 'center')
end