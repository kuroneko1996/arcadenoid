local uistate = {
  mousex = 0,
  mousey = 0,
  mousedown = 0,

  hotitem = 0,
  activeitem = 0,
}

local colors = require "nanogui/palettes/db16"

local nanogui = {}
local draw_elements = {}

function nanogui.init()
  draw_elements = {}
  love.mouse.setVisible(true)
end

function nanogui.draw()
  for k, v in pairs(draw_elements) do
    v()
  end 
end

function nanogui.pre()
  uistate.mousex = love.mouse.getX()
  uistate.mousey = love.mouse.getY()

  if love.mouse.isDown(1) then
    uistate.mousedown = 1
  elseif not(love.mouse.isDown(1)) then
    uistate.mousedown = 0
  end

  uistate.hotitem = 0

  draw_elements = {}
end

function nanogui.after()
  if uistate.mousedown == 0 then
    uistate.activeitem = 0
  elseif uistate.activeitem == 0 then
    uistate.activeitem = -1
  end
end

function nanogui.regionhit(x, y, w, h)
  return(not(uistate.mousex < x or uistate.mousey < y or uistate.mousex >= x + w or uistate.mousey >= y + h))
end

function nanogui.label(id, text, x, y, color)
  w = w or 64
  h = h or 16
  color = color or colors[16]
  if draw_elements[id] == nil then
    draw_elements[id] = function()
      love.graphics.setColor(color)
      love.graphics.print(text, x, y)
    end
  end
end

function nanogui.button(id, text, x, y, w, h)
  w = w or 64
  h = h or 48
  if nanogui.regionhit(x, y, w, h) then
    uistate.hotitem = id
    if (uistate.activeitem == 0 and uistate.mousedown == 1) then
      --print("clicked")
      uistate.activeitem = id
    end
  end

  if draw_elements[id] == nil then
    local draw = function()
      local xpos = x
      local ypos = y
      --shadow
      love.graphics.setColor(colors[1])
      love.graphics.rectangle("fill", x + 4, y + 4, w + 4, h + 4)

      if uistate.hotitem == id then
        if uistate.activeitem == id then
          --clicked
          love.graphics.setColor(colors[14])
          xpos = x + 4
          ypos = y + 4
          love.graphics.rectangle("fill", xpos, ypos, w, h)
        else
          love.graphics.setColor(colors[9])
          love.graphics.rectangle("fill", xpos, ypos, w, h)
        end
      else
        love.graphics.setColor(colors[3])
        love.graphics.rectangle("fill", xpos, ypos, w, h)
      end

      love.graphics.setColor(colors[16])
      love.graphics.printf(text, xpos, ypos + h / 2 - 8, w, "center")
    end

    draw_elements[id] = draw
  end

  if uistate.mousedown == 0 and uistate.hotitem and uistate.activeitem == id then
    return true
  end
  return false
end

function nanogui.slider(id, value, min, max, x, y, w, h, handler_size)
  w = w or 256
  h = h or 32
  local handler_size = handler_size or 16
  local xpos = ((w-handler_size) * value) / max
  if nanogui.regionhit(x, y, w + handler_size, h) then
    uistate.hotitem = id
    if uistate.activeitem == 0 and uistate.mousedown == 1 then
      uistate.activeitem = id
    end
  end

  if draw_elements[id] == nil then
    local draw = function()
      love.graphics.setColor(colors[11])
      love.graphics.rectangle("fill", x, y, w + handler_size, h)

      if uistate.activeitem == id or uistate.hotitem == id then
        love.graphics.setColor(colors[9])
        love.graphics.rectangle("fill", x + 8 + xpos, y + 8, handler_size, handler_size)
      else
        love.graphics.setColor(colors[3])
        love.graphics.rectangle("fill", x + 8 + xpos, y + 8, handler_size, handler_size)
      end
    end
    draw_elements[id] = draw
  end

  if uistate.activeitem == id then
    local mouseposx = uistate.mousex - (x + 8)
    if mouseposx < 0 then
      mouseposx = 0
    elseif mouseposx > w then
      mouseposx = w
    end
    local new_value = (mouseposx * max) / w
    --print(new_value)
    if new_value ~= value then
      return 1, new_value
    end
  end

  return 0, value 
end

return nanogui
