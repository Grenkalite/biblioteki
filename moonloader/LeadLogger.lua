script_name('LeadLogger')
script_version('2.0')
script_description('/logger')
script_author('Cosmo')

require "moonloader"
se = require 'lib.samp.events'
inicfg = require 'inicfg'
imgui = require 'imgui'
encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

cfg = inicfg.load({ 
	logs = {
		['/giverank'] 	= '!member | !rankNameOld(!rankOld) -> !rankNameNew(!rankNew) | !date | !time | Выдал: !myName',
		['/invite'] 	= 'Новый член организации: !member. Принят !date !time',
		['/uninvite'] 	= 'Уволен член организации: !member. Причина: !reason. Дата: !date !time',
		['/fwarn'] 		= 'Выдан выговор игроку: !member | Причина: !reason. Дата: !date !time',
		['/unfwarn'] 	= 'Снят выговор игроку: !member. Дата: !date !time',
		['/fmute'] 		= 'Выдана заглушка игроку: !member на !muteTime минут | Причина: !reason. Дата: !date !time',
		['/funmute']  	= 'Снята заглушка игроку: !member. Дата: !date !time',
		['/blacklist'] 	= 'Игрок !member занесён в Чёрный Список организации. Причина: !reason. Дата: !date !time'
	},
	countToday = {
		['last'] = tonumber(os.date("%d", os.time())),
		['/giverank'] 	= 0,
		['/invite'] 	= 0,
		['/uninvite'] 	= 0,
		['/fwarn'] 		= 0,
		['/unfwarn'] 	= 0,
		['/fmute'] 		= 0,
		['/funmute']  	= 0,
		['/blacklist'] 	= 0
	},
	countAll = {
		['/giverank'] 	= 0,
		['/invite'] 	= 0,
		['/uninvite'] 	= 0,
		['/fwarn'] 		= 0,
		['/unfwarn'] 	= 0,
		['/fmute'] 		= 0,
		['/funmute']  	= 0,
		['/blacklist'] 	= 0
	},
	ranks = {
		[1]  = 'Стажёр',
		[2]  = 'Охранник',
		[3]  = 'Ст.Охранник',
		[4]  = 'Начальник Охраны',
		[5]  = 'Мл. Сотрудник',
		[6]  = 'Ст. Сотрудник',
		[7]  = 'Менеджер',
		[8]  = 'Начальник отдела',
		[9]  = 'Зам. Директора',
		[10] = 'Директор'
	}
}, "LLogger")

mainPath = os.getenv("USERPROFILE")..'\\Documents\\GTA San Andreas User Files\\SAMP\\Leader-Logger'
wc, mc, mcx = '{FFFFFF}', '{0079FF}', 0x0079FF
tag = mc..'Leader-Logger: '..wc
sWindow = 'main'
ImMenu = imgui.ImBool(false)
ImLogs = imgui.ImBuffer(131072)
TodayLast = imgui.ImInt(cfg.countToday['last'])

