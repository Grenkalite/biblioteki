script_name("WHY.Lua")
script_description("")
script_author("")
script_url("")
script_version("0.1.0")
script_version_number(0)

local imgui = require("imgui")
imgui.ToggleButton = require("imgui_addons").ToggleButton
local cjson = require("cjson")
local dlstatus = require('moonloader').download_status
local k = require("vkeys")
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local main_window_state = imgui.ImBool(false)
local json = { categories = {}, data = {} } -- Раскомментируй это вместо тестового объекта
--[[
local json = { -- Объект для теста
	categories = {
		"cat1", "cat2", "cat3", "cat4", "cat5"
	},
	data = {
		{
			name = "Example Script",
			ver = "1651582993",
			date = "1",
			category = "cat1",
			filename = "example-script.lua",
			download_url = "https://pastebin.com/raw/AvPX9r4m"
		},
		{
			name = "Script 2",
			ver = "1650417622",
			date = "1",
			category = "cat2",
			filename = "example-script2.lua",
			download_url = "https://pastebin.com/raw/AvPX9r4m"
		},
		{
			name = "Script 3",
			ver = "42",
			date = "1",
			category = "cat3",
			filename = "example-script3.lua",
			download_url = "https://pastebin.com/raw/AvPX9r4mss"
		}
	}
}
--]]
local CWD = getWorkingDirectory() .. "\\"
local jsonPath = CWD .. "why.json"
local imgui_vars = { category = imgui.ImInt(1), script_status = {}, download_status = {} }


local FUCK_IMGUI = false
local FUCKING_DO_STUFF = {}
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	--jsonLoad("https://pastebin.com/raw/q1Zd5nJE", jsonPath) -- Закомментировано для теста
	jsonLoad("https://pastebin.com/raw/fNtXS6yZ", jsonPath) -- not mine
	--jsonLoad("https://pastebin.com/raw/UkBPh9qs", jsonPath) -- test mine not mine

	while true do wait(0)
		if not isSampfuncsConsoleActive() and not sampIsChatInputActive() and not sampIsDialogActive() then
			if isKeyDown(k.VK_SHIFT) and wasKeyPressed(k.VK_E) then -- Нажми SHIFT+R чтобы перезапустить этот скрипт
				reloadScript()
			elseif wasKeyPressed(k.VK_E) then -- Нажми R чтобы открыть главное окно скрипта
				main_window_state.v = not main_window_state.v
			end
			if isKeyDown(k.VK_SHIFT) and wasKeyPressed(k.VK_F) then
				load_script("SampBinder.lua")
			end
		end
		imgui.Process = main_window_state.v

		if FUCK_IMGUI then
			if FUCKING_DO_STUFF[0] == "unload_script" then
				unload_script_fuck(FUCKING_DO_STUFF[1], FUCKING_DO_STUFF[2])
			elseif FUCKING_DO_STUFF[0] == "load_script" then
				load_script_fuck(FUCKING_DO_STUFF[1])
			elseif FUCKING_DO_STUFF[0] == "delete_script" then
				delete_script_fuck(FUCKING_DO_STUFF[1], FUCKING_DO_STUFF[2])
			end
			FUCKING_DO_STUFF = {}
			FUCK_IMGUI = false
		end
	end
end


function jsonLoad(url, path)
	sampAddChatMessage("Starting download...", 0x00FFFF)
	downloadUrlToFile(url, path, function(id, status)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			sampAddChatMessage("Download finished!", 0x00FF00)
			local file = io.open(path, "r")
			if not file then
				sampAddChatMessage("File doesn't exist D:", 0xFF0000)
				return
			end
			local input = file:read("*a")
			file:close()
			os.remove(path)
			sampAddChatMessage("File read", 0x00FF00)
			json = cjson.decode(input)
			sampAddChatMessage("JSON decoded", 0x00FF00)
		end
	end)
end

local X, Y = getScreenResolution()

