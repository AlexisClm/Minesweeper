local class = {}
local data = {}

function class.getBackgroundPlay()
  return data.background:play()
end

function class.getBackgroundStop()
  return data.background:stop()
end

function class.getLeftClick()
  data.leftClickClone = data.leftClick:clone()
  return data.leftClickClone:play()
end

function class.getRightClick()
  data.rightClickClone = data.rightClick:clone()
  return data.rightClickClone:play()
end

function class.getFloodFill()
  data.floodFillClone = data.floodFill:clone()
  return data.floodFillClone:play()
end

function class.getWinPlay()
  return data.win:play()
end

function class.getWinStop()
  return data.win:stop()
end

function class.getLosePlay()
  return data.lose:play()
end

local function initBackground() 
  data.background = love.audio.newSource("Assets/Sounds/Background.mp3", "static")
  data.background:setVolume(0.6)
end

local function initLeftClick() 
  data.leftClick = love.audio.newSource("Assets/Sounds/LeftClick.mp3", "static")
  data.leftClick:setVolume(0.8)
end

local function initRightClick() 
  data.rightClick = love.audio.newSource("Assets/Sounds/RightClick.mp3", "static")
  data.rightClick:setVolume(0.1)
end

local function initFloodFill() 
  data.floodFill = love.audio.newSource("Assets/Sounds/FloodFill.wav", "static")
  data.floodFill:setVolume(0.5)
end

local function initWin()
  data.win = love.audio.newSource("Assets/Sounds/Win.mp3", "static")
  data.win:setVolume(0.5)
end
local function initLose()
  data.lose = love.audio.newSource("Assets/Sounds/Lose.mp3", "static")
  data.lose:setVolume(0.5)
end

function class.load()
  initBackground()
  initLeftClick()
  initRightClick()
  initFloodFill()
  initWin()
  initLose()
end

return class