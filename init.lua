local tfs = {"cmd", "alt", "ctrl"}
local ffs = {"cmd", "alt", "ctrl", "shift"}

local frame_cache = {}

function set_frame(w, f)
   frame_cache[w:id()] = w:frame()
   w:setFrame(f)
end

function unset_frame()
   local w = hs.window.focusedWindow()
   local f = frame_cache[w:id()]
   if f then
      set_frame(w, f)
   end
end
hs.hotkey.bind(tfs, "z", unset_frame)

function screen_frame(win)
   local screen = win:screen()
   local max = screen:frame()
   local dx = max.x
   if dx > 0 and dx < 10 then
      max.x = 0
      max.w = max.w + dx
   end
   return max
end

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
   return f1.x == f2.x
      and f1.y == f2.y
      and math.abs(f1.w - f2.w) <= 100
      and math.abs(f1.h - f2.h) <= 100
end

function frame_origins_equalp(f1, f2)
   return f1.x == f2.x and f1.y == f2.y
end

function cycle_frames(frames)
   local win = hs.window.focusedWindow()
   local f = win:frame()

   for i = 1, (#frames - 1) do
      if (frames_equalp(f, frames[i])) then
	 set_frame(win, frames[i + 1])
	 return
      end
   end
   set_frame(win, frames[1])
end

function cycle_quadrants()
   local win = hs.window.focusedWindow()
   local max = screen_frame(win)
   local frames = {quadrant_frame(max, 0, 0),
		   quadrant_frame(max, 1, 0),
		   quadrant_frame(max, 0, 1),
		   quadrant_frame(max, 1, 1)}
   cycle_frames(frames)
end
hs.hotkey.bind(tfs, "4", cycle_quadrants)

function cycle_halves()
   local win = hs.window.focusedWindow()
   local max = screen_frame(win)
   local frames = {fraction_frame(max, 'vertical', 0.5, 0),
		   fraction_frame(max, 'vertical', 0.5, 1),
		   fraction_frame(max, 'horizontal', 0.5, 0),
		   fraction_frame(max, 'horizontal', 0.5, 1)}
   cycle_frames(frames)
end
hs.hotkey.bind(tfs, "2", cycle_halves)

function cycle_thirds()
   local win = hs.window.focusedWindow()
   local max = screen_frame(win)
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
   local max = screen_frame(win)

   f.w = math.ceil(max.w * 0.75)
   f.h = math.ceil(max.h * 0.75)
   f.x = max.x + math.ceil((max.w - f.w) / 2)
   f.y = max.y + math.ceil((max.h - f.h) / 2)
   set_frame(win, f)
end
hs.hotkey.bind(tfs, "f", frontcenter)

function center()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local max = screen_frame(win)

   f.x = max.x + math.ceil((max.w - f.w) / 2)
   f.y = max.y + math.ceil((max.h - f.h) / 2)
   set_frame(win, f)
end
hs.hotkey.bind(tfs, "c", center)

function maximize()
   local win = hs.window.focusedWindow()
   local max = screen_frame(win)
   set_frame(win, max)
end
hs.hotkey.bind(tfs, "1", maximize)

function grow(a, b)
   return a + b
end

function shrink(a, b)
   return a - b
end

function grid_change(orient, change_fn)
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local max = screen_frame(win)

   if ('horizontal' == orient or 'both' == orient) then
      f.w = change_fn(f.w, math.ceil(max.w / 32))
   end
   if ('vertical' == orient or 'both' == orient) then
      f.h = change_fn(f.h, math.ceil(max.h / 32))
   end
   set_frame(win, f)
end

function grid_grow(orient)
   grid_change(orient, grow)
end

function grid_shrink(orient)
   grid_change(orient, shrink)
end

function grid_grow_x()
   grid_grow('horizontal')
end
function grid_shrink_x()
   grid_shrink('horizontal')
end
function grid_grow_y()
   grid_grow('vertical')
end
function grid_shrink_y()
   grid_shrink('vertical')
end

hs.hotkey.bind(tfs, "right", grid_grow_x)
hs.hotkey.bind(tfs, "left", grid_shrink_x)
hs.hotkey.bind(tfs, "down", grid_grow_y)
hs.hotkey.bind(tfs, "up", grid_shrink_y)

function align_right()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local max = screen_frame(win)

   f.x = max.x + (max.w - f.w)
   set_frame(win, f)
end
hs.hotkey.bind(tfs, "r", align_right)

function align_left()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local max = screen_frame(win)

   f.x = max.x
   set_frame(win, f)
end
hs.hotkey.bind(tfs, "l", align_left)

function align_bottom()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local max = screen_frame(win)

   f.y = max.y + (max.h - f.h)
   set_frame(win, f)
end
hs.hotkey.bind(tfs, "b", align_bottom)

function align_top()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local max = screen_frame(win)

   f.y = max.y
   set_frame(win, f)
end
hs.hotkey.bind(tfs, "t", align_top)

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

hs.hotkey.bind(tfs, "\\", caffeineClicked)

function reload_config()
   if caffeine then
      caffeine:delete()
   end
   hs.reload()
end

hs.hotkey.bind(ffs, "r", reload_config)

-- end of config
--
hs.alert.show("hammerspoon at your service")

