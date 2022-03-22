local gears = require("gears")
M = {}

-- eva progressbar with width, height, gaps between each of the arrow things and size
local progressbar = function(cr, width, height, gaps, size)
    local amount = math.floor(width/(size+gaps))
    for i = 1, amount, 1 do
      gears.shape.transform(gears.shape.powerline) : translate((i-1)*(gaps + size), 0) (cr, size, height)
    end
end


-- creates one of these 斜め rectangles, using cr, height and width
-- x0/y0 is the starting point if there are multiple paths to draw
-- dir is the direction being either 1 -> bar left bottom to top right 
--  or 2 -> bar is from top left to bottom right
--  angle is the angle at which the 斜め線 should cross the x-axis in radiants
local single_eva = function(cr, height, width, angle, x0, y0, dir)
	local buf = math.tan(angle) * width
	-- require("naughty").notify({text = tostring(buf .. "  " .. wid .. " " .. height)})
	cr:new_sub_path()
	-- eva bar left bottom to top right
	if dir == 1 then
		cr:move_to(x0, y0 + buf)
		cr:line_to(x0, y0 + height)
		cr:line_to(x0 + width, y0 + height - buf)
		cr:line_to(x0 + width, y0)
		-- from top left to bottom right
	elseif dir == 2 then
		cr:move_to(x0 + width, y0 + buf)
		cr:line_to(x0 + width, y0 + height)
		cr:line_to(x0, y0 + height - buf)
		cr:line_to(x0, y0)
	end
	cr:close_path()
end


-- function that draws multiple double eva progress bars
-- container_h, container_w are container width and height
-- container_max_w is the maximum container width, useful for progressbars
-- s_height/width are the shapes width and height
-- gaph/w are width or height gaps
-- on is for drawing the progressbar bg (=false) or the progressbar itself (=true)
local eva_double_matrix_progress = function(cr, container_h, container_w, container_max_w, s_height, s_width, gaph, gapw, on)
	-- calculate percentage
	local perc = container_w / (container_max_w)

	-- calculate remainder that is left up to center widget
	local remainder = (container_max_w - 2 * s_width - gapw) / 2

	-- amount of things to draw
	local amount = math.floor(perc * container_h / (s_height + gaph))

	for i = 1, amount, 1 do
		local iheight = (i - 1) * (s_height + gaph)
    -- draw left thing
		single_eva(cr, s_height, s_width, math.pi / 9, remainder, iheight, 1)
    -- draw thing on the right side
		single_eva(cr, s_height, s_width, math.pi / 9, remainder + gapw + s_width, iheight, 2)

    -- fancy color and shape changes depending on whether this block should be connected or not
		if on then
			gears.shape.transform(gears.shape.rectangle):translate(remainder + s_width, iheight + 4)(cr, gapw, 1)
		else
			gears.shape.transform(gears.shape.rectangle):translate(remainder + s_width, iheight + 4)(cr, gapw / 3, 1)
			gears.shape.transform(gears.shape.rectangle):translate(remainder + s_width + gapw * 2 / 3, iheight + 4)(
				cr,
				gapw / 2,
				1
			)
		end
	end
end


M.single_eva = single_eva
M.eva_progessbar = progressbar
M.eva_double_matrix_progress = eva_double_matrix_progress
return M
