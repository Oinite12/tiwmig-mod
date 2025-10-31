-- Loading features
SMODS.current_mod.optional_features = {
    retrigger_joker = true
}

G_TWMG = G_TWMG or {}
G_TWMG.mod_path = tostring(SMODS.current_mod.path)
F_TWMG = F_TWMG or {}

-- == VARIABLES
G_TWMG.max_card_layers = 3
G_TWMG.infinite_joker_iterator = {
    index = 0,
    group_size = 10
}

-- A shorthand of adding an event to G.E_MANAGER that only defines the properties trigger, delay, and func.\
-- Event function will always return true, so "return true" is not required.\
-- Consequently, do not use this function if the event function needs to return a non-true value\
-- or if other parameters such as blocking require specification.
---@param trigger string | nil
---@param delay number | nil
---@param func function
---@return nil
F_TWMG.add_simple_event = function(trigger, delay, func)
	-- This is here in Oblivion.lua so it's loaded before everything, which uses this function
	G.E_MANAGER:add_event(Event {
		trigger = trigger,
		delay = delay,
		func = function() func(); return true end
	})
end

-- Loads all Lua files in a directory.
---@param folder_name string
---@param condition_function? fun(file_name: string): boolean
---@return nil
function F_TWMG.load_directory(folder_name, condition_function)
	local mod_path = G_TWMG.mod_path
	local files = NFS.getDirectoryItems(mod_path .. folder_name)

	for _,file_name in ipairs(files) do
		local condition_is_met = true
		if condition_function then condition_is_met = condition_function(file_name) end

		if file_name:match(".lua$") and condition_is_met then
			print("[TIWMIG] Loading file " .. file_name)
			local file_format = ("%s/%s")
			local file_func, err = SMODS.load_file(file_format:format(folder_name, file_name))
			if err then error(err) end
			if file_func then file_func() end
		end
	end
end

F_TWMG.load_directory("func")
F_TWMG.load_directory("load_assets")
F_TWMG.load_directory("items")