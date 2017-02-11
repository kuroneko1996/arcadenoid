local uistate = {
  mousex = 0,
  mousey = 0,
  mousedown = 0,
  jdelay = 0,

  hotitem = 0,
  activeitem = 0,

  --keyboard stuff
  kbditem = 0,
  keyentered = 0,
  keyshift = false,
  lastwidget = 0,
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

  --love.graphics.print("kbditem="..uistate.kbditem..", lastwidget="..uistate.lastwidget..", keyentered="..uistate.keyentered..
  --  ", keyshift="..tostring(uistate.keyshift))
end

function nanogui.pre(joystick)
  uistate.mousex = love.mouse.getX()
  uistate.mousey = love.mouse.getY()

  if love.mouse.isDown(1) then
    uistate.mousedown = 1
  elseif not(love.mouse.isDown(1)) then
    uistate.mousedown = 0
  end
  
  local time = love.timer.getTime() * 1000
  if joystick ~= nil and uistate.jdelay < time then
    local jx = joystick:getGamepadAxis("leftx")
    local jy = joystick:getGamepadAxis("lefty")
    local threshold = 0.2
    
    if jx > threshold then
      uistate.keyentered = "right"
    elseif jx < -threshold then
      uistate.keyentered = "left"
    elseif jy > threshold then
      uistate.keyentered = "down"
    elseif jy < -threshold then
      uistate.keyentered = "up"
    end
    
    if math.abs(jx) > threshold or math.abs(jy) > threshold then
      uistate.jdelay = time + 250
    end
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

function nanogui.change_page()
  uistate.kbditem = 0
  uistate.lastwidget = 0
  uistate.keyentered = 0
  uistate.keyshift = false
end

function nanogui.keypressed(key, isrepeat)
  uistate.keyentered = key
  uistate.keyshift = love.keyboard.isDown("lshift", "rshift")
end

function nanogui.gamepadpressed(joystick, button)
    if button == "dpleft" then
      uistate.keyentered = "left" 
    elseif button == "dpright" then
      uistate.keyentered = "right"
    elseif button == "dpdown" then
      uistate.keyentered = "down"
    elseif button == "dpup" then
      uistate.keyentered = "up"
    end
    if button == "a" then
      uistate.keyentered = "return"
    end
    if button == "b" then
      --uistate.keyentered = "escape"
    end
end

function nanogui.regionhit(x, y, w, h)
  return(not(uistate.mousex < x or uistate.mousey < y or uistate.mousex >= x + w or uistate.mousey >= y + h))
end

function nanogui.focus_change()
  if uistate.keyentered == "tab" or uistate.keyentered == "down" then --lose focus
    uistate.kbditem = 0
    uistate.keyentered = 0
    if uistate.keyshift then --move back
      uistate.kbditem = uistate.lastwidget
    end
    return true
  elseif uistate.keyentered == "up" then -- move back
    uistate.keyentered = 0
    uistate.kbditem = uistate.lastwidget
    return true
  end

  return false
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

  --keyboard focus
  if uistate.kbditem == 0 then --get focus
    uistate.kbditem = id
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

      --text
      love.graphics.setColor(colors[16])
      love.graphics.printf(text, xpos, ypos + h / 2 - 8, w, "center")

      if uistate.kbditem == id then --show keyboard focus
        love.graphics.setColor(colors[7])
        love.graphics.rectangle("line", xpos-4, ypos-4, w + 8, h + 8)
      end
    end
    draw_elements[id] = draw
  end

  --focus keys
  if uistate.kbditem == id then
    if not(nanogui.focus_change()) then
      if uistate.keyentered == "return" then
        uistate.keyentered = 0
        return true
      end
    end
  end
  uistate.lastwidget = id

  --return
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
  local step = max / 10

  if nanogui.regionhit(x, y, w + handler_size, h) then
    uistate.hotitem = id
    if uistate.activeitem == 0 and uistate.mousedown == 1 then
      uistate.activeitem = id
    end
  end

  --keyboard focus
  if uistate.kbditem == 0 then --get focus
    uistate.kbditem = id
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

      if uistate.kbditem == id then --show keyboard focus
        love.graphics.setColor(colors[7])
        love.graphics.rectangle("line", x-4, y-4, w + handler_size + 8, h + 8)
      end
    end
    draw_elements[id] = draw
  end

  local new_value = value
  -- mouse
  if uistate.activeitem == id then
    local mouseposx = uistate.mousex - (x + 8)
    if mouseposx < 0 then
      mouseposx = 0
    elseif mouseposx > w then
      mouseposx = w
    end
    new_value = (mouseposx * max) / w
  end

  -- keyboard
  if uistate.kbditem == id then
    if not(nanogui.focus_change()) then
      if uistate.keyentered == "left" then
        if value > 0 then
          new_value = value - step
        end
        uistate.keyentered = 0
      elseif uistate.keyentered == "right" then
        if value < max then
          new_value = value + step
        end
        uistate.keyentered = 0
      end
    end
  end

  uistate.lastwidget = id

  --print(new_value)
  if new_value > max then
    new_value = max
  elseif new_value < min then
    new_value = min
  end

  if new_value ~= value then
    return 1, new_value
  else
    return 0, value
  end
end

return nanogui
