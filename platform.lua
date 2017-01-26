local platform = {
  x=500,
  y=500,
  hspd=500,
  width=96,
  height=16,
}
platform.image = love.graphics.newImage("assets/platform.png")

function platform.draw()
  love.graphics.setColor(255,255,255)
  love.graphics.draw(platform.image, platform.x, platform.y)
  --love.graphics.setColor(89, 125, 206)
  --love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
end

function platform.update(dt, joystick)
  if love.keyboard.isDown("right") then
    platform.x = platform.x + platform.hspd * dt
  end
  if love.keyboard.isDown("left") then
    platform.x = platform.x - platform.hspd * dt
  end

  if joystick ~= nil then
    local xdir = joystick:getGamepadAxis( "leftx" )
    if math.abs(xdir) > 0.2 then -- TODO deadzone
      platform.x = platform.x + xdir * platform.hspd * dt
    end
  end
end

function platform.rebound(shift_x, shift_y)
  local min_shift = math.min(math.abs(shift_x), math.abs(shift_y))

  if math.abs(shift_x) == min_shift then
    shift_y = 0
  else
    shift_x = 0
  end
  platform.x = platform.x + shift_x
  platform.y = platform.y + shift_y
end

return platform
