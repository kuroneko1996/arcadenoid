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

  game.load_spritesheet("bonus_laser", 32, 32)
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
  for k, anim in pairs(game.animations) do
    anim.elapsed = anim.elapsed + dt
    if anim.elapsed >= 0.1 then
      anim.elapsed = anim.elapsed - 0.1
      if anim.frame == anim.max_frame then
        anim.frame = 1
      else
        anim.frame = anim.frame + 1
      end
    end
  end
end

function game.draw_animation(idx, x, y)
  if game.animations[idx] == nil then
    game.add_animation(idx, idx)
  end
  local animation = game.animations[idx]
  local spritesheet = animation.spritesheet
  if spritesheet.frames[animation.frame] ~= nil then
    love.graphics.draw(spritesheet.image, spritesheet.frames[animation.frame], x, y)
  end
end

function game.add_animation(idx, sprite_name)
  local animation = {
    sprite_name=sprite_name,
    frame=0,
    max_frame=game.spritesheets[sprite_name].frames_number,
    elapsed=0,
    spritesheet=game.spritesheets[sprite_name],
  }
  game.animations[idx] = animation
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
