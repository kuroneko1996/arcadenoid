local levels = {}
levels.current = 0
levels.sequence = require "levels/sequence"

function levels.require_current_level()
  local filename = "levels/"..levels.sequence[levels.current]
  local level = require(filename)
  return level
end

return levels