ImEdit = {
	['/giverank'] 	= imgui.ImBuffer(u8(cfg.logs['/giverank']), 256),
	['/invite'] 	= imgui.ImBuffer(u8(cfg.logs['/invite']), 256),
	['/uninvite'] 	= imgui.ImBuffer(u8(cfg.logs['/uninvite']), 256),
	['/fwarn'] 		= imgui.ImBuffer(u8(cfg.logs['/fwarn']), 256),
	['/unfwarn'] 	= imgui.ImBuffer(u8(cfg.logs['/unfwarn']), 256),
	['/fmute'] 		= imgui.ImBuffer(u8(cfg.logs['/fmute']), 256),
	['/funmute']  	= imgui.ImBuffer(u8(cfg.logs['/funmute']), 256),
	['/blacklist'] 	= imgui.ImBuffer(u8(cfg.logs['/blacklist']), 256)
}
ImRank 	= {
	[1]  = imgui.ImBuffer(u8(cfg.ranks[1]), 256),
	[2]  = imgui.ImBuffer(u8(cfg.ranks[2]), 256),
	[3]  = imgui.ImBuffer(u8(cfg.ranks[3]), 256),
	[4]  = imgui.ImBuffer(u8(cfg.ranks[4]), 256),
	[5]  = imgui.ImBuffer(u8(cfg.ranks[5]), 256),
	[6]  = imgui.ImBuffer(u8(cfg.ranks[6]), 256),
	[7]  = imgui.ImBuffer(u8(cfg.ranks[7]), 256),
	[8]  = imgui.ImBuffer(u8(cfg.ranks[8]), 256),
	[9]  = imgui.ImBuffer(u8(cfg.ranks[9]), 256),
	[10] = imgui.ImBuffer(u8(cfg.ranks[10]), 256)
}
ImCountToday = {
	['/giverank'] 	= imgui.ImInt(cfg.countToday['/giverank']),
	['/invite'] 	= imgui.ImInt(cfg.countToday['/invite']),
	['/uninvite'] 	= imgui.ImInt(cfg.countToday['/uninvite']),
	['/fwarn'] 		= imgui.ImInt(cfg.countToday['/fwarn']),
	['/unfwarn'] 	= imgui.ImInt(cfg.countToday['/unfwarn']),
	['/fmute'] 		= imgui.ImInt(cfg.countToday['/fmute']),
	['/funmute']  	= imgui.ImInt(cfg.countToday['/funmute']),
	['/blacklist'] 	= imgui.ImInt(cfg.countToday['/blacklist'])
}
ImCountAll = {
	['/giverank'] 	= imgui.ImInt(cfg.countAll['/giverank']),
	['/invite'] 	= imgui.ImInt(cfg.countAll['/invite']),
	['/uninvite'] 	= imgui.ImInt(cfg.countAll['/uninvite']),
	['/fwarn'] 		= imgui.ImInt(cfg.countAll['/fwarn']),
	['/unfwarn'] 	= imgui.ImInt(cfg.countAll['/unfwarn']),
	['/fmute'] 		= imgui.ImInt(cfg.countAll['/fmute']),
	['/funmute']  	= imgui.ImInt(cfg.countAll['/funmute']),
	['/blacklist'] 	= imgui.ImInt(cfg.countAll['/blacklist'])
}

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(80) end
    	log('Логгирование действий во фракции '..mc..'включено!')
    	if sampRegisterChatCommand('logger', function() ImMenu.v = not ImMenu.v; sWindow = 'main' end) then log('Настройки: /logger') end
    	if not doesFileExist('moonloader/config/LLogger.ini') then inicfg.save(cfg, 'LLogger.ini') end
    	loadlogs()
    while true do
    	local selfId = select(2, sampGetPlayerIdByCharHandle(playerPed))
    	tInfo = {
    		['selfId'] = selfId,
			['selfName'] = sampGetPlayerNickname(selfId),
			['date'] = os.date("%d.%m.%Y", os.time()),
			['time'] = os.date("%H:%M:%S", os.time())
    	}
		imgui.Process = ImMenu.v
		checkDate()
    	wait(0)
    end
end

local fs18, fs20 = nil, nil
function imgui.BeforeDrawFrame()
	if fs18 == nil then fs18 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 18.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end
    if fs20 == nil then fs20 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end
end

