Entity = Object:extend()

function Entity:new(x, y, imagePath)
  self.x = x
  self.y = y
  self.imageData = love.image.newImageData(imagePath)
  self.image = love.graphics.newImage(self.imageData)
  self.width, self.height = self.imageData:getDimensions()
end