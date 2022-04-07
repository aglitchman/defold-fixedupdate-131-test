local M = {}

--- Clamps x between 0 and 1 and returns value.
local function clamp01(x)
	if x < 0 then
		return 0
	elseif x > 1 then
		return 1
	else
		return x
	end
end

function M.init(t)
	assert(type(t.object_id) ~= "nil")

	t.time = 0
	t.fixed_time = 0
	t.fixed_dt = t.fixed_dt or 1 / math.max(1, tonumber(sys.get_config("engine.fixed_update_frequency", 60)))
	t.continuous_mode = t.continuous_mode or true

	return t
end

function M.start_frame(t, fixed_dt)
	t.fixed_time = t.fixed_time + fixed_dt
	t.fixed_dt = fixed_dt

	if t.continuous_mode and t.position and t.rotation then
		t.start_position = t.position
		t.start_rotation = t.rotation
	else
		if not t.dirty then
			t.start_position = go.get_position(t.object_id)
			t.start_rotation = go.get_rotation(t.object_id)
		end
	end

	t.dirty = true
end

function M.interpolate(t, dt)
	t.time = t.time + dt
	t.dt = dt

	if t.dirty then
		t.last_position = go.get_position(t.object_id)
		t.last_rotation = go.get_rotation(t.object_id)
		t.dirty = false
	end

	local interpolation_factor = clamp01((t.time - t.fixed_time) / t.fixed_dt)

	if not t.start_position then
		-- Happens if interpolate() is called before start_frame()
		return
	end

	t.position = vmath.lerp(interpolation_factor, t.start_position, t.last_position)
	t.rotation = vmath.slerp(interpolation_factor, t.start_rotation, t.last_rotation)
end

return M