function imgui.OnDrawFrame()
	local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(650, 300), imgui.Cond.FirstUseEver)

    imgui.Begin('Leader-Logger', ImMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.ShowBorders)
    	if sWindow == 'main' then
	    	imgui.CenterTextColoredRGB(mc..'В этом окне считаются ваши руководительские действия в организации')
	    	imgui.CenterTextColoredRGB('{909090}Для просмотра логов нажми на нужное действие')
	    	imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
	    	if imgui.Button(u8'Изменить названия рангов', imgui.ImVec2(200, 20)) then 
	    		sWindow = 'ranks'
	    	end
	    	imgui.NewLine()
	    	countBut = 0
	    	for k, v in pairs(cfg.logs) do 
	    		imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
		    		imgui.BeginChild('##Child-'..k, imgui.ImVec2(150, 105), true)
		    		    imgui.PushFont(fs18)
		    		    if imgui.Button(u8(k), imgui.ImVec2(150, 60)) then
		    		    	local getLog = io.open(mainPath..'\\'..k..'.txt', 'r+')
		    		    	local tLogTxt = {}
                            for str in getLog:lines() do
                                table.insert(tLogTxt, str)
                            end getLog:close()
                            ImLogs.v = u8(table.concat(tLogTxt, '\n'))
                            sWindow = k
		    		    end
		    		    imgui.PopFont()
		    		    imgui.CenterTextColoredRGB('За сегодня: '..mc..ImCountToday[k].v)
		    		    imgui.CenterTextColoredRGB('{606060}За всё время: {909090}'..ImCountAll[k].v)
		    		imgui.EndChild()
		    	imgui.PopStyleVar()
	    		countBut = countBut + 1
	    		if countBut ~= 4 and countBut ~= 8 then 
	    			imgui.SameLine() 
	    		end
	    	end
	    	imgui.CenterTextColoredRGB('{606060}Автор: Cosmo')
	    	imgui.Hint('VK: @opasanya\nDiscord: cosmo#1000')
	    elseif sWindow == 'ranks' then
	    	imgui.PushFont(fs18)
	    	imgui.CenterTextColoredRGB(mc..'Настройка названия рангов')
	    	imgui.PopFont()
	    	imgui.NewLine()
	    	for k = 1, 10 do 
	    		imgui.PushItemWidth(300)
	    		imgui.Text(u8(k..' ранг')); imgui.SameLine(60)
	    		imgui.InputText('##editrank'..k, ImRank[k])
	    		imgui.SameLine()
	    		if ImRank[k].v ~= u8(cfg.ranks[k]) and #ImRank[k].v > 0 then 
	    			if imgui.Button(u8'Сохранить##'..k, imgui.ImVec2(100, 20)) then 
	    				cfg.ranks[k] = u8:decode(ImRank[k].v)
	    				inicfg.save(cfg, 'LLogger.ini')
		    		end
	    		else
	    			imgui.DisableButton(u8'Сохранить##'..k, imgui.ImVec2(100, 20))
	    		end
	    		imgui.PopItemWidth()
	    	end
	    	imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
	    	if imgui.Button(u8'Вернуться назад', imgui.ImVec2(200, 25)) then sWindow = 'main' end
	    else
	    	imgui.PushFont(fs20)
		   	imgui.CenterTextColoredRGB('Логгирование действия: '..mc..sWindow)
		    imgui.PopFont()
		    local pathSelect = mainPath..sWindow:gsub('/', '\\')..'.txt'
		    imgui.CenterTextColoredRGB('{606060}'..pathSelect)
		    if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then os.execute('explorer '..pathSelect) end
		    imgui.Hint(u8'Дважды кликните что-бы открыть этот текстовый файл', 1)
		    imgui.NewLine()
		    imgui.TextColoredRGB(mc..'Форма логгирования c использованием {SSSSSS}паттернов:')
		    imgui.Hint(u8'Паттерны (или же теги) - заменяют себя на входящую в них информацию при выполнении действия\n\nПример:\nНам нужно что бы строка лога была такого формата:\nLesha_Povaresha был повышен на 3 ранг. Дата: 10.01.2020\n\nС помощью патернов сделаем такую строку:\n!member был повышен на !rankNew ранг. Дата: !date\n\nДалее скрипт сам будет заменять эти паттерны на нужную информацию')
		    if ImEdit[sWindow].v ~= u8(cfg.logs[sWindow]) then 
		    	imgui.SameLine()
		    	if imgui.SmallButton(u8'Сохранить') then 
		    		cfg.logs[sWindow] = u8:decode(ImEdit[sWindow].v)
		    		inicfg.save(cfg, 'LLogger.ini')
		    	end
		    end
		    imgui.PushItemWidth(650)
		    imgui.InputText('##EditForma', ImEdit[sWindow])
		    imgui.SameLine()
		    if imgui.Button(u8'Паттерны', imgui.ImVec2(100, 20)) then 
		    	imgui.OpenPopup('##allPatterns')
		    end
		    patternsContext()
		    imgui.TextColoredRGB(mc..'Преобразованая форма: {606060}(пример)')
		    imgui.TextColoredRGB(getExitString(sWindow, true))
		    imgui.PopItemWidth()
		    imgui.NewLine()
		    imgui.InputTextMultiline("##LogList", ImLogs, imgui.ImVec2(755, 400), imgui.InputTextFlags.ReadOnly)
		    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.28, 0.45, 1.00, 1.00))
		    if imgui.Button(u8'Вернуться назад', imgui.ImVec2(755, 25)) then sWindow = 'main' end
		    imgui.PopStyleColor()
		    if #ImLogs.v == 0 then
			    imgui.SetCursorPosY(380)
			    imgui.CenterTextColoredRGB('{606060}Пусто')
			end
	    end
    imgui.End()
