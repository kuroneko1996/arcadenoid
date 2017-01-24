local walls = {}
walls.wall_thickness = 10
walls.walls = {}

function walls.new_wall(x, y, width, height)
  return ({x=x, y=y, width=width, height=height})
end

function walls.construct_walls()
  walls.walls["left"] = walls.new_wall(0,0,walls.wall_thickness, love.graphics.getHeight())
  walls.walls["right"] = walls.new_wall(love.graphics.getWidth() - walls.wall_thickness, 0, 
    walls.wall_thickness, love.graphics.getHeight())
  walls.walls["top"] = walls.new_wall(0,0,love.graphics.getWidth(), walls.wall_thickness)
  walls.walls["bottom"] = walls.new_wall(0,love.graphics.getHeight()-walls.wall_thickness, 
    love.graphics.getWidth(),walls.wall_thickness)
end

function walls.draw()
  for _, wall in pairs(walls.walls) do
    love.graphics.setColor(117, 113, 97)
    love.graphics.rectangle('fill', wall.x, wall.y, wall.width, wall.height)
  end
end

function walls.update(dt)
end

return walls
