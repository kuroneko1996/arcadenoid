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

local gui_width = 300
local gui_heigth = 300
local gui_posx = 0
local gui_posy = 0

function start_game(state)
  game.score = 0
  game.lives = 3
  levels.current = 1
  start_level(bricks)
  ball.reposition()
  gamestate = state
end

function start_level(bricks)
  bricks.clear_level_bricks()
  local level_table = levels.require_current_level()
  bricks.construct_level(level_table)
end

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
  local xpos = 10
  local ypos = 10
  love.graphics.print("score: "..game.score, xpos, ypos)
  xpos = xpos + 80
  love.graphics.print("high score: "..game.highscore, xpos, ypos)
  xpos = xpos + 120
  love.graphics.print("lives: "..game.lives, xpos, ypos)
end

--Love callbacks
function love.keyreleased(key, code)
  if gamestate == "menu" then
    if key == "escape" then
      love.event.quit()
    end
  elseif gamestate == "options" then
    if key == "escape" then
      game.save_data()
      gamestate = "menu"
    end
  elseif gamestate == "gamepaused" then
    if key == "escape" then
      gamestate = "menu"
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
      start_game("menu")
    elseif key == "escape" then
      love.event.quit()
    end
  end
end

function love.update(dt)
  nanogui.pre()
  if gamestate == "menu" then
    local xpos = love.graphics.getWidth() / 2 - 150 / 2
    local ypos = gui_posy
    if nanogui.button("btn_start", "Start", xpos, ypos, 150, 40) then
      gamestate = "game"
    end
    ypos = ypos + 60
    if nanogui.button("btn_options", "Options", xpos, ypos, 150, 40) then
      gamestate = "options"
    end
    ypos = ypos + 60
    if nanogui.button("btn_quit", "Quit", xpos, ypos, 150, 40) then
      love.event.quit()
    end

    -- game is restarting
    if gamestate == "game" then
      start_game("game")
    end
  elseif gamestate == "options" then
    local xpos = love.graphics.getWidth() / 2 - 272 / 2
    local ypos = gui_posy
    if nanogui.button("btn_opt_back", "Back", xpos, ypos, 150, 40) then
      game.save_data()
      gamestate = "menu"
    end
    ypos = ypos + 40 + 32
    nanogui.label("l_title", "Options", xpos, ypos)
    ypos = ypos + 16 + 16
    nanogui.label("l_sound","Sound Volume", xpos, ypos)
    ypos = ypos + 16
    _, game.sfx_volume = nanogui.slider("sld1", game.sfx_volume, 0, 100, xpos, ypos, 256, 32)
    ypos = ypos + 32 + 10
    nanogui.label("l_music","Music Volume", xpos, ypos)
    ypos = ypos + 16
    _, game.music_volume = nanogui.slider("sld2", game.music_volume, 0, 100, xpos, ypos, 256, 32)

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
  
  if gamestate == "gamepaused" then
    ball.draw()
    platform.draw()
    bricks.draw()
    walls.draw()
    love.graphics.setColor(222,238,214)
    love.graphics.print("Game is paused. Press Enter to continue or Esc to quit to Menu", 50, 50)
    draw_score_lives()
  elseif gamestate == "game" then
    ball.draw()
    platform.draw()
    bricks.draw()
    walls.draw()
    draw_score_lives()
  elseif gamestate == "gamefinished" then
    love.graphics.setColor(222,238,214)
    love.graphics.printf("Congrats!\n You have completed the game!\n Press Enter to continue or Esc to quit",
                          250, 250, 300, "center")
    draw_score_lives()
  end

  nanogui.draw()
end

function love.load()
  game.load_data()

  gui_posx = love.graphics.getWidth() / 2 - gui_width / 2
  gui_posy = love.graphics.getHeight() / 2 - gui_heigth / 2 

  nanogui.init()

  collisions.on_brick_hit = game.set_score
  walls.construct_walls()
  start_game("menu") 
end

function love.quit()
  game.save_data()
  --print("Thanks for playing")
end
