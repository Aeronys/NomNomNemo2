Upgrades = Object:extend()

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