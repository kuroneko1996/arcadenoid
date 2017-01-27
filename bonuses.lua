local bonus_types = {}
local bonuses = {}
bonuses.bonuses = {}

bonus_types.laser = {
  sprite="bonus_laser",
  width=28,
  heigth=12,
  on_platform_hit = function(platform)
    print("hit")
  end,
}

function bonuses.create(bonus_type,  x, y)
  local new_bonus = {}
  new_bonus.sprite = bonus_types[bonus_type].sprite
  new_bonus.width = bonus_types[bonus_type].width
  new_bonus.height = bonus_types[bonus_type].heigth
  new_bonus.on_platform_hit = bonus_types[bonus_type].on_platform_hit
  new_bonus.x = x
  new_bonus.y = y
  return new_bonus
end

function bonuses.draw()
  for k, b in pairs(bonuses.bonuses) do
    b.animation:draw(b.x, b.y)
  end
end

function bonuses.update(dt)
  for k, b in pairs(bonuses.bonuses) do
    b.animation:update(dt)
    
    b.y = b.y + 100 * dt
    if b.y > love.graphics.getHeight() then
      bonuses.bonuses[k] = nil
    end
  end
end

return bonuses
