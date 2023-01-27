local screen = require("screen")
local grid = require("grid")
local sound = require("sound")

function love.load()
  screen.load()
  grid.load()
  sound.load()
end

function love.draw()
  grid.draw()
end

function love.update(dt)
  grid.update(dt)
end

function love.keypressed(key)
  grid.keypressed(key)
end

function love.mousereleased(x, y, button)
  grid.mousereleased(x, y, button)
end
