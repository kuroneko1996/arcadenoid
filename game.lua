local game = {}
game.score = 0
game.lives = 3

function game.set_score(brick_type)
  if brick_type ~= 8 then
    game.score = game.score + 10
  end
end

return game
