RegisterServerEvent("labn_payments:server:sendBill")
AddEventHandler("labn_payments:server:sendBill", function(playerId, label, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	amount = ESX.Math.Round(amount)
	if amount > 0 and xTarget then
		MySQL.insert("INSERT INTO labn_payments (identifier, label, amount, status, type) VALUES (?, ?, ?, ?, ?)", {xTarget.identifier, label, amount, "unpaid", "multa"}, function(rowsChanged)
			TriggerClientEvent("ox_lib:notify", xTarget.source, {description = "You received a fine", type = "inform"})
		end)
	end
end)

RegisterServerEvent("labn_payments:server:sendInvoice")
AddEventHandler("labn_payments:server:sendInvoice", function(playerId, label, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	amount = ESX.Math.Round(amount)
	if amount > 0 and xTarget then
		MySQL.insert("INSERT INTO labn_payments (identifier, label, amount, status, type) VALUES (?, ?, ?, ?, ?)", {xTarget.identifier, label, amount, "unpaid", "fatura"}, function(rowsChanged)
			TriggerClientEvent("ox_lib:notify", xTarget.source, {description = "You received an Invoice", type = "inform"})
		end)
	end
end)

ESX.RegisterServerCallback("labn_payments:server:getBills", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.query("SELECT amount, id, status, type, label FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'multa'", {xPlayer.identifier}, function(result)
		cb(result)
	end)
end)

ESX.RegisterServerCallback("labn_payments:server:getInvoices", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.query("SELECT amount, id, status, type, label FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'fatura'", {xPlayer.identifier}, function(result)
		cb(result)
	end)
end)