local cat_id = imgui.ImInt(-1)
function imgui.OnDrawFrame()
	imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)
  imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin("Scripters", main_window_state, imgui.WindowFlags.NoResize)
	                                        --Крестик
		imgui.BeginChild('Categories', imgui.ImVec2(120, 374))
			local txt_categor = 'Категории'
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8(txt_categor)).x)/2)
			imgui.Text(u8(txt_categor))
			imgui.Separator()
			for i,cat in ipairs(json.categories) do
				imgui.RadioButton(cat, imgui_vars.category, i)
			end
		imgui.EndChild()


		imgui.SameLine(130); imgui.BeginChild('main_child', imgui.ImVec2(465, 374), imgui.Cond.FirstUseEver)
			imgui.SameLine(3); imgui.Text(u8"№") -- Первый ряд
			imgui.SameLine(20); imgui.Text(u8"Название") -- Второй ряд
			imgui.SameLine(160); imgui.Text(u8"Версия") -- Третий ряд
			imgui.SameLine(242); imgui.Text(u8"Дата") -- Четвертый ряд
			imgui.Separator()

			local scripts = script.list()
			for i,entry in ipairs(json.data) do
				if entry.category == json.categories[imgui_vars.category.v] then
					imgui.Text(' '..tostring(i)..'.')
					imgui.SameLine(20); imgui.Text(entry.name)
					imgui.SameLine(160); imgui.Text(entry.ver)
					imgui.SameLine(222); imgui.Text(entry.date)

					if not imgui_vars.script_status[entry.filename] then
						imgui_vars.script_status[entry.filename] = imgui.ImBool(false)
					end
					local entryScript
					for i,scr in ipairs(scripts) do
						if scr.filename == entry.filename then
							entryScript = scr
						end
					end
					if entryScript then
						imgui_vars.script_status[entry.filename].v = true
					else
						imgui_vars.script_status[entry.filename].v = false
					end

					imgui.SameLine(318);
					if imgui.Button(u8('Скачать###dwnld' .. i)) then
						download_script(entry.download_url, entry.filename)
					end

					imgui.SameLine(295);
					if doesFileExist(CWD .. entry.filename) or doesFileExist(CWD .. entry.filename .. ".disabled") then
						imgui_vars.download_status[entry.filename] = true
					else
						imgui_vars.download_status[entry.filename] = false
					end
					test = imgui.ImBool(false)
					imgui.PushStyleColor( imgui.Col.CheckMark, imgui.ImVec4(0, 0.7, 0, 0.5) )
					imgui.RadioButton(u8'', imgui_vars.download_status[entry.filename])
					imgui.PopStyleColor()




				--[[	if imgui.Button(u8'О') then
						load_te(entry.filename)
					end

					imgui.SameLine(393)
					if imgui.Button(u8'I') then
						unload_te(entry.filename)
					end  --]]

					imgui.SameLine(405)
					if imgui.Button(u8('Удалить###del' .. i)) then
						delete_script(entry.filename, entryScript)
					end

					imgui.SameLine(375)
					if imgui.ToggleButton(entry.filename, imgui_vars.script_status[entry.filename]) then
						if imgui_vars.script_status[entry.filename].v then -- Включаем скрипт
							if doesFileExist(CWD .. entry.filename .. ".disabled") or doesFileExist(CWD .. entry.filename) then
								load_script(entry.filename)
							else
								imgui_vars.script_status[entry.filename].v = false
								sampAddChatMessage("Скрипт не найден", 0xFF0000)
							end
						else -- Выключаем скрипт
							unload_script(entry.filename, entryScript)
						end
					end
				end
			end

		imgui.EndChild()
	imgui.End()
end










function unload_script(path, scr)
	FUCKING_DO_STUFF = { path, scr }
	FUCKING_DO_STUFF[0] = "unload_script"
	FUCK_IMGUI = true
end

function load_script(path)
	FUCKING_DO_STUFF = { path }
	FUCKING_DO_STUFF[0] = "load_script"
	FUCK_IMGUI = true
end

function delete_script(path, scr)
	FUCKING_DO_STUFF = { path, scr }
	FUCKING_DO_STUFF[0] = "delete_script"
	FUCK_IMGUI = true
end


function unload_script_fuck(path, scr)
	scr:unload()
	os.rename(CWD .. path, CWD .. path .. '.disabled')
	print(u8'Disabled: ' .. path)
end