end

function se.onSendCommand(cmd)
	if cmd:match('/invite %d+') then
    	local id = cmd:match('/invite (%d+)')
    	if sampIsPlayerConnected(id) then
    		tOutput = {
				['!member'] 		= sampGetPlayerNickname(id),
				['!date'] 			= tInfo['date'],
				['!time'] 			= tInfo['time'],
				['!myName'] 		= tInfo['selfName'],
				['!myId'] 			= tInfo['selfId']
			}
    		writeLog('/invite')
    	end
    end

    if cmd:match('/giverank %d+ %d+') then
    	local id, rank = cmd:match('/giverank (%d+) (%d+)')
    	local rank = tonumber(rank)
    	if sampIsPlayerConnected(id) and rank > 1 and rank < 10 then
    		tOutput = {
				['!member'] 		= sampGetPlayerNickname(id),
				['!rankNameOld'] 	= u8:decode(ImRank[rank - 1].v),
				['!rankNameNew']	= u8:decode(ImRank[rank].v),
				['!rankOld'] 		= rank - 1,
				['!rankNew'] 		= rank,
				['!date'] 			= tInfo['date'],
				['!time'] 			= tInfo['time'],
				['!myName'] 		= tInfo['selfName'],
				['!myId'] 			= tInfo['selfId']
			}
    		writeLog('/giverank')
    	end
    end

    if cmd:match('/uninvite %d+ .+') then
    	local id, reason = cmd:match('/uninvite (%d+) (.+)')
    	if sampIsPlayerConnected(id) and reason then
    		tOutput = {
				['!member'] 		= sampGetPlayerNickname(id),
				['!date'] 			= tInfo['date'],
				['!time'] 			= tInfo['time'],
				['!myName'] 		= tInfo['selfName'],
				['!myId'] 			= tInfo['selfId'],
 				['!reason'] 		= tostring(reason)
			}
    		writeLog('/uninvite')
    	end
    end

    if cmd:match('/fwarn %d+ .+') then
    	local id, reason = cmd:match('/fwarn (%d+) (.+)')
    	if sampIsPlayerConnected(id) and reason then
    		tOutput = {
				['!member'] 		= sampGetPlayerNickname(id),
				['!date'] 			= tInfo['date'],
				['!time'] 			= tInfo['time'],
				['!myName'] 		= tInfo['selfName'],
				['!myId'] 			= tInfo['selfId'],
 				['!reason'] 		= tostring(reason)
			}
    		writeLog('/fwarn')
    	end
    end

    if cmd:match('/unfwarn %d+') then
    	local id = cmd:match('/unfwarn (%d+)')
    	if sampIsPlayerConnected(id) then
    		tOutput = {
				['!member'] 		= sampGetPlayerNickname(id),
				['!date'] 			= tInfo['date'],
				['!time'] 			= tInfo['time'],
				['!myName'] 		= tInfo['selfName'],
				['!myId'] 			= tInfo['selfId']
			}
    		writeLog('/unfwarn')
    	end
    end

    if cmd:match('/fmute %d+ %d+ .+') then
    	local id, time, reason = cmd:match('/fmute (%d+) (%d+) (.+)')
    	if sampIsPlayerConnected(id) and tonumber(time) and reason then
    		tOutput = {
				['!member'] 		= sampGetPlayerNickname(id),
				['!date'] 			= tInfo['date'],
				['!time'] 			= tInfo['time'],
				['!myName'] 		= tInfo['selfName'],
				['!myId'] 			= tInfo['selfId'],
				['!reason'] 		= tostring(reason),
				['!muteTime'] 		= tonumber(time)
			}
    		writeLog('/fmute')
    	end
    end

    if cmd:match('/funmute %d+') then
    	local id = cmd:match('/funmute (%d+)')
    	if sampIsPlayerConnected(id) then
    		tOutput = {
				['!member'] 		= sampGetPlayerNickname(id),
				['!date'] 			= tInfo['date'],
				['!time'] 			= tInfo['time'],
				['!myName'] 		= tInfo['selfName'],
				['!myId'] 			= tInfo['selfId']
			}
    		writeLog('/funmute')
    	end
    end

    if cmd:match('/blacklist %d+ .+') then
    	local id, reason = cmd:match('/blacklist (%d+) (.+)')
    	if sampIsPlayerConnected(id) and reason then
    		tOutput = {
				['!member'] 		= sampGetPlayerNickname(id),
				['!date'] 			= tInfo['date'],
				['!time'] 			= tInfo['time'],
				['!myName'] 		= tInfo['selfName'],
				['!reason'] 		= tostring(reason),
				['!myId'] 			= tInfo['selfId']
			}
    		writeLog('/blacklist')
    	end
    end
