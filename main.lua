--Arkanoid game
local platform = require "platform"
local ball = require "ball"
local bricks = require "bricks"
local walls = require "walls"
local collisions = require "collisions"
local levels = require "levels"

local gamestate = "menu"


function switch_to_next_level(bricks, levels)
  if bricks.no_more_bricks then
    bricks.clear_level_bricks()
    if levels.current < #levels.sequence then
      levels.current = levels.current + 1
      local level_table = levels.require_current_level()
      bricks.construct_level(level_table)
      return true
    else
      gamestate = "gamefinished"
    end
  end
  return false
end

--Love callbacks
function love.keyreleased(key, code)
  if gamestate == "menu" then
    gamestate = "game"
    if key == "escape" then
      love.event.quit()
    end
  elseif gamestate == "gamepaused" then
    if key == "escape" then
      love.event.quit()
    elseif key == "return" then
      gamestate = "game"
    end
  elseif gamestate == "game" then
    if key == 'escape' then
      gamestate = "gamepaused"
    end
    if key == 'c' then
      bricks.clear_level_bricks()
    end
  elseif gamestate == "gamefinished" then
    if key == "return" then
      levels.current = 0
      switch_to_next_level(bricks, levels)
      ball.reposition()
      gamestate = "game"
    elseif key == "escape" then
      love.event.quit()
    end
  end
end

function love.update(dt)

  if gamestate == "menu" then
  elseif gamestate == "game" then
    ball.update(dt)
    platform.update(dt)
    bricks.update(dt)
    walls.update(dt)

    collisions.resolve(platform, ball, bricks, walls)

    if switch_to_next_level(bricks, levels) then
      ball.reposition()
    end
  elseif gamestate == "gamepaused" then

  elseif gamestate == "gamefinished" then

  end

  
end

function love.draw()
  love.graphics.setBackgroundColor(78, 74, 78)
  love.graphics.setColor(222,238,214)
  love.graphics.print("fps: "..tostring(love.timer.getFPS( )), 10, 10)
  
  if gamestate == "menu" then
    love.graphics.setColor(222,238,214)
    love.graphics.print("Press any key to start.", 280, 250)
  elseif gamestate == "gamepaused" then
    ball.draw()
    platform.draw()
    bricks.draw()
    walls.draw()
    love.graphics.setColor(222,238,214)
    love.graphics.print("Game is paused. Press Enter to continue or Esc to quit", 50, 50)
  elseif gamestate == "game" then
    ball.draw()
    platform.draw()
    bricks.draw()
    walls.draw()
  elseif gamestate == "gamefinished" then
    love.graphics.setColor(222,238,214)
    love.graphics.printf("Congrats!\n You have completed the game!\n Press Enter to continue or Esc to quit",
                          250, 250, 300, "center")
  end
end

function love.load()
  switch_to_next_level(bricks, levels)
  walls.construct_walls()
end

function love.quit()
  --print("Thanks for playing")
end