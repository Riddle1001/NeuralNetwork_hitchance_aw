local json_lib_installed = false

file.Enumerate(function(filename)
	if filename == "libraries/json.lua" then
		json_lib_installed = true
	end
end)

if not json_lib_installed then
	local body = http.Get("https://raw.githubusercontent.com/Aimware0/aimware_scripts/main/libraries/json.lua")
	file.Write("libraries/json.lua", body)
end

RunScript("libraries/json.lua")


function map(n, start1, stop1, start2, stop2)
  return ((n-start1)/(stop1-start1))*(stop2-start2)+start2
end

function unmap(n, start1, stop1, start2, stop2)
	return map(n, start2, stop2, start1, stop1)
end


local nn_accuracy_tab = gui.Tab(gui.Reference("Settings"), "Chicken.nn.tab", "Accuracy")

local enable_nn = gui.Checkbox(nn_accuracy_tab, "Chicken.nn.enable.NN", "Enable Neural network", false)
local accuracy_slider = gui.Slider(nn_accuracy_tab, "Chicken.nn.accuracy", "Accuracy", 100, 0, 100, 1)
local hitchance_slider = gui.Slider(nn_accuracy_tab, "", "Hitchance", 0, 0, 100)
local dt_hitchance_slider = gui.Slider(nn_accuracy_tab, "", "DT Hitchance", 0, 0, 100)


local highest_dist = 5160.2
local highest_fired = 21

local Target = nil


local oaccuracy_slider = 0
callbacks.Register("Draw", function()
	if not enable_nn:GetValue() then return end

	if oaccuracy_slider ~= accuracy_slider:GetValue() then
		http.Get("http://127.0.0.1:3000/set?fired=" .. map(3, 0, highest_fired, 0, 1) .. "&accuracy=" ..map(accuracy_slider:GetValue(), 1, 100, 0, 1), function() end)
		oaccuracy_slider = accuracy_slider:GetValue()
	end
	
	
	
	hitchance_slider:SetValue(gui.GetValue("rbot.accuracy.weapon.asniper.hitchance"))
	dt_hitchance_slider:SetValue(gui.GetValue("rbot.accuracy.weapon.asniper.doublefirehc"))
end)


local function SetValues(target, range)
	if not enable_nn:GetValue() then return end
	
	local e = pcall(function()
		http.Get("http://127.0.0.1:3000/accuracy?dist=" .. map(vector.Distance({target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z}, {entities.GetLocalPlayer():GetAbsOrigin().x, entities.GetLocalPlayer():GetAbsOrigin().y, entities.GetLocalPlayer():GetAbsOrigin().z}), 0, highest_dist, 0, 1), function(content)
			local j = json.decode(content)
			local _newhc = unmap(j.hitchance, 0, 100, 0, 1)
			local _newdthc = unmap(j.dt_hitchance, 0, 100, 0, 1)
			gui.SetValue("rbot.accuracy.weapon.asniper.hitchance", _newhc)
			gui.SetValue("rbot.accuracy.weapon.asniper.doublefirehc", _newdthc)
		end)
	end)
end




callbacks.Register("AimbotTarget", function(target)
	if not enable_nn:GetValue() then return end
	
	if target.GetIndex and target:GetIndex() then
		Target = target
		SetValues(Target)
	else
		Target = nil
	end
end)


function closest_to_crosshair()
	local lowest = math.huge			
	local x, y = draw.GetScreenSize()
	local mid_x = x / 2
	local mid_y = y / 2
	
	local closest = nil
	
	for k, v in pairs(entities.FindByClass("CCSPlayer")) do
		if v:GetIndex() ~= entities.GetLocalPlayer():GetIndex() and v:GetTeamNumber() ~= entities.GetLocalPlayer():GetTeamNumber() and v:IsAlive() then
			local p_x, p_y = client.WorldToScreen(v:GetAbsOrigin())
			if  p_x and p_y then
				local dist = math.pow(mid_x - p_x, 2) + math.pow(mid_y - p_y, 2)
				if dist < lowest then
					closest = v
					lowest = dist
				end
			end
		end
	end
	return closest
end



callbacks.Register("Draw", function()
	if not enable_nn:GetValue() then return end
	
	local fd_key = gui.GetValue("rbot.antiaim.extra.fakecrouchkey")
	
	if fd_key ~= 0 and input.IsButtonDown(fd_key) then
		gui.SetValue("rbot.accuracy.weapon.asniper.hitchance", 50)
		return
	end
	
	local closest_enemy = closest_to_crosshair()
	if Target then
		SetValues(Target)
	else
		SetValues(closest_enemy)
	end
end)