end

function writeLog(nameLog)
	local Log = io.open(mainPath..'\\'..nameLog:gsub('/', '')..'.txt', "a")
	Log:write(getExitString(nameLog, false)..'\n')
	Log:close()

	ImCountAll[nameLog].v = ImCountAll[nameLog].v + 1; cfg.countAll[nameLog] = ImCountAll[nameLog].v
	ImCountToday[nameLog].v = ImCountToday[nameLog].v + 1; cfg.countToday[nameLog] = ImCountToday[nameLog].v
	inicfg.save(cfg, 'LLogger.ini')
end

function getExitString(lable, demo)
	local demo = demo and true or false
	local template = u8:decode(ImEdit[lable].v)
	local tDemo = {
		['!member'] 		= 'Nick_Name',
		['!rankNameOld'] 	= 'Охранник',
		['!rankNameNew']	= 'Ст. Охранник',
		['!rankOld'] 		= '1',
		['!rankNew'] 		= '2',
		['!date'] 			= '01.01.2000',
		['!time'] 			= '10:50:25',
		['!myName'] 		= tInfo['selfName'],
		['!myId'] 			= tInfo['selfId'],
		['!reason'] 		= 'Наруш. Устава',
		['!muteTime'] 		= '30'
	}

	local isPatternAllowed = function(typeLog, pattern)
		tAllowedPatterns = {
			['/giverank'] 	= {'!member', '!rankNameOld', '!rankNameNew', '!rankOld', '!rankNew', '!date', '!time', '!myId', '!myName'},
			['/invite'] 	= {'!member', '!date', '!time', '!myId', '!myName'},
			['/uninvite'] 	= {'!member', '!date', '!time', '!myId', '!myName', '!reason'},
			['/fwarn'] 		= {'!member', '!date', '!time', '!myId', '!myName', '!reason'},
			['/unfwarn'] 	= {'!member', '!date', '!time', '!myId', '!myName'},
			['/fmute'] 		= {'!member', '!date', '!time', '!myId', '!myName', '!reason', '!muteTime'},
			['/funmute']  	= {'!member', '!date', '!time', '!myId', '!myName'},
			['/blacklist'] 	= {'!member', '!date', '!time', '!myId', '!myName', '!reason'}
		}
		for k, v in pairs(tAllowedPatterns[typeLog]) do 
			if v == pattern then return true end
		end
		return false
	end

	local getResultFromTemplate = function(typeLog, template, pattern)
		local bPat = isPatternAllowed(typeLog, pattern)
		local errPat = '{FF2000}'..pattern..'{SSSSSS}'
		return template:gsub(pattern, (bPat and (demo and tDemo[pattern] or tOutput[pattern]) or errPat))
	end

	local template = getResultFromTemplate(lable, template, '!member')
	local template = getResultFromTemplate(lable, template, '!rankNameOld')
	local template = getResultFromTemplate(lable, template, '!rankNameNew')
	local template = getResultFromTemplate(lable, template, '!rankOld')
	local template = getResultFromTemplate(lable, template, '!rankNew')
	local template = getResultFromTemplate(lable, template, '!date')
	local template = getResultFromTemplate(lable, template, '!time')
	local template = getResultFromTemplate(lable, template, '!myName')
	local template = getResultFromTemplate(lable, template, '!myId')
	local template = getResultFromTemplate(lable, template, '!reason')
	local template = getResultFromTemplate(lable, template, '!muteTime')
	return template
