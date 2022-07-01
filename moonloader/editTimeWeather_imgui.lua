script_name 'editTimeWeather_imgui'
script_author 'imring'
script_version '4.0'

samp							= require 'samp.events'
memory						= require 'memory'
imgui							= require 'imgui'
encoding						= require 'encoding'
inicfg							= require 'inicfg'
encoding.default					= 'CP1251'
u8							= encoding.UTF8
menu_script						= imgui.ImBool(false)
script_enable						= imgui.ImBool(false)
slider_int_time					= imgui.ImInt(-1)
slider_int_weather					= imgui.ImInt(-1)

parameter_weather					= imgui.ImInt(0)
parameter_time					= imgui.ImInt(0)

name_parameter					= imgui.ImBuffer(256)
autoload_enable					= imgui.ImBool(false)

local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4

style.WindowRounding = 1.5

colors[clr.TitleBg] = ImVec4(0.3, 0.3, 0.5, 0.5)
colors[clr.TitleBgActive] = ImVec4(0.3, 0.3, 0.5, 0.75)
colors[clr.TitleBgCollapsed] = ImVec4(0.3, 0.3, 0.5, 1.0)

colors[clr.Button] = ImVec4(0.8, 0.8, 0.8, 0.40)
colors[clr.ButtonHovered] = ImVec4(0.8, 0.8, 0.8, 0.5)
colors[clr.ButtonActive] = ImVec4(0.8, 0.8, 0.8, 0.75)

colors[clr.SliderGrabActive] = ImVec4(0.8, 0.8, 0.8, 0.75)

sampRegisterChatCommand("swst", function() menu_script.v = not menu_script.v end)

function imgui.OnDrawFrame()
	local x, y = getScreenResolution()
	local max_size = imgui.ImVec2(-0.1, 0)
	if menu_script.v then
		imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(450, 235), imgui.Cond.FirstUseEver)
		imgui.Begin(u8('Редактор времени и погоды'), menu_script, imgui.WindowFlags.NoResize)
		if imgui.Checkbox(u8('Активирывать скрипт'), script_enable) then script_enable.v = script_enable.v end
		if script_enable.v then
			local selected
			imgui.SliderInt(u8('Изменить время'), slider_int_time, 0, 24)
			imgui.SliderInt(u8('Изменить погоду'), slider_int_weather, 0, 50)
			imgui.Text(u8('Сохраненый конфиг: '))
			imgui.SameLine(nil, 0)
			for i, k in pairs(file.time) do
				if i ~= 0 then
					if slider_int_time.v == k and slider_int_weather.v == file.weather[i] then
						selected = i
						if imgui.Button(u8(file.name[i])..'№'..i+10) then current_option = i end
					end
				end
			end
			if not selected then imgui.Text(u8('У вас нет сохранения')) end
			imgui.Separator()
			if imgui.Checkbox(u8('Сохранение'), autoload_enable) then
				file.autoload.enable = autoload_enable.v
				inicfg.save(file, 'moonloader/config/editTimeWeather_config.ini')
			end
			if autoload_enable.v and imgui.Button(u8('Задать значение')) then select_autoload = true end
			imgui.Separator()
			if select_autoload then
				imgui.Text(u8('Выберете сохранение'))
				for i, k in pairs(file.name) do
					if i ~= 0 then
						if imgui.Button(u8(k)) then
							file.autoload.id = i
							inicfg.save(file, 'moonlaoder/config/editTimeWeather_config.ini')
							select_autoload = false
						end
						imgui.SameLine()
					end
				end
				if imgui.Button(u8('Создать сохранение')) then select_autoload = false end
			elseif current_option then
				imgui.Text('Name: '..u8(file.name[current_option]))
				if edit_parameters then
					imgui.InputText(u8('Название'), name_parameter)
					imgui.SliderInt(u8('Время'), parameter_time, 0, 24)
					imgui.SliderInt(u8('Погода'), parameter_weather, 0, 50)
					if imgui.Button(u8('Сохранить')) then
						local namedublicate = false
						for i, k in pairs(file.name) do
							if i ~= 0 and k ~= file.name[current_option] then
								if k == u8:decode(name_parameter.v) or not u8:decode(name_parameter.v):find('%S') then namedublicate = true end
							end
						end
						if not namedublicate then
							file.time[current_option] = parameter_time.v
							file.weather[current_option] = parameter_weather.v
							file.name[current_option] = u8:decode(name_parameter.v)
							inicfg.save(file, 'moonloader/config/editTimeWeather_config.ini')
							edit_parameters = false
						end
					end
					imgui.SameLine()
					if imgui.Button(u8('Назад')) then edit_parameters = false end
				else
					imgui.Text(u8('Время: ')..file.time[current_option]..u8(' | Погода: ')..file.weather[current_option])
					if imgui.Button(u8('Редактирывать')) then
						parameter_weather.v = file.weather[current_option]
						parameter_time.v = file.time[current_option]
						name_parameter.v = u8(file.name[current_option])
						edit_parameters = not edit_parameters
					end
					imgui.SameLine()
					if imgui.Button(u8('Удалить сохранение')) then
						file.time[current_option] = nil
						file.weather[current_option] = nil
						file.name[current_option] = nil
						current_option = nil
						inicfg.save(file, 'moonloader/config/editTimeWeather_config.ini')
					end
					imgui.SameLine()
					if imgui.Button(u8('Включить')) then
						slider_int_weather.v = file.weather[current_option]
						slider_int_time.v = file.time[current_option]
					end
					imgui.SameLine()
					if imgui.Button(u8('Закрыть')) then current_option = nil end
				end
			elseif create_option then
				imgui.InputText(u8('Название'), name_parameter)
				imgui.SliderInt(u8('Время'), parameter_time, 0, 24)
				imgui.SliderInt(u8('Погода'), parameter_weather, 0, 50)
				if imgui.Button(u8('Сохранить')) then
					local namedublicate = false
					for i, k in pairs(file.name) do
						if i ~= 0 then
							if k == u8:decode(name_parameter.v) or not u8:decode(name_parameter.v):find('%S') then namedublicate = true end
						end
					end
					if not namedublicate then
						local index, bool = -1, false
						while not bool do
							index = index + 1
							if not file.name[index] then bool = true end
						end
						file.time[index] = parameter_time.v
						file.weather[index] = parameter_weather.v
						file.name[index] = u8:decode(name_parameter.v)
						inicfg.save(file, 'moonloader/config/editTimeWeather_config.ini')
						create_option = false
						name_parameter.v = ''
					end
				end
				imgui.SameLine()
				if imgui.Button(u8('Назад')) then create_option = false end
			else
				imgui.Text(u8('Сохранение: '))
				imgui.SameLine(nil, 1)
				for i, k in pairs(file.name) do
					if i ~= 0 then
						if imgui.Button(u8(k)..'№'..i) then current_option = i end
						imgui.SameLine()
					end
				end
				imgui.NewLine()
				if imgui.Button(u8('Создать новое сохранение')) then
					create_option = true
					name_parameter.v = u8('Время: ')..slider_int_time.v..u8('; Погода: ')..slider_int_weather.v..'.'
					parameter_time.v = slider_int_time.v
					parameter_weather.v = slider_int_weather.v
				end
				imgui.SameLine()
			end
		end
		imgui.End()
	end
