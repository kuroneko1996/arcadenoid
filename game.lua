local Animation = require "animation"

local game = {}
game.highscore = 0
game.score = 0
game.lives = 3
game.sfx_volume = 100
game.music_volume = 100

game.spritesheets = {}
game.animations = {}

local save_fields = {"highscore", "sfx_volume", "music_volume"}

function game.load_assets()
  game.lives_image = love.graphics.newImage("assets/lives.png")

  game.load_spritesheet("bonus_laser", 28, 12)
end

function game.load_spritesheet(name, width, height)
  game.spritesheets[name] = {}
  local sheet = game.spritesheets[name]
  sheet.image = love.graphics.newImage("assets/"..name..".png")
  local image_width = sheet.image:getWidth()
  local image_height = sheet.image:getHeight()

  sheet.frame_width = width or 32
  sheet.frame_height = height or 32
  sheet.frames_number = math.floor(image_width / sheet.frame_width)
  sheet.frames = {}

  for i = 1, sheet.frames_number do
    table.insert(sheet.frames, 
                 love.graphics.newQuad((i-1)*sheet.frame_width, 0, sheet.frame_width, sheet.frame_height, image_width, image_height))
  end
end  

function game.update_animations(dt)
  for anim, k in pairs(game.animations) do
    anim:update(dt)
  end
end

function game.draw_animation(anim, x, y)
  game.animations[anim]:draw(x, y)
end

function game.add_animation(name, duration)
  local anim = Animation.new(game.spritesheets[name].image, game.spritesheets[name].frames, duration)
  --game.animations[anim] = 1
  return anim
end

function game.set_score(brick_type)
  if brick_type ~= 8 then
    game.score = game.score + 10
  end

  if game.score > game.highscore then
    game.highscore = game.score
  end
end

function game.save_data()
  local f = love.filesystem.newFile("data.txt")
  f:open("w")

  for _, field in pairs(save_fields) do
    f:write(field.."="..game[field].."\n")
  end
  f:close()
end

function game.load_data()
  local contents = love.filesystem.read("data.txt")
  if contents ~= nil then
    for str in string.gmatch(contents, "%S+") do
      local index = str:find("=")
      if index ~= nil then
        local field_name = str:sub(1, index-1)
        local field_value = str:sub(index + 1)
        --print(field_name.."="..field_value)
        if game[field_name] ~= nil then --field exists TODO check for save fields
          game[field_name] = tonumber(field_value)
        end
      end
    end
  end
end

function game.play_sfx()
end

return game
