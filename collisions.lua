local collisions = {}





--Collisions
function collisions.rectangle_overlap(a, b)
  local overlap = false
  local shift_b_x, shift_b_y = 0, 0
  if not (a.x + a.width < b.x or b.x + b.width < a.x or 
          a.y + a.height < b.y or b.y + b.height < a.y) then
    overlap = true
    if (a.x + a.width / 2) < (b.x + b.width / 2) then
      shift_b_x = (a.x + a.width) - b.x
    else
      shift_b_x = a.x - (b.x + b.width)
    end
    if (a.y + a.height / 2) < (b.y + b.height / 2) then
      shift_b_y = (a.y + a.height) - b.y
    else
      shift_b_y = a.y - (b.y+b.height)
    end
  end
  return overlap, shift_b_x, shift_b_y
end

function collisions.ball_platform_collision(ball, platform)
  local a = {x=platform.x, y=platform.y, width=platform.width,height=platform.height}
  local b = {x=ball.x-ball.radius, y=ball.y-ball.radius, width=2*ball.radius,height=2*ball.radius}
  local overlap, shift_x, shift_y = collisions.rectangle_overlap(a, b)

  if overlap then
    --print("ball-platform")
    ball.rebound(shift_x, shift_y)
  end
end

function collisions.ball_bricks_collision(ball, bricks)
  local b = {x=ball.x-ball.radius, y=ball.y-ball.radius,width=2*ball.radius,height=2*ball.radius}
  for i, brick in pairs(bricks.bricks) do
    local a = {x=brick.x, y=brick.y,width=brick.width,height=brick.height}
    local overlap, shift_x, shift_y = collisions.rectangle_overlap(a, b)
    if overlap then
      --print("ball-brick")
      ball.rebound(shift_x, shift_y)
      bricks.hit_by_ball(i, brick, shift_x, shift_y)
    end
  end
end

function collisions.ball_walls_collision(ball, walls)
  local b = {x=ball.x-ball.radius, y=ball.y-ball.radius,width=2*ball.radius,height=2*ball.radius}
  for i, wall in pairs(walls.walls) do
    local a = {x=wall.x, y=wall.y,width=wall.width,height=wall.height}
    local overlap, shift_x, shift_y = collisions.rectangle_overlap(a, b)
    if overlap then
      --print("ball-wall")
      ball.rebound(shift_x, shift_y)
    end
  end
end

function collisions.platform_walls_collision(platform, walls)
  local b = {x=platform.x, y=platform.y,width=platform.width,height=platform.height}
  for i, wall in pairs(walls.walls) do
    local a = {x=wall.x, y=wall.y,width=wall.width,height=wall.height}
    local overlap, shift_x, shift_y = collisions.rectangle_overlap(a, b)
    if overlap then
      --print("platform-wall")
      platform.rebound(shift_x, shift_y)
      break
    end
  end
end

function collisions.resolve(platform, ball, bricks, walls)
  collisions.ball_platform_collision(ball, platform)
  collisions.ball_walls_collision(ball, walls)
  collisions.ball_bricks_collision(ball, bricks)
  collisions.platform_walls_collision(platform, walls)
end

return collisions
