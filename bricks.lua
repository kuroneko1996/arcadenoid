local bricks = {}
bricks.image = love.graphics.newImage("assets/bricks.png")
bricks.top_left_x = 220
bricks.top_left_y = 150
bricks.horizontal_distance = 0
bricks.vertical_distance = 0
bricks.no_more_bricks = false
bricks.tile_width = 32
bricks.tile_height = 16
bricks.default_width = bricks.tile_width
bricks.default_heigth = bricks.tile_height
bricks.tileset_width = 256
bricks.tileset_height = 16
bricks.bricks = {}

function bricks.construct_level(level_table)
  bricks.no_more_bricks = false

  for row_index, row in pairs(level_table) do
    for col_index, brick_type in pairs(row) do
      if brick_type ~= 0 then
        local newx = bricks.top_left_x + (col_index-1)*(bricks.default_width+bricks.horizontal_distance)
        local newy = bricks.top_left_y + (row_index-1)*(bricks.default_heigth+bricks.vertical_distance)
        local new_brick = bricks.new_brick(newx, newy, brick_type)
        table.insert(bricks.bricks, new_brick)
      end
    end
  end
end

function bricks.clear_level_bricks()
  for i in pairs(bricks.bricks) do
    bricks.bricks[i] = nil
  end
end

function bricks.brick_type_to_quad(brick_type)
  local x = (brick_type-1) * bricks.tile_width
  local y = 0
  return love.graphics.newQuad(x, y, bricks.tile_width, bricks.tile_height, bricks.tileset_width, bricks.tile_height)
end

function bricks.new_brick(x, y, brick_type, width, height)
  local hp = 1
  if brick_type == 7 then
    hp = 2 -- TODO change by level
  end
  return ({
            x = x,
            y = y,
            brick_type = brick_type,
            hp = hp,
            quad = bricks.brick_type_to_quad(brick_type),
            width = width or bricks.default_width,
            height = height or bricks.default_heigth })
end

function bricks.hit_by_ball(i, brick, shift_ball_x, shift_ball_y)
  if brick.brick_type ~= 8 then
    brick.hp = brick.hp - 1
    if brick.hp <= 0 then
      table.remove(bricks.bricks, i)
    end
  end
end

function bricks.draw_brick(brick)
  love.graphics.setColor(255,255,255)
  love.graphics.draw(bricks.image, brick.quad, brick.x, brick.y)
  --love.graphics.setColor(109, 170, 44)
  --love.graphics.rectangle('fill', brick.x, brick.y, brick.width, brick.height)
end

function bricks.update_brick(brick)
end

function bricks.draw()
  for _, brick in pairs(bricks.bricks) do
    bricks.draw_brick(brick)
  end
end

function bricks.update(dt)
  local bricks_left = 0
  for _, brick in pairs(bricks.bricks) do
    bricks.update_brick(brick)
    if brick.brick_type ~= 8 then
      bricks_left = bricks_left + 1
    end
  end
  if bricks_left == 0 then
    bricks.no_more_bricks = true
  end
end

return bricks
