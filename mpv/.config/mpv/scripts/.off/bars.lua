local mp = require 'mp'
local assdraw = require "mp.assdraw"
local msg = require 'mp.msg'
local mpx, mpy = mp.get_mouse_pos()
x1, y1, x2, y2 = nil

drawing = false
second_point = false
done = false

function get_points()
	if done == true then
		x1, y1, x2, y2 = nil
		drawing = true
		done = false
		msg.error("reset points and drawing true")
		return
	end

	if x1 == nil then
		x1, y1 = mp.get_mouse_pos()
		second_point = true
	else
		x2, y2 = mp.get_mouse_pos()
		second_point = false
		done = true
		drawing = false
	end
end


function start_crop()
	mp.add_forced_key_binding("MOUSE_MOVE", "update", update)
	mp.add_forced_key_binding("MOUSE_BTN0", "get-points", get_points)
	drawing = true
	mp.register_idle(draw_crop_zone)
end

function draw_crop_zone()
	local ass = assdraw.ass_new()
	window = {}
	window.w, window.h = mp.get_osd_size()
	draw_crosshair(ass, window)
	mp.set_osd_ass(window.w, window.h, ass.text)
end

function draw_crosshair(ass, window)	
	ass:new_event()
    ass:append("{\\bord0}")
    ass:append("{\\shad0}")
    ass:append("{\\c&H663399&}")
    ass:append("{\\1a&H00&}")
    ass:append("{\\2a&HFF&}")
    ass:append("{\\3a&HFF&}")
    ass:append("{\\4a&HFF&}")
    ass:pos(0, 0)
	ass:draw_start()
    ass:rect_cw(mpx - 0.5, 0, mpx +0.5, window.h)
    ass:rect_cw(0, mpy -0.5, window.w , mpy+0.5 )
    ass:draw_stop()

    make_box(ass)

end

function make_box(ass)
	ass:new_event()
    ass:pos(0, 0)
    ass:append("{\\bord0}")
    ass:append("{\\shad&100&}")
    ass:append("{\\c&H000000&}")
    ass:append("{\\1a&H00&}")
    ass:append("{\\2a&HFF&}")
    ass:append("{\\3a&HFF&}")
    ass:append("{\\4a&HFF&}")
    ass:draw_start()

    if second_point then
    	ass:rect_cw(x1,y1, mpx, mpy)
    end
    if done then
    	ass:rect_cw(x1, y1, x2, y2)
    	write_subs(ass)
    end

    ass:draw_stop()
end

function write_subs(ass)
	ass:new_event()
	ass:pos(x1, y1)
	ass:draw_start()
	ass:draw_stop()
	if not (mp.get_property('sub-text') == nil) then
		local subs = mp.get_property('sub-text'):gsub('\n','')
		ass:append(subs)
	end

	--msg.error(ass.text)
end


function cancel()
	mp.unregister_idle(draw_crop_zone)
	--mp.remove_forced_key_binding("update")
	--mp.remove_forced_key_binding("get-points")
	x1, y1, x2, y2 = nil
	mp.set_osd_ass(1280, 720, '')
	msg.error("cancelled")
end

function update()
	mpx, mpy = mp.get_mouse_pos()
end

mp.add_key_binding("b", "start-drawing", start_crop)
mp.add_key_binding("ESC", "stop", cancel)


-- FEHLT : SUBS ÜBER BARS DRÜBER MACHEN
-- Idee: subs inhalt kopieren und drüber schreiben 