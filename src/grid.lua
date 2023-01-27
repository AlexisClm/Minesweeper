local screen = require("screen")
local sound = require("sound")

local class = {}
local data = {}
local images = {}
local mouse = {}
local cell = {}
local cellList = {}
local timer = {}
local offset = {}
local nb = {}
local rect = {}
local game = {}
local font = {}
local firstClick
local level
local rectEasyY
local rectNormalY
local rectHardY

local function getX(column)
  return offset.x + (column-1) * cell.w
end

local function getY(line)
  return offset.y + (line-1) * cell.h
end

local function getColumn(x)
  return math.floor((x - offset.x)/cell.w) + 1
end

local function getLine(y)
  return math.floor((y - offset.y)/cell.h) + 1
end

local function cellIsAvailable(line, column)
  if (line < 1) or (line > nb.lines) or (column < 1) or (column > nb.columns) then
    return false
  else
    return true
  end
end

local function loadImages()
  images.number = {}

  images.number[0]  = love.graphics.newImage("Assets/Images/0.png")
  images.number[1]  = love.graphics.newImage("Assets/Images/1.png")
  images.number[2]  = love.graphics.newImage("Assets/Images/2.png")
  images.number[3]  = love.graphics.newImage("Assets/Images/3.png")
  images.number[4]  = love.graphics.newImage("Assets/Images/4.png")
  images.number[5]  = love.graphics.newImage("Assets/Images/5.png")
  images.number[6]  = love.graphics.newImage("Assets/Images/6.png")
  images.number[7]  = love.graphics.newImage("Assets/Images/7.png")
  images.number[8]  = love.graphics.newImage("Assets/Images/8.png")

  images.background = love.graphics.newImage("Assets/Images/Background.jpg")
  images.preshot    = love.graphics.newImage("Assets/Images/Preshot.png")
  images.hide       = love.graphics.newImage("Assets/Images/Hide.png")
  images.flagTrue   = love.graphics.newImage("Assets/Images/FlagTrue.png")
  images.flagFalse  = love.graphics.newImage("Assets/Images/FlagFalse.png")
  images.mines      = love.graphics.newImage("Assets/Images/Mines.png")
  images.mine       = love.graphics.newImage("Assets/Images/Mine.png")
end

local function initSettings(type)
  level = type

  if (level == "easy") then
    nb.lines   = 5
    nb.columns = 5
    nb.mines   = 4

  elseif (level == "normal") then
    nb.lines   = 12
    nb.columns = 15
    nb.mines   = 30

  elseif (level == "hard") then
    nb.lines   = 20
    nb.columns = 25
    nb.mines   = 99
  end

  font.game   = love.graphics.newFont("Assets/Font/Font.TTF", 30)
  font.cell   = love.graphics.newFont("Assets/Font/Font.TTF", 15)
  cell.w      = 32
  cell.h      = 32
  offset.x    = (screen.getWidth() - nb.columns * cell.w)/2
  offset.y    = (screen.getHeight() - nb.lines * cell.h)/2 + 20
  game.over   = false
  game.win    = false
  timer.time  = 0
  timer.state = false
  firstClick  = false

  rect.w = 80
  rect.h = 80
  rect.x = 15

  rectEasyY   = 100
  rectNormalY = 300
  rectHardY   = 500
end

local function initGrid()
  cellList = {}

  for line = 1, nb.lines do
    data[line] = {}
    for column = 1, nb.columns do
      data[line][column] = {value = 0, hide = true, flag = false, bomb = false}
      table.insert(cellList, {line = line, column = column})
    end
  end
end

