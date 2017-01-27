local Animation = {}
local Animation_mt = { __index = Animation }

function Animation.new(image, frames, duration)
  local new_animation = {
    image=image,
    frames=frames,
    max_frame=#frames,
    duration=duration or 0.1,
    position=0,
    elapsed=0,
  }
  
  return setmetatable(new_animation, Animation_mt)
end

function Animation:update(dt)
  self.elapsed = self.elapsed + dt
  if self.elapsed >= self.duration then
    self.elapsed = self.elapsed - self.duration
    if self.position == self.max_frame then
      self.position = 1
    else
      self.position = self.position + 1
    end
  end
end

function Animation:draw(x, y)
  if self.frames[self.position] ~= nil then
    love.graphics.setColor(255,255,255)
    love.graphics.draw(self.image, self.frames[self.position], x, y)
  end
end

return Animation