end

function loadlogs()
	createDirectory(mainPath)
	for nameLog, _ in pairs(cfg.logs) do
		local nameLog = nameLog:gsub('/', '')..'.txt'
		local pathLog = mainPath..'\\'..nameLog
		if not doesFileExist(pathLog) then 
			local newLog = io.open(pathLog, "a"); newLog:close()
			log('Создан пустой файл: '..mc..nameLog)
		end
	end
end

function log(text)
	sampfuncsLog(tag..text)
end

function patternsContext()
	if imgui.BeginPopupContextItem('##allPatterns') then
		imgui.PushFont(fs18)
	   	imgui.CenterTextColoredRGB(mc..'Поддерживаемые паттерны')
	    imgui.PopFont()
	   	imgui.CenterTextColoredRGB('{606060}Нажми что-бы скопировать')
	    imgui.NewLine()
		showPattern('!member', 		'Получает Nick_Name игрока') 
		showPattern('!rankNameOld', 'Получает сатрое название ранга\nТолько в /giverank!')
		showPattern('!rankNameNew', 'Получает новое название ранга\nТолько в /giverank!')
		showPattern('!rankOld', 	'Получает номер старого ранга\nТолько в /giverank!')
		showPattern('!rankNew', 	'Получает номер нового ранга\nТолько в /giverank!')
		showPattern('!date', 		'Получает текущую дату') 
		showPattern('!time', 		'Получает текущее время') 
		showPattern('!myName', 		'Получает ваш Nick_Name') 
		showPattern('!myId', 		'Получает ваш ID') 
		showPattern('!reason', 		'Получает причину\nТолько в /fmute, /fwarn, /blacklist!') 
		showPattern('!muteTime', 	'Получает время мута\nТолько в /fmute!')
		imgui.EndPopup()
	end
end

function showPattern(patName, patInfo)
	if imgui.Button(u8(patName), imgui.ImVec2(230, 30)) then 
		setClipboardText(patName)
		imgui.CloseCurrentPopup()
	end
	imgui.Hint(u8(patInfo))
end

