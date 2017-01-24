local ball = {
  x=200,
  y=500,
  hspd=300,
  vspd=300,
  radius=5,
}
ball.image = love.graphics.newImage("assets/ball.png")

function ball.update(dt)
  ball.x = ball.x + ball.hspd * dt
  ball.y = ball.y + ball.vspd * dt
end

function ball.draw()
  love.graphics.setColor(255,255,255)
  love.graphics.draw(ball.image, ball.x, ball.y)

  --local segments_in_circle = 16
  --love.graphics.setColor(208, 70, 72)
  --love.graphics.circle('fill', ball.x, ball.y, ball.radius, segments_in_circle)
end

function ball.rebound(shift_x, shift_y)
  local min_shift = math.min(math.abs(shift_x), math.abs(shift_y))

  if math.abs(shift_x) == min_shift then
    shift_y = 0
  else
    shift_x = 0
  end
  ball.x = ball.x + shift_x
  ball.y = ball.y + shift_y
  if shift_x ~= 0 then
    ball.hspd = -ball.hspd
  end
  if shift_y ~= 0 then
    ball.vspd = -ball.vspd
  end

end

function ball.reposition()
  ball.x = 200
  ball.y = 500
end

return ball