end

function main()
	while not isSampAvailable() do wait(0) end
	if not doesFileExist('moonloader/config/editTimeWeather_config.ini') then
		local f = io.open('moonloader/config/editTimeWeather_config.ini', 'a')
		f:write('[name]\n0=0\n[weather]\n0=0\n[time]\n0=0\n[autoload]\nenable=false\nid=0')
		f:flush()
		f:close()
	end
	while sampGetCurrentServerName() == 'SA-MP' do wait(0) end
	file = inicfg.load(nil, 'moonloader/config/editTimeWeather_config.ini')
	while not file do file = inicfg.load(nil, 'moonloader/config/editTimeWeather_config.ini') end
	oldtime = memory.getint8(0xB70153, true)
	oldweather = memory.getint8(0xC81320, true)
	slider_int_time.v = oldtime
	slider_int_weather.v = oldweather
	if file.autoload.enable and file.autoload.id ~= 0 then
		slider_int_time.v = file.time[file.autoload.id]
		slider_int_weather.v = file.weather[file.autoload.id]
		script_enable.v = true
		autoload_enable.v = true
	end
	while true do wait(0)
		if script_enable.v then
			memory.setint8(0xB70153, tonumber(slider_int_time.v), true)
			memory.setint8(0xC81320, tonumber(slider_int_weather.v), true)
		else
			memory.setint8(0xB70153, oldtime, true)
			memory.setint8(0xC81320, oldweather, true)
		end
		if not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
		end
		imgui.Process = menu_script.v
	end
end

function samp.onSetWeather(weather)
	oldweather = weather
end

function samp.onSetPlayerTime(hour, minute)
	oldtime = hour
end

function onScriptTerminate(scr, bool)
	if scr == thisScript() then
		memory.setint8(0xB70153, oldtime, true)
		memory.setint8(0xC81320, oldweather, true)
	end
end
