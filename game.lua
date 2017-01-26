local game = {}
game.highscore = 0
game.score = 0
game.lives = 3
game.sfx_volume = 100
game.music_volume = 100

local save_fields = {"highscore", "sfx_volume", "music_volume"}

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

return game
