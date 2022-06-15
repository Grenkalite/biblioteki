-- by Cosmo with love <3
local se = require "samp.events"
local ini = require "inicfg"
local font = renderCreateFont("Arial", 10, 9)
local cfg = ini.load(
	{ main = { delay = 0.7 } },
	"vip-resend"
)

function main()
	assert(isSampLoaded(), 'SA:MP was not loaded!')
	while not isSampAvailable() do wait(0) end
	sampRegisterChatCommand("vipdelay", vip_delay)
	wait(0)
end

function vip_delay(sec)
	sec = tonumber(sec)
	if sec ~= nil and sec >= 0.1 and sec <= 5.0 then
		cfg.main.delay = sec
		ini.save(cfg, 'vip-resend.ini')
		sampAddChatMessage(string.format("Задержка изменена на {EEEEEE}%0.1f сек.", sec), 0xFF9900)
		return
	end
	sampAddChatMessage("[Ошибка] {EEEEEE}Используйте: /vipdelay [ {FF9900}0.1 - 5.0{EEEEEE} ] ", 0xFF9900)
end

function se.onSendCommand(cmd)
	local result = cmd:match("^/vr (.+)")
	if result ~= nil then
		if process ~= nil and result ~= message then
			process:terminate()
			process = nil
		end
		if process == nil then
			finished, try = false, 1
			message = tostring(result)
			process = lua_thread.create(function()
				while not finished do
					if sampGetGamestate() ~= 3 then
						finished = true; break
					end
					if not sampIsChatInputActive() then
						local rotate = math.sin(os.clock() * 3) * 90 + 90
				        local el = getStructElement(sampGetInputInfoPtr(), 0x8, 4)
				        local X, Y = getStructElement(el, 0x8, 4), getStructElement(el, 0xC, 4)
			        	renderDrawPolygon(X + 10, Y + (renderGetFontDrawHeight(font) / 2), 20, 20, 3, rotate, 0xFFFFFFFF)
	        			renderDrawPolygon(X + 10, Y + (renderGetFontDrawHeight(font) / 2), 20, 20, 3, -1 * rotate, 0xFF0090FF)
			        	renderFontDrawText(font, message, X + 25, Y, -1)
			        	renderFontDrawText(font, string.format(" [x%s]", try), X + 25 + renderGetFontDrawTextLength(font, message), Y, 0x40FFFFFF)
			        end
			        wait(0)
				end
				process = nil
			end)
		end
	end
end

function se.onServerMessage(color, text)
	if not finished then
		if text:find("^%[Ошибка%].*После последнего сообщения в этом чате нужно подождать") then
			lua_thread.create(function()
				wait(cfg.main.delay * 1000);
				sampSendChat("/vr " .. message)
				try = try + 1	
			end)
			return false
		end

		local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
		if text:match("%[%u+%] {%x+}[A-z0-9_]+%[" .. id .. "%]:") then
			finished = true
		end
	end

	if text:find("^Вы заглушены") or text:find("Для возможности повторной отправки сообщения в этот чат") then
		finished = true
	end
end