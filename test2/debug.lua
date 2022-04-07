local M = {}

function M.reset()
	M.dt_sum = 0
	M.fixed_dt_sum = 0
	M.updates = 0
	M.fixed_updates = 0
end

return M