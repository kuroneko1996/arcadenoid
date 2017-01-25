--Arkanoid game
local platform = require "platform"
local ball = require "ball"
local bricks = require "bricks"
local walls = require "walls"
local collisions = require "collisions"
local levels = require "levels"
local game = require "game"
local nanogui = require "nanogui/nanogui"

local gamestate = "menu"

function start_game()
  game.score = 0
  game.lives = 3
  levels.current = 0
  switch_to_next_level(bricks, levels)
  ball.reposition()
  gamestate = "menu"
end

local slider_val = 0

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

function draw_score_lives()
  love.graphics.setColor(222,238,214)
  love.graphics.print("score: "..game.score, 10, 10)

  love.graphics.print("lives: "..game.lives, 90, 10)
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
      start_game()
    elseif key == "escape" then
      love.event.quit()
    end
  end
end

function love.update(dt)
  nanogui.pre()

  if gamestate == "menu" then
    nanogui.button("btn1", "Hey", 80, 80, 150, 40)
    nanogui.button("btn2", "Press Me", 260, 80, 150, 40)
    _, slider_val = nanogui.slider("sld1", slider_val, 0, 10, 80, 150, 256, 32)
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

  nanogui.after()
end

function love.draw()
  love.graphics.setBackgroundColor(78, 74, 78)
  love.graphics.setColor(222,238,214)
  love.graphics.print("fps: "..tostring(love.timer.getFPS( )), love.graphics.getWidth() - 55, 10)
  draw_score_lives()
  
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

  nanogui.draw()
end

function love.load()
  nanogui.init()

  collisions.on_brick_hit = game.set_score
  walls.construct_walls()
  start_game() 
end

function love.quit()
  --print("Thanks for playing")
end