function checkDate()
	if TodayLast.v ~= tonumber(os.date("%d", os.time())) then 
		TodayLast.v = tonumber(os.date("%d", os.time()))
		cfg.countToday['last'] = TodayLast.v
		for k, v in pairs(ImCountToday) do 
			ImCountToday[k].v = 0
			cfg.countToday[k] = ImCountToday[k].v
		end		
	end
end

function theme()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

    style.WindowPadding 		= imgui.ImVec2(8, 8)
    style.WindowRounding 		= 6
    style.ChildWindowRounding 	= 5
    style.FramePadding 			= imgui.ImVec2(5, 3)
    style.FrameRounding 		= 5.0
    style.ItemSpacing 			= imgui.ImVec2(5, 4)
    style.ItemInnerSpacing 		= imgui.ImVec2(4, 4)
    style.IndentSpacing 		= 21
    style.ScrollbarSize 		= 10.0
    style.ScrollbarRounding 	= 13
    style.GrabMinSize 			= 8
    style.GrabRounding			= 1
    style.WindowTitleAlign 		= imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign 		= imgui.ImVec2(0.5, 0.5)
  
	colors[clr.Text] 					= ImVec4(0.95, 0.96, 0.98, 1.00)
	colors[clr.TextDisabled] 			= ImVec4(0.36, 0.42, 0.47, 1.00)
	colors[clr.WindowBg] 				= ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ChildWindowBg] 			= ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.PopupBg] 				= ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border] 					= ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.BorderShadow] 			= ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] 				= ImVec4(0.28, 0.56, 1.00, 0.10)
	colors[clr.FrameBgHovered] 			= ImVec4(0.12, 0.20, 0.28, 1.00)
	colors[clr.FrameBgActive] 			= ImVec4(0.09, 0.12, 0.14, 1.00)
	colors[clr.TitleBg] 				= ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.TitleBgCollapsed] 		= ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.TitleBgActive] 			= ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.MenuBarBg] 				= ImVec4(0.15, 0.18, 0.22, 1.00)
	colors[clr.ScrollbarBg] 			= ImVec4(0.02, 0.02, 0.02, 0.39)
	colors[clr.ScrollbarGrab] 			= ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.18, 0.22, 0.25, 1.00)
	colors[clr.ScrollbarGrabActive] 	= ImVec4(0.09, 0.21, 0.31, 1.00)
	colors[clr.ComboBg] 				= ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.CheckMark] 				= ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.SliderGrab] 				= ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.SliderGrabActive] 		= ImVec4(0.37, 0.61, 1.00, 1.00)
	colors[clr.Button] 					= ImVec4(0.28, 0.56, 1.00, 0.10)
	colors[clr.ButtonHovered] 			= ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.ButtonActive] 			= ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header] 					= ImVec4(0.20, 0.25, 0.29, 0.55)
	colors[clr.HeaderHovered] 			= ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive] 			= ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip] 				= ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered] 		= ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive] 		= ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton]            	= ImVec4(0.00, 0.00, 0.00, 0.30)
    colors[clr.CloseButtonHovered]     	= ImVec4(1.00, 0.00, 0.00, 0.80)
    colors[clr.CloseButtonActive]      	= ImVec4(1.00, 0.00, 0.00, 1.00)
	colors[clr.PlotLines] 				= ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered] 		= ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram] 			= ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered] 	= ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg] 			= ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.ModalWindowDarkening] 	= ImVec4(1.00, 0.98, 0.95, 0.73)
end
theme()

function imgui.Hint(text, delay)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- скорость появления
        if os.clock() >= go_hint then 
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.28, 0.46, 1.00, 1.00))
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(450)
                    imgui.TextUnformatted(text)
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar()
        end
    end
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function imgui.DisableButton(...)
    local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(r, g, b, a / 2) )
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a / 2) )
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a / 2))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a / 2))
    imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
    local result = imgui.Button(...)
    imgui.PopStyleColor(5)
    return result
end

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end