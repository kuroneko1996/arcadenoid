--Arkanoid game
local platform = require "platform"
local ball = require "ball"
local bricks = require "bricks"
local walls = require "walls"
local collisions = require "collisions"
local levels = require "levels"
local bonuses = require "bonuses"
local game = require "game"
local nanogui = require "nanogui/nanogui"

local Animation = require "animation"

local gamestate = "menu"

local gui_width = 300
local gui_heigth = 300
local gui_posx = 0
local gui_posy = 0
local joystick = nil

local t = 0

function start_game()
  game.score = 0
  game.lives = 3
  levels.current = 1
  start_level(bricks)
  ball.reposition()
  gamestate = "game"
end

function add_bonus(bonus_type, x, y)
  local bonus = bonuses.create(bonus_type, x, y)
  bonus.animation = game.add_animation(bonus.sprite)
  table.insert(bonuses.bonuses, bonus)
end

function spawn_bonus(x, y, random_number)
  add_bonus("laser", x, y)
end

function start_level(bricks)
  bricks.clear_level_bricks()
  local level_table = levels.require_current_level()
  bricks.construct_level(level_table)
  
  --add_bonus("laser", 20, 50)
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
      change_state("gamefinished")
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
  
  local lives_width = 32
  local lives_height = 10
  for l = 1, game.lives do
    xpos = xpos + (lives_width+4) * (l-1)
    love.graphics.draw(game.lives_image, xpos, ypos + lives_height / 2)
  end
end

function handle_input(key, jbutton)
  if gamestate == "menu" then
    if key == "escape" then
      love.event.quit()
    end
  elseif gamestate == "options" then
    if key == "escape" or jbutton == "b" then
      game.save_data()
      change_state("menu")
    end
  elseif gamestate == "gamepaused" then
    if key == "escape" or jbutton == "b" then
      change_state("menu")
    elseif key == "return" or jbutton == "a" or jbutton == "start" then
      change_state("game")
    end
  elseif gamestate == "game" then
    if key == "escape" or jbutton == "start" then
      change_state("gamepaused")
    end
    if key == 'c' or key == "back" then
      bricks.clear_level_bricks()
    end
  elseif gamestate == "gamefinished" then
    if key == "return" or jbutton == "a" or jbutton == "start" then
      change_state("menu")
    elseif key == "escape" or jbutton == "b" then
      love.event.quit()
    end
  end
end

function change_state(new_state)
  if gamestate ~= new_state then
    nanogui.change_page()
  end
  gamestate = new_state
end

--Love callbacks
function love.keyreleased(key, code)
  handle_input(key)
end

function love.gamepadreleased(joystick, button)
  handle_input(nil, button)
end

function love.keypressed(key, isrepeat)
  nanogui.keypressed(key, isrepeat)
end

function love.gamepadpressed(joystick, button)
  nanogui.gamepadpressed(joystick, button)
end

function love.update(dt)
  t = t + 1
  nanogui.pre(joystick)
  game.update_animations(dt)

  if gamestate == "menu" then
    local xpos = love.graphics.getWidth() / 2 - 150 / 2
    local ypos = gui_posy
    if nanogui.button("btn_start", "Start", xpos, ypos, 150, 40) then
      change_state("game")
    else
      ypos = ypos + 60
      if nanogui.button("btn_options", "Options", xpos, ypos, 150, 40) then
        change_state("options")
      else
        ypos = ypos + 60
        if nanogui.button("btn_quit", "Quit", xpos, ypos, 150, 40) then
          love.event.quit()
        end
      end
    end

    -- game is restarting
    if gamestate == "game" then
      start_game()
    end
  elseif gamestate == "options" then
    local xpos = love.graphics.getWidth() / 2 - 272 / 2
    local ypos = gui_posy
    if nanogui.button("btn_opt_back", "Back", xpos, ypos, 150, 40) then
      game.save_data()
      change_state("menu")
    else
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
    end
  elseif gamestate == "game" then
    ball.update(dt)
    platform.update(dt, joystick)
    bricks.update(dt)
    walls.update(dt)
    bonuses.update(dt)

    collisions.resolve(platform, ball, bricks, walls, bonuses)

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
    bonuses.draw()
    draw_score_lives()
  elseif gamestate == "gamefinished" then
    love.graphics.setColor(222,238,214)
    love.graphics.printf("Congrats!\n You have completed the game!\n Press Enter to continue or Esc to quit",
                          250, 250, 300, "center")
    draw_score_lives()
  end

  nanogui.draw()
end

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  local joysticks = love.joystick.getJoysticks()
  joystick = joysticks[1]

  game.load_assets()
  game.load_data()
  
  gui_posx = love.graphics.getWidth() / 2 - gui_width / 2
  gui_posy = love.graphics.getHeight() / 2 - gui_heigth / 2 

  nanogui.init()

  collisions.on_brick_hit = game.set_score
  bricks.spawn_bonus = spawn_bonus
  walls.construct_walls()
  change_state("menu") 
end

function love.quit()
  game.save_data()
  --print("Thanks for playing")
end
