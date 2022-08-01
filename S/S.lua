ESX = nil

local logit = "https://discordapp.com/api/webhooks/1003447093307912282/n8iYxo9EQ2DZ3QfDe3AzLhmcnyPv4vQpQMpTt6ObpjkUmPUd6LyiRAUmD1QIdzE10p4B"

Itemit = {
    "lfish"
}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_fishing:caughtFish')
AddEventHandler('esx_fishing:caughtFish', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item(), newCount())
end)

function item()
    return Itemit[math.random(#Itemit)]
  end

function newCount()
    return math.random(1,2)
end

--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Aseiden saaminen järvestä ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
RegisterServerEvent("esx_fishing:caughtFish")
AddEventHandler("esx_fishing:caughtFish", function()
    local player = ESX.GetPlayerFromId(source)
    local nimi = GetPlayerName(source)


    math.randomseed(os.time())
    local tuuri = math.random(0, 3500)

    if tuuri >= 0 and tuuri <= 15 then
        player.addWeapon("weapon_pistol", 50)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Löysit Huonokuntoisen Pistoolin 1x', style = { ['background-color'] = '#474747', ['color'] = '#ffffff' } })
        sendToDiscord("Aseita", "Pelaaja" ..nimi.. " Löysi Huonokuntoisen Pistoolin 1x", 16753920)
    elseif tuuri >= 0 and tuuri <= 5 then
        player.addWeapon("weapon_revolver", 50)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Löysit Huonokuntoisen Revolverin 1x', style = { ['background-color'] = '#474747', ['color'] = '#ffffff' } })
        sendToDiscord("Aseita", "Pelaaja" ..nimi.. " Löysi Huonokuntoisen Revolverin 1x", 16753920)
    end
end)

RegisterServerEvent("esx_fishing:caughtFish")
AddEventHandler("esx_fishing:caughtFish", function()
    local player = ESX.GetPlayerFromId(source)
    local nimi = GetPlayerName(source)

    math.randomseed(os.time())
    local tuuri = math.random(0, 3050)

    if tuuri >= 0 and tuuri <= 35 then
        player.addWeapon("weapon_knife", 1)
        TriggerClientEvent("esx:showNotification", source, ("~g~Löysit: ~b~Ruosteisen puukon"))
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Löysit Ruosteisen puukon 1x', style = { ['background-color'] = '#474747', ['color'] = '#ffffff' } })
        sendToDiscord("Aseita", "Pelaaja" ..nimi.. " Löysi ruosteisen puukon 1x", 16753920)
    end
end)

RegisterServerEvent("esx_fishing:caughtFish")
AddEventHandler("esx_fishing:caughtFish", function()
    local player = ESX.GetPlayerFromId(source)
    local nimi = GetPlayerName(source)


    math.randomseed(os.time())
    local tuuri = math.random(1, 1)

    if tuuri >= 1 and tuuri <= 1 then
        player.addWeapon("weapon_bat", 1)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Löysit Märän pesäpallomailan 1x', style = { ['background-color'] = '#474747', ['color'] = '#ffffff' } })
        sendToDiscord("Aseita", "Pelaaja " ..nimi.. " Löysi pesäpalomailan 1x", 16753920)
    end
end)
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Aseiden saaminen järvestä "YLHÄÄLLÄ" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    TriggerClientEvent('esx_fishing:getItemAmount', function(amount)
    TriggerEvent('esx_fishing:startFishing', amount)
end)

ESX.RegisterUsableItem('fishingrod', function(source)
	local xPlayer  = ESX.GetPlayerFromId(source)
	local pienisyotti = xPlayer.getInventoryItem('lbait')
	if pienisyotti.count == 1 or pienisyotti.count > 1 then
		TriggerClientEvent('esx_fishing:startFishing', source)
		xPlayer.removeInventoryItem("lbait", 1)
	  else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Sinä et löydä taskuista syöttejä tajuat "ei vittu mähän unohdin ne"', style = { ['background-color'] = '#474747', ['color'] = '#ffffff' } })
	end
end)

RegisterServerEvent("esx_s_kalastus:SellItem")
AddEventHandler("esx_s_kalastus:SellItem", function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.Kalastus[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)
    local nimi = GetPlayerName(source)


	if not price then
		print(('esx_s_kalastus: %s yritti myydä kelpaamattoman tuotteen!'):format(xPlayer.identifier))
		return
	end

	if xItem.count < amount then
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'sinulla ei ole tarpeeksi kyseistä tavaraa.' })
		return
	end

	price = ESX.Math.Round(price * amount)

	if Config.GiveBlack then
		xPlayer.addAccountMoney('black_money', price)
	else
		xPlayer.addMoney(price)
	end

	xPlayer.removeInventoryItem(xItem.name, amount)
    sendToDiscord("Myynti", "Pelaaja " ..nimi.. " Myi "..amount.. " "..xItem.label.." hintaan $"..ESX.Math.GroupDigits(price), 16753920)
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'Myit '..amount.." "..xItem.label.." hintaan $"..ESX.Math.GroupDigits(price) })
end)

RegisterServerEvent('esx_fishing:removeInventoryItem')
AddEventHandler('esx_fishing:removeInventoryItem', function(item, quantity)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(item, quantity)
end)

function sendToDiscord(name, message, color)
    local connect = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = "**```".. message.."```**",
              ["footer"] = {
                  ["text"] = "Kalastus - logit",
              },
          }
      }
    PerformHttpRequest(logit, function(err, text, headers) end, 'POST', json.encode({username = "esx_s_kalastus", embeds = connect, avatar_url = ''}), { ['Content-Type'] = 'application/json' })
end
