local tfs = {"cmd", "alt", "ctrl"}
local ffs = {"cmd", "alt", "ctrl", "shift"}

function quadrant_frame(pframe, dx, dy)
   local w_2 = math.ceil(pframe.w / 2)
   local h_2 = math.ceil(pframe.h / 2)
   return {x = pframe.x + (dx * w_2),
	   y = pframe.y + (dy * h_2),
	   w = w_2,
	   h = h_2}
end

function fraction_frame(pframe, orient, frac, offs)
   local f = {x = 0, y = 0, w = 0, h = 0}
   if 'vertical' == orient then
      f.w = math.ceil(pframe.w * frac)
      f.h = pframe.h
      f.x = pframe.x + (offs * f.w)
      f.y = pframe.y
   elseif 'horizontal' == orient then
      f.w = pframe.w
      f.h = math.ceil(pframe.h * frac)
      f.x = pframe.x
      f.y = pframe.y + (offs * f.h)
   end
   return f
end

function print_table(f)
   for key, val in pairs(f) do  -- Table iteration.
      print(key, val)
   end
end

function frames_equalp(f1, f2)
   return f1.x == f2.x and f1.y == f2.y and f1.w == f2.w and f1.h == f2.h
end

function cycle_frames(frames)
   local win = hs.window.focusedWindow()
   local f = win:frame()

   for i = 1, (#frames - 1) do
      if (frames_equalp(f, frames[i])) then
	 win:setFrame(frames[i + 1])
	 return
      end
   end
   win:setFrame(frames[1])
end

function cycle_quadrants()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()
   max.x = 0
   max.w = 1920
   local frames = {quadrant_frame(max, 0, 0),
		   quadrant_frame(max, 1, 0),
		   quadrant_frame(max, 0, 1),
		   quadrant_frame(max, 1, 1)}
   cycle_frames(frames)
end
hs.hotkey.bind(tfs, "4", cycle_quadrants)

function cycle_halves()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()
   max.x = 0
   max.w = 1920
   local frames = {fraction_frame(max, 'vertical', 0.5, 0),
		   fraction_frame(max, 'vertical', 0.5, 1),
		   fraction_frame(max, 'horizontal', 0.5, 0),
		   fraction_frame(max, 'horizontal', 0.5, 1)}
   cycle_frames(frames)
end
hs.hotkey.bind(tfs, "2", cycle_halves)

function cycle_thirds()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()
   max.x = 0
   max.w = 1920
   local frames = {fraction_frame(max, 'vertical', 0.33, 0),
		   fraction_frame(max, 'vertical', 0.33, 1),
		   fraction_frame(max, 'vertical', 0.33, 2),
		   fraction_frame(max, 'horizontal', 0.33, 0),
		   fraction_frame(max, 'horizontal', 0.33, 1),
		   fraction_frame(max, 'horizontal', 0.33, 2)}
   cycle_frames(frames)
end
hs.hotkey.bind(tfs, "3", cycle_thirds)

function frontcenter()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()

   f.w = math.ceil(max.w * 0.75)
   f.h = math.ceil(max.h * 0.75)
   f.x = max.x + math.ceil((max.w - f.w) / 2)
   f.y = max.y + math.ceil((max.h - f.h) / 2)
   win:setFrame(f)
end
hs.hotkey.bind(tfs, "f", frontcenter)

function maximize()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()
   max.x = 0
   max.w = 1920
   win:setFrame(max)
end
hs.hotkey.bind(tfs, "1", maximize)

local caffeine = hs.menubar.new()
function setCaffeineDisplay(state, quietp)
   if state then
      caffeine:setIcon("caffeine-on.pdf")
      if not quietp then
	 hs.alert.show("Caffeine has been activated")
      end
   else
      caffeine:setIcon("caffeine-off.pdf")
      if not quietp then
	 hs.alert.show("Caffeine has been deactivated")
      end
   end
end

function caffeineClicked()
   setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
   caffeine:setClickCallback(caffeineClicked)
   setCaffeineDisplay(hs.caffeinate.get("displayIdle"), true)
end

hs.hotkey.bind(tfs, "z", caffeineClicked)

function reload_config()
   if caffeine then
      caffeine:delete()
   end
   hs.reload()
end

hs.hotkey.bind(tfs, "r", reload_config)

-- end of config
--
hs.alert.show("hammerspoon at your service")

