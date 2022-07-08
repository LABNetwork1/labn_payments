RegisterServerEvent("labn_payments:server:sendFine")
AddEventHandler("labn_payments:server:sendFine", function(playerId, label, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	if xTarget then
		MySQL.insert("INSERT INTO labn_payments (identifier, label, amount, status, type) VALUES (?, ?, ?, ?, ?)", {xTarget.identifier, label, amount, "unpaid", "multa"}, function(rowsChanged)
			TriggerClientEvent("ox_lib:notify", xTarget.source, {description = "You received a fine", type = "inform"})
		end)
	end
end)

RegisterServerEvent("labn_payments:server:sendInvoice")
AddEventHandler("labn_payments:server:sendInvoice", function(playerId, label, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	if xTarget then
		MySQL.insert("INSERT INTO labn_payments (identifier, label, amount, status, type) VALUES (?, ?, ?, ?, ?)", {xTarget.identifier, label, amount, "unpaid", "fatura"}, function(rowsChanged)
			TriggerClientEvent("ox_lib:notify", xTarget.source, {description = "You received an Invoice", type = "inform"})
		end)
	end
end)

ESX.RegisterServerCallback("labn_payments:server:getFines", function(source, cb)
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

ESX.RegisterServerCallback("labn_payments:server:getTargetFines", function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		MySQL.query("SELECT amount, id, status, type, label FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'multa'", {xPlayer.identifier}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

ESX.RegisterServerCallback("labn_payments:server:getTargetInvoices", function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		MySQL.query("SELECT amount, id, status, type, label FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'fatura'", {xPlayer.identifier}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

ESX.RegisterServerCallback("labn_payments:server:payFine", function(source, cb, fineId)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.single("SELECT amount FROM labn_payments WHERE id = ?", {fineId}, function(result)
		if result then
			local amount = result.amount
			if xPlayer.getMoney() >= amount then
				MySQL.update("UPDATE labn_payments SET status = ? WHERE id = ?", {"paid", fineId}, function(affectedRows)
					xPlayer.removeMoney(amount)
					TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Pagas-te a Multa no Valor de $"..ESX.Math.GroupDigits(amount).."", type = "success"})
					cb()
				end)
			elseif xPlayer.getAccount("bank").money >= amount then
				MySQL.update("UPDATE labn_payments SET status = ? WHERE id = ?", {"paid", fineId}, function(affectedRows)
					xPlayer.removeAccountMoney("bank", amount)
					TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Pagas-te a Multa no Valor de $"..ESX.Math.GroupDigits(amount).."", type = "success"})
					cb()
				end)
			else
				TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Não possuis Dinheiro Suficiente", type = "error"})
				cb()
			end
		end
	end)
end)

ESX.RegisterServerCallback("labn_payments:server:payInvoice", function(source, cb, invoiceId)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.single("SELECT amount FROM labn_payments WHERE id = ?", {invoiceId}, function(result)
		if result then
			local amount = result.amount
			if xPlayer.getMoney() >= amount then
				MySQL.update("UPDATE labn_payments SET status = ? WHERE id = ?", {"paid", invoiceId}, function(affectedRows)
					xPlayer.removeMoney(amount)
					TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Pagas-te a Fatura no Valor de $"..ESX.Math.GroupDigits(amount).."", type = "success"})
					cb()
				end)
			elseif xPlayer.getAccount("bank").money >= amount then
				MySQL.update("UPDATE labn_payments SET status = ? WHERE id = ?", {"paid", invoiceId}, function(affectedRows)
					xPlayer.removeAccountMoney("bank", amount)
					TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Pagas-te a Fatura no Valor de $"..ESX.Math.GroupDigits(amount).."", type = "success"})
					cb()
				end)
			else
				TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Não possuis Dinheiro Suficiente", type = "error"})
				cb()
			end
		end
	end)
end)