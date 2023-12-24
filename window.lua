Window = Object:extend()

function Window:new(width, height)
   -- Dimensions and positioning of level up window
  self.width = width
  self.height = height
  self.xPos = screenWidth / 2 - self.width / 2
  self.yPos = screenHeight / 2 - self.height / 2
  
  --Color schemes
  self.lvlColor = {1, 1, .4, 1}
  self.bgColor = {.5, .5, .5, .2}
  self.buttonColor = {.3, .3, .3, .3}
end

function Window:draw()
  love.graphics.setColor(self.bgColor)
  love.graphics.rectangle('fill', self.xPos, self.yPos, self.width, self.height)
  love.graphics.setColor(1, 1, 1)
end

-- Draw buttons at a specified position in our window
function Window:drawButtons(buttons, buttonWidth, buttonHeight, buttonYOffset, font, headingsOn, headings, headingsColor)
  local buttonYPos = self.yPos + buttonYOffset
  for i, v in ipairs(buttons) do
      love.graphics.setColor(self.buttonColor)
      love.graphics.rectangle('fill', v['xPos'], buttonYPos, buttonWidth, buttonHeight)
      -- Headings are optional
      if headingsOn then
        love.graphics.setColor(headingsColor)
        love.graphics.printf(headings[i], font15, v['xPos'], (buttonYPos - 20), buttonWidth, 'center')
      end
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.printf(v['Type'], font, v['xPos'], (buttonYPos + buttonHeight / 2) - 15, buttonWidth, 'center')
  end
end

-- Draw a single line of text at a specified position within our window
function Window:drawLine(text, font, yOffset, color)
  if color then
    love.graphics.setColor(color)
  end
  love.graphics.printf(text, font, self.xPos, self.yPos + yOffset, self.width, 'center')
  love.graphics.setColor(1, 1, 1, 1)
end

-- prepareButtons is separate from drawButtons because other functions need to know button position to see if buttons are clicked on
function Window:prepareButtons(buttonInfoList, buttonWidth)
  local buttons = {}
  for i,v in ipairs(buttonInfoList) do
    table.insert(buttons, {['xPos'] = self.xPos + ((self.width / (#buttonInfoList + 1)) * i) - (buttonWidth / 2), ['Type'] = v['uText']})
  end
  return buttons
end
  