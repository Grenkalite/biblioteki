script_author('Cosmo')
require "moonloader"
inicfg = require 'inicfg'
memory = require 'memory'

tag = 'Minecraft Hud: {33AA33}'
sw, sh = getScreenResolution()
cfg = inicfg.load({
    pos = {
        x = 100,
        y = 200
    }
}, 'mineHud')
pos = { 
	['x'] = cfg.pos.x, 
	['y'] = cfg.pos.y 
}

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(80) end
    
    editHealthBarCoordinates(sw, -10)  -- govno code
    sampRegisterChatCommand('minehud', function()
    	statePos = not statePos
    	if statePos then
    		sampAddChatMessage(tag..'Используйте СТРЕЛКИ для перемещения', 0x9B6300)
    		sampAddChatMessage(tag..'Введите команду заного что-бы сохранить положение', 0x9B6300)
    	else
    		if inicfg.save(cfg, 'mineHud.ini') then 
    			sampAddChatMessage(tag..'Позиция сохранена!', 0x9B6300)
    		end
    	end
    end)
    if not doesFileExist('moonloader/config/mineHud.ini') then inicfg.save(cfg, 'mineHud.ini') end
    if not loadTextures() then
		sampAddChatMessage(tag..'Не удалось найти файл(ы) для работы скрипта!', 0x9B6300)
		return
	end
	
	sampRegisterChatCommand('hhp', function(hp)
		if tonumber(hp) then 
			setCharHealth(playerPed, hp)
		end
	end)

    while true do

    	local bSpawned = sampIsLocalPlayerSpawned()
    	if bSpawned then
	    	X, Y = pos['x'], pos['y']
	    	HP = getCharHealth(playerPed)
	    	if tDamage == nil then tDamage = { HP, nil, nil, nil } end
	    	math.randomseed(tonumber(tostring(os.clock()):match('%.(%d)')) or 0)
	    	
	    	if tDamage[1] ~= HP then
	    	 	local GiveHP = HP - tDamage[1]
	    	 	tDamage = { HP, HP - GiveHP, GiveHP, GiveHP > 0 and os.clock() - 0.5 or os.clock() }
		    end

	    	if tDamage[4] == nil or (os.clock() - tDamage[4] > 1.0) then
		    	for i = 10, 100, 10 do
		    		if HP >= i then 
		    			drawHeart(tTextures[1], X, (HP <= 40 and Y + math.random(-1, 0) or Y), 13)
		    		elseif HP > i - 10 and HP ~= i then
		    			drawHeart(tTextures[2], X, (HP <= 40 and Y + math.random(-1, 0) or Y), 13)
		    		else
		    			drawHeart(tTextures[3], X, (HP <= 40 and Y + math.random(-1, 0) or Y), 13)
		    		end
		    		X = X + 11.5    	
		    	end
		    else
		    	local LHP = tDamage[2]
		    	if not blicking then -- nano tecnology
			    	blicking = lua_thread.create(function()
			    		blick = not blick
			    		wait(125)
			    		blicking = nil
			    	end)
			    end

		    	for i = 10, 100, 10 do
		    		if HP >= i then
		    			if blick then
		    				drawHeart(tTextures[4], X, (HP <= 40 and Y + math.random(-1, 0) or Y), 13)
		    			else
		    				drawHeart(tTextures[1], X, (HP <= 40 and Y + math.random(-1, 0) or Y), 13)
		    			end
		    		elseif HP > i - 10 and HP ~= i then  
		    			if blick then
		    				drawHeart(tTextures[i > LHP and 5 or 8], X, (HP <= 40 and Y + math.random(-1, 0) or Y), 13)
		    			else
		    				drawHeart(tTextures[2], X, (HP <= 40 and Y + math.random(-1, 0) or Y), 13)
		    			end
		    		else
		    			if blick then
			    			drawHeart(tTextures[i > LHP and 6 or 7], X, (HP <= 40 and Y + math.random(-1, 0) or Y), 13)
			    		else
			    			drawHeart(tTextures[3], X, (HP <= 40 and Y + math.random(-1, 0) or Y), 13)
			    		end
		    		end
		    		X = X + 11.5
		    	end
		    end
	    end

	    if statePos then
    		if not sampIsCursorActive() then 
	    		if isKeyDown(VK_LEFT) then 
	    			cfg.pos.x = cfg.pos.x - 0.5
	    			pos['x'] = cfg.pos.x
	    		end
	    		if isKeyDown(VK_RIGHT) then 
	    			cfg.pos.x = cfg.pos.x + 0.5
	    			pos['x'] = cfg.pos.x
	    		end
	    		if isKeyDown(VK_UP) then 
	    			cfg.pos.y = cfg.pos.y - 0.5
	    			pos['y'] = cfg.pos.y
	    		end
	    		if isKeyDown(VK_DOWN) then
	    			cfg.pos.y = cfg.pos.y + 0.5
	    			pos['y'] = cfg.pos.y
	    		end
	    	end
    	end
    wait(0)
    end
end

tStates = {'heart_full', 'heart_half', 'heart_none', 'damage_full', 'damage_half', 'damage_none', 'blick_full', 'blick_half'}
function loadTextures()
	if tTextures == nil then
    	tTextures = getTextures("mineHud", tStates)
    	if tTextures == nil then return false end
  	end
  	return true
end

function getTextures(txd, names)
  	if not loadTextureDictionary(txd) then return nil end
	local t = {}
	for _, name in ipairs(names) do
		local id = loadSprite(name)
		table.insert(t, id)
	end
	return t
end

function drawHeart(id, x, y, size)
  setSpritesDrawBeforeFade(true)
  drawSprite(id, x, y, size, size, 255, 255, 255, 255)
end

function editHealthBarCoordinates(posX, posY)
    local X = memory.getuint32(0x58EE87, true)
    local Y = memory.getuint32(0x58EE68, true)
    memory.setfloat(X, posX)
    memory.setfloat(Y, posY)
end