function load_script_fuck(path)
	if doesFileExist(CWD .. path .. ".disabled") then
		os.rename(CWD .. path .. '.disabled', CWD .. path)
	end
	script.load(path)
	print(u8"UnDisabled: " .. path)
end

function delete_script_fuck(path, scr)
	if scr then
		scr:unload()
	end
	os.remove(CWD .. path .. ".disabled")
	os.remove(CWD .. path)
	print(u8"Deleted: " .. path)
end

function download_script(url, path)
	local full_path = CWD .. path
	if doesFileExist(full_path) or doesFileExist(full_path .. ".disabled") then
		sampAddChatMessage("ХУЙ ТЕБЕ", 0xFF0000)
		return
	end
	print("Downloading: " .. path)
	downloadUrlToFile(url, full_path, function(id, status)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(full_path) then
				print(path .. ": Download finished!")
				script.load(full_path)
			else
				print(path .. ": ERROR DOWNLOADING FILE")
			end
		end
	end)
end

function reloadScript()
	main_window_state.v = false
	imgui.Process = false
	imgui.ShowCursor = false
	lua_thread.create(function() wait(0); thisScript():reload() end)
end


function guiCustomStyle()
	ImVec4 = imgui.ImVec4
	ImVec2 = imgui.ImVec2
	style = imgui.GetStyle()
	colors = style.Colors
	clr = imgui.Col
	imgui.SwitchContext()
	style.WindowPadding                = ImVec2(4.0, 4.0)
	style.WindowRounding               = 7
	style.WindowTitleAlign             = ImVec2(0.5, 0.5)
	style.FramePadding             	   = ImVec2(4.0, 2.0)
	style.ItemSpacing                  = ImVec2(8.0, 4.0)
	style.ItemInnerSpacing             = ImVec2(4.0, 4.0)
	style.ChildWindowRounding          = 7
	style.FrameRounding                = 7
	style.ScrollbarRounding            = 7
	style.GrabRounding                 = 7
	style.IndentSpacing                = 21.0
	style.ScrollbarSize                = 13.0
	style.GrabMinSize                  = 10.0
	style.ButtonTextAlign              = ImVec2(0.5, 0.5)
	colors[clr.Text]                   = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.86, 0.86, 0.86, 1.00)
	colors[clr.ChildWindowBg]          = ImVec4(0.71, 0.71, 0.71, 1.00)
	colors[clr.PopupBg]                = ImVec4(0.79, 0.79, 0.79, 1.00)
	colors[clr.Border]                 = ImVec4(0.00, 0.00, 0.00, 0.36)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.10)
	colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.FrameBgHovered]         = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.FrameBgActive]          = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TitleBg]                = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.MenuBarBg]              = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(1.00, 1.00, 1.00, 0.86)
	colors[clr.ScrollbarGrab]          = ImVec4(0.37, 0.37, 0.37, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.60, 0.60, 0.60, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.21, 0.21, 0.21, 1.00)
	colors[clr.ComboBg]                = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.42, 0.42, 0.42, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.65, 0.65, 0.65, 1.00)
	colors[clr.Button]                 = ImVec4(0.52, 0.52, 0.52, 1.00)
	colors[clr.ButtonHovered]          = ImVec4(0.52, 0.52, 0.52, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.44, 0.44, 0.44, 0.83)
	colors[clr.Header]                 = ImVec4(0.86, 0.86, 0.86, 1.00) -- select
	colors[clr.HeaderHovered]          = ImVec4(0.75, 0.75, 0.75, 1.00)
	colors[clr.HeaderActive]           = ImVec4(0.6, 0.6, 0.6, 1.00)
	colors[clr.Separator]              = ImVec4(0.46, 0.46, 0.46, 1.00) -- end
	colors[clr.SeparatorHovered]       = ImVec4(0.45, 0.45, 0.45, 1.00)
	colors[clr.SeparatorActive]        = ImVec4(0.45, 0.45, 0.45, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.23, 0.23, 0.23, 1.00)
	colors[clr.ResizeGripHovered]      = ImVec4(0.32, 0.32, 0.32, 1.00)
	colors[clr.ResizeGripActive]       = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.70, 0.70, 0.70, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.62, 0.62, 0.62, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60)
end
guiCustomStyle()

return scripters
