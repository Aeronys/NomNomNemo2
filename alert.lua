Alert = Entity:extend()

function Alert:new(x, y, duration)
  Alert.super.new(self, x, y, 'images/PNG/Default size/fishTile_127.png')
  self.sizeMod = 0.35
  self.timer = 0
  self.duration = duration
  self.active = false
end