local function initMines()
  local random

  for i = 1, nb.mines do
    random = table.remove(cellList, love.math.random(#cellList))
    data[random.line][random.column].value = 9
    for line = -1, 1 do
      for column = -1, 1 do
        if (cellIsAvailable(random.line + line, random.column + column)) and (data[random.line + line][random.column + column].value ~= 9) then
          data[random.line + line][random.column + column].value = data[random.line + line][random.column + column].value + 1
        end
      end
    end
  end
end

function class.load()
  loadImages()
  initSettings("easy")
  initGrid()
end

local function updateMouse()
  local x      = love.mouse.getX()
  local y      = love.mouse.getY()
  local column = getColumn(x)
  local line   = getLine(y)

  mouse.x = -cell.w
  mouse.y = -cell.h

  if (cellIsAvailable(line, column)) and (data[line][column].hide) and (not data[line][column].flag) then
    mouse.x = column * cell.w + offset.x - cell.w
    mouse.y = line * cell.h + offset.y - cell.h
  end
end

local function updateTimer(dt)
  if (timer.state) then
    timer.time = timer.time + dt
    if (game.over) or (game.win) then
      timer.state = false
    end
  end
end

local function updateSoundBackground()
  if (not game.win) and (not game.over) and (firstClick) then
    sound.getBackgroundPlay()
  end
end

function class.update(dt)
  updateMouse()
  updateTimer(dt)
  updateSoundBackground()
end

local function drawBackground()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(images.background)
end

local function drawGrid()
  for line = 1, nb.lines do
    for column = 1, nb.columns do
      local x = getX(column)
      local y = getY(line)

--      Case cachée
      if (data[line][column].hide) then
        love.graphics.draw(images.hide, x, y)
      end

--      Drapeau
      if (data[line][column].flag) then
        love.graphics.draw(images.flagTrue, x, y)

--          Fausse prédiction du drapeau
        if (game.over) and (data[line][column].value ~= 9) then
          love.graphics.draw(images.flagFalse, x, y)
        end
      end

--      Drapeaux même s'ils ne sont pas marqués par le joueur à la victoire
      if (game.win) and (data[line][column].hide) then
        love.graphics.draw(images.flagTrue, x, y)
      end

--      Nombre de mines autour de la case
      if (data[line][column].hide == false) and (data[line][column].value ~= 9) then
        love.graphics.draw(images.number[data[line][column].value], x, y)
      end

--      Mine
      if (data[line][column].value == 9) and (not data[line][column].flag) and (game.over) then
        love.graphics.draw(images.mines, x, y)
      end

--      Mine où le joueur a perdu
      if (data[line][column].bomb) then
        love.graphics.draw(images.mine, x, y)
      end
    end
  end

--  Surbrillance de la case
  if (not game.over) and (not game.win) then
    love.graphics.draw(images.preshot, mouse.x, mouse.y)
  end
end

local function drawHUD()  
--  Nombre de mines restantes
  love.graphics.setFont(font.game)
  love.graphics.setColor(1, 0, 0)
  love.graphics.printf("Mines : "..nb.mines, 0, 35, screen.getWidth()/2, "center")

  --  Timer
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("Time : "..math.floor(timer.time), screen.getWidth()/2, 35, screen.getWidth()/2, "center")

--  Game Win
  if (game.win) then
    love.graphics.printf("YOU WIN ! PRESS <SPACE> TO RESTART", 0, screen.getHeight() - 35, screen.getWidth(), "center")
  elseif (game.over) then
    love.graphics.printf("YOU LOSE ! PRESS <SPACE> TO RESTART", 0, screen.getHeight() - 35, screen.getWidth(), "center")
  end

--  Difficultés
  love.graphics.setFont(font.cell)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", rect.x, rectEasyY, rect.w, rect.h)
  love.graphics.printf("Easy", rect.x, 135, rect.w, "center")

  love.graphics.rectangle("line", rect.x, rectNormalY, rect.w, rect.h)
  love.graphics.printf("Normal", rect.x, 335, rect.w, "center")

  love.graphics.rectangle("line", rect.x, rectHardY, rect.w, rect.h)
  love.graphics.printf("Hard", rect.x, 535, rect.w, "center")

  if (game.win) and (timer.time < 2) then
    love.graphics.printf(math.floor(timer.time).." second !", 0, 45, screen.getWidth(), "center")
  elseif (game.win) and (timer.time >= 2) then
    love.graphics.printf(math.floor(timer.time).." seconds !", 0, 45, screen.getWidth(), "center")
  end
end

function class.draw()
  drawBackground()
  drawGrid()
  drawHUD()
end

function class.keypressed(key)
  if (key == 'space') then
    if (level == "easy") then
      initSettings("easy")
    elseif (level == "normal") then
      initSettings("normal")
    elseif (level == "hard") then
      initSettings("hard")
    end
    initGrid()
    sound.getBackgroundStop()
    sound.getWinStop()
    sound.getWinStop()
  elseif (key == "escape") then
    love.event.quit()
  end
end

local function checkWin(line, column)
  local openCell = 0

  for line = 1, nb.lines do
    for column = 1, nb.columns do
      if (not data[line][column].hide) and (data[line][column].value ~= 9) then
        openCell = openCell + 1
      end
    end
  end

  if (openCell == #cellList + nb.freeCell) then
    game.win = true
    nb.mines = 0
    sound.getBackgroundStop()
    sound.getWinPlay()
  end
end

local function checkLose(line, column)
  if (data[line][column].value == 9) then
    game.over = true
    data[line][column].bomb = true
    sound.getBackgroundStop()
    sound.getLosePlay()
  end
end

local function floodFill(line, column)
  local openList = {}

  table.insert(openList, {line = line, column = column})

  while (#openList > 0) do
    local currentCell = table.remove(openList, 1)
    for checkLine = currentCell.line - 1, currentCell.line + 1 do
      for checkColumn = currentCell.column - 1, currentCell.column + 1 do
        if (cellIsAvailable(checkLine, checkColumn)) and (data[checkLine][checkColumn].hide) and (not data[checkLine][checkColumn].flag) then
          if (data[checkLine][checkColumn].value == 0) then
            data[checkLine][checkColumn].hide = false
            sound.getFloodFill()
            table.insert(openList, {line = checkLine, column = checkColumn})
          elseif (data[checkLine][checkColumn].value < 9) then
            data[checkLine][checkColumn].hide = false
          end
        end
      end
    end
  end
end

local function freeCell(line, column)
  nb.freeCell = 0
  for lineFree = line + 1, line - 1, -1 do
    for columnFree = column + 1, column - 1, -1 do
      if (cellIsAvailable(lineFree, columnFree)) then
        nb.freeCell = nb.freeCell + 1
        table.remove(cellList, (lineFree -1) * nb.columns + columnFree)
      end
    end
  end
end

local function freeCell2(line, column)
  for lineFree = line - 1, line + 1 do
    for columnFree = column - 1, column + 1 do
      if (cellIsAvailable(lineFree, columnFree)) then
        if (not data[lineFree][columnFree].flag) then
          floodFill(line, column)
          checkLose(lineFree, columnFree)
        end
      end
    end
  end
end

local function flagAround(line, column)
  local flag = 0

  for lineFree = line - 1, line + 1 do
    for columnFree = column - 1, column + 1 do
      if (cellIsAvailable(lineFree, columnFree)) then
        if (data[lineFree][columnFree].flag) and (not data[line][column].hide) then
          flag = flag + 1
        end
      end
    end
  end
  if (flag == data[line][column].value) then
    freeCell2(line, column)
  end
end

local function colPointRect(x, y, a, b)
  if (x > a.x) and (x < a.x + a.w) and (y < b + a.h) and (y > b) then
    return true
  else
    return false
  end
end

local function setLevel(x, y, button)
  if (button == 1) and (colPointRect(x, y, rect, rectEasyY)) then
    initSettings("easy")
    initGrid()
    sound.getBackgroundStop()
    sound.getWinStop()
    sound.getLeftClick()
  elseif (button == 1) and (colPointRect(x, y, rect, rectNormalY)) then
    initSettings("normal")
    initGrid()
    sound.getBackgroundStop()
    sound.getWinStop()
    sound.getLeftClick()
  elseif (button == 1) and (colPointRect(x, y, rect, rectHardY)) then
    initSettings("hard")
    initGrid()
    sound.getBackgroundStop()
    sound.getWinStop()
    sound.getLeftClick()
  end
end

local function putFlag(line, column)
  if (data[line][column].hide) and (not data[line][column].flag) then
    data[line][column].flag = true
    nb.mines = nb.mines - 1
  elseif (data[line][column].flag) then
    data[line][column].flag = false
    nb.mines = nb.mines + 1
  end
end

function class.mousereleased(x, y, button)
  local column = getColumn(x)
  local line = getLine(y)

--  Choix de la difficulté
  setLevel(x, y, button)

  if (button == 1) and (not game.win) and (not game.over) and (cellIsAvailable(line, column)) and (not data[line][column].flag) then

--    1er clic safe
    if (not firstClick) then
      freeCell(line, column)
      initMines()
      firstClick = true
      timer.state = true
    end

--    Clic gauche pour découvrir la case survolée ou clic gauche sur un chiffre si le nb de drapeaux est = au chiffre
    flagAround(line, column)
    data[line][column].hide = false

    if (data[line][column].value == 0) then
      floodFill(line, column)
    end

--    Vérification de victoire/défaite
    checkLose(line, column)
    checkWin(line, column)

    if (data[line][column].value ~= 0) then
      sound.getLeftClick()
    end

  elseif (button == 2) and (not game.win) and (not game.over) and (cellIsAvailable(line, column)) then

--    Clic droit pour mettre ou retirer un drapeau
    putFlag(line, column)
    timer.state = true
    if (data[line][column].hide) then
      sound.getRightClick()
      sound.getBackgroundPlay()
    end
  end
end

return class