local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


ESX                    = nil
local SuccessLimit     = 0.08 -- Maxim 0.1 (korkea arvo, alhaiset onnistumismahdollisuudet)
local AnimationSpeed   = 0.0010
local ShowChatMSG      = false -- tai false

local IsFishing, CFish = false, false
local BarAnimation, Faketimer = 0, 0
local RunCodeOnly1Time = true
local PosX = 0.5
local PosY, TimerAnimation = 0.1, 0.1
local ostaja = {
    {741.74169, 4170.9106, 40.087863, "Smecherica", 162.13127, 0x0DE9A30A, "s_m_m_ammucountry"},
}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function GetCar() return GetVehiclePedIsIn(GetPlayerPed(-1), false) end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Ostaja pedi
Citizen.CreateThread(function()
    for _,ostaja in pairs(ostaja) do
        RequestModel(GetHashKey(ostaja[7]))
        while not HasModelLoaded(GetHashKey(ostaja[7])) do
          Wait(1)
        end
        pedi =  CreatePed(4, ostaja[6],ostaja[1],ostaja[2],ostaja[3], 3374176, false, true)
        SetEntityHeading(pedi, ostaja[5])
        FreezeEntityPosition(pedi, true)
        SetEntityInvincible(pedi, true)
        SetBlockingOfNonTemporaryEvents(pedi, true)
    end
end)



function DrawText3Ds(x,y,z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function GetPed() return GetPlayerPed(-1) end

function text(x,y,scale,text)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(255,255,255,255)
    SetTextDropShadow(0,0,0,0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
	DrawText(x, y)
end

function FishGUI(bool)
	if not bool then return end
	DrawRect(PosX,PosY+0.005,TimerAnimation,0.005,255,255,0,255)
	DrawRect(PosX,PosY,0.1,0.01,0,0,0,255)
	TimerAnimation = TimerAnimation - 0.0001005
	if BarAnimation >= SuccessLimit then
		DrawRect(PosX,PosY,BarAnimation,0.01,102,255,102,150)
	else
		DrawRect(PosX,PosY,BarAnimation,0.01,255,51,51,150)
	end
	if BarAnimation <= 0 then
		up = true
	end
	if BarAnimation >= PosY then
		up = false
	end
	if not up then
		BarAnimation = BarAnimation - AnimationSpeed
	else
		BarAnimation = BarAnimation + AnimationSpeed
	end
	text(0.44,0.05,0.30, "Paina ~b~[E]~w~ kun viiva on vihreä")
end

function PlayAnim(ped,base,sub,nr,time) 
	Citizen.CreateThread(function() 
		RequestAnimDict(base) 
		while not HasAnimDictLoaded(base) do 
			Citizen.Wait(1) 
		end
		if IsEntityPlayingAnim(ped, base, sub, 3) then
			ClearPedSecondaryTask(ped) 
		else 
			for i = 1,nr do 
				TaskPlayAnim(ped, base, sub, 8.0, -8, -1, 16, 0, 0, 0, 0) 
				Citizen.Wait(time) 
			end 
		end 
	end) 
end

function AttachEntityToPed(prop,bone_ID,x,y,z,RotX,RotY,RotZ)
	BoneID = GetPedBoneIndex(GetPed(), bone_ID)
	obj = CreateObject(GetHashKey(prop),  1729.73,  6403.90,  34.56,  true,  true,  true)
	vX,vY,vZ = table.unpack(GetEntityCoords(GetPed()))
	xRot, yRot, zRot = table.unpack(GetEntityRotation(GetPed(),2))
	AttachEntityToEntity(obj,  GetPed(),  BoneID, x,y,z, RotX,RotY,RotZ,  false, false, false, false, 2, true)
	return obj
end

RegisterNetEvent('esx_fishing:startFishing')
AddEventHandler('esx_fishing:startFishing', function()
    if not IsPedInAnyVehicle(GetPed(), false) then
        if not IsPedSwimming(GetPed()) then
            if IsEntityInWater(GetPed()) then
                if ESX.UI.Menu.IsOpen('default', 'extendedmode', 'inventory') then
                    ESX.UI.Menu.Close('default', 'extendedmode', 'inventory')
                end

                if ESX.UI.Menu.IsOpen('default', 'extendedmode', 'inventory_item') then
                    ESX.UI.Menu.Close('default', 'extendedmode', 'inventory_item')
                end

                IsFishing = true
                if ShowChatMSG then ESX.ShowNotification("Aloitit kalastuksen odota...") end
                RunCodeOnly1Time = true

            else
                ESX.ShowNotification('Jotta voit kalastaa, jalkojesi täytyy olla vedessä')
            end
        else
            ESX.ShowNotification('Et voi kalastaa tässä.')
        end
    else
        ESX.ShowNotification('Et voi kalastaa tässä.')
    end
end)


Citizen.CreateThread(function()
    while true do
       Citizen.Wait(1)
    
       while IsFishing do
          local time = 4*3000
          exports['progressBars']:startUI(time, "kalastaa")
          TaskStandStill(GetPed(), time+7000)
          FishRod = AttachEntityToPed('prop_fishing_rod_01',60309, 0,0,0, 0,0,0)
          PlayAnim(GetPed(),'amb@world_human_stand_fishing@base','base',4,3000)
          Citizen.Wait(time)
          CFish = true
          IsFishing = false
          StopAnimTask(GetPed(), 'amb@world_human_stand_fishing@idle_a','idle_c',2.0)
       end
    
       while CFish do
          Citizen.Wait(1)
          PlayAnim(GetPed(),'amb@world_human_stand_fishing@idle_a','idle_c',1,0) -- 10sec
          local finished = exports["taskbarskill"]:taskBar(3700, 1)
          if finished == 100 then
             CFish = false
             TimerAnimation = 0.1
             if ShowChatMSG then ESX.ShowNotification("Katso mitä löysit merestä ") end
             Citizen.Wait(200)
             DeleteEntity(FishRod)
             if math.random(100) == 1 then
                if ShowChatMSG then ESX.ShowNotification("Siima katkesi, tarvitset uuden ongen!") end
                TriggerServerEvent('esx_fishing:removeInventoryItem', 'fishingrod', 1)
             end
    
          else
             CFish = false
             TimerAnimation = 0.1
             StopAnimTask(GetPed(), 'amb@world_human_stand_fishing@idle_a','idle_c',2.0)
             Citizen.Wait(200)
             DeleteEntity(FishRod)
             if ShowChatMSG then ESX.ShowNotification("~r~Kokeile uudestaan!") end
          end
       end
    end
end)

Citizen["CreateThread"](function()
    local ostaja = Config.ostaja
    while true do
        Citizen.Wait(5)
        local SleepThread = 200
        local playerped = PlayerPedId()
        local pedposition = GetEntityCoords(playerped)
        local distance = #(ostaja - pedposition)
        if distance < 0.5 then
            SleepThread = 5
            DrawText3Ds(741.56347, 4170.3227, 41.087856, '[E] Myydäksesi kaloja')
            if IsControlJustReleased(0, 38) then
                TriggerEvent('esx_s_kalastus:AvaaMyynti')
            end
        end
    end
end)

AddEventHandler('esx_s_kalastus:AvaaMyynti', function()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen = true

	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.Kalastus[v.name]

		if price and v.count > 0 then
			table.insert(elements, {
				label = ('%s - <span style="color:green;">%s</span>'):format(v.label, "$" .. ESX.Math.GroupDigits(price)),
				name = v.name,
				price = price,
				type = 'slider',
				value = 1,
				min = 1,
				max = v.count
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'esx_s_kalastus', {
		title    = "",
		align    = Config.MenuAlign,
		elements = elements
	}, function(data, menu)
		TriggerServerEvent('esx_s_kalastus:SellItem', data.current.name, data.current.value)
	end, function(data, menu)
		menu.close()
		menuOpen = false
    end)
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(741.56347, 4170.3227, 41.087856)
    SetBlipSprite(blip, 780)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Kalatarikkeiden ostaja")
    EndTextCommandSetBlipName(blip)
  end)