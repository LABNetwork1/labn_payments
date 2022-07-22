RegisterServerEvent("labn_payments:server:sendFine")
AddEventHandler("labn_payments:server:sendFine", function(playerId, label, amount, society)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	if xTarget then
		TriggerEvent("esx_addonaccount:getSharedAccount", society, function(account)
			if account then
				MySQL.insert("INSERT INTO labn_payments (type, identifier, sender, label, amount, send_date, status, society) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {"fine", xTarget.identifier, xPlayer.identifier, label, amount, os.date("%m-%m-%Y %H:%M:%S"), "unpaid", society}, function(rowsChanged)
					TriggerClientEvent("ox_lib:notify", xTarget.playerId, {description = "You received a fine", type = "inform"})
				end)
			end
		end)
	end
end)

RegisterServerEvent("labn_payments:server:sendInvoice")
AddEventHandler("labn_payments:server:sendInvoice", function(playerId, label, amount, society)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	if xTarget then
		TriggerEvent("esx_addonaccount:getSharedAccount", society, function(account)
			if account then
				MySQL.insert("INSERT INTO labn_payments (type, identifier, sender, label, amount, send_date, status, society) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {"fine", xTarget.identifier, xPlayer.identifier, label, amount, os.date("%m-%m-%Y %H:%M:%S"), "unpaid", society}, function(rowsChanged)
					TriggerClientEvent("ox_lib:notify", xTarget.playerId, {description = "You received an Invoice", type = "inform"})
				end)
			end
		end)
	end
end)

ESX.RegisterServerCallback("labn_payments:server:getFines", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'fine'", {xPlayer.identifier}, function(result)
		cb(result)
	end)
end)

ESX.RegisterServerCallback("labn_payments:server:getInvoices", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'invoice'", {xPlayer.identifier}, function(result)
		cb(result)
	end)
end)

ESX.RegisterServerCallback("labn_payments:server:getFinesPaid", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'paid' AND type = 'fine'", {xPlayer.identifier}, function(result)
		cb(result)
	end)
end)

ESX.RegisterServerCallback("labn_payments:server:getInvoicesPaid", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'paid' AND type = 'invoice'", {xPlayer.identifier}, function(result)
		cb(result)
	end)
end)

ESX.RegisterServerCallback("labn_payments:server:getTargetFines", function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'fine'", {xPlayer.identifier}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

ESX.RegisterServerCallback("labn_payments:server:getTargetInvoices", function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'invoice'", {xPlayer.identifier}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

ESX.RegisterServerCallback("labn_payments:server:getTargetFinesPaid", function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'paid' AND type = 'fine'", {xPlayer.identifier}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

ESX.RegisterServerCallback("labn_payments:server:getTargetInvoicesPaid", function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'paid' AND type = 'invoice'", {xPlayer.identifier}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

ESX.RegisterServerCallback("labn_payments:server:payFine", function(source, cb, fineId)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.single("SELECT * FROM labn_payments WHERE id = ?", {fineId}, function(result)
		if result then
			local amount = result.amount
			local society = result.society
			TriggerEvent("esx_addonaccount:getSharedAccount", society, function(account)
				if xPlayer.getMoney() >= amount then
					MySQL.update("UPDATE labn_payments SET status = ?, paid_date = ? WHERE id = ?", {"paid", os.date("%m-%m-%Y %H:%M:%S"), fineId}, function(affectedRows)
						xPlayer.removeMoney(amount)
						account.addMoney(amount)
						TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Pagas-te a fine no Valor de $"..ESX.Math.GroupDigits(amount).."", type = "success"})
						cb()
					end)
				elseif xPlayer.getAccount("bank").money >= amount then
					MySQL.update("UPDATE labn_payments SET status = ?, paid_date = ? WHERE id = ?", {"paid", os.date("%m-%m-%Y %H:%M:%S"), fineId}, function(affectedRows)
						xPlayer.removeAccountMoney("bank", amount)
						account.addMoney(amount)
						TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Pagas-te a fine no Valor de $"..ESX.Math.GroupDigits(amount).."", type = "success"})
						cb()
					end)
				else
					TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Não possuis Dinheiro Suficiente", type = "error"})
					cb()
				end
			end)
		end
	end)
end)

ESX.RegisterServerCallback("labn_payments:server:payInvoice", function(source, cb, invoiceId)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.single("SELECT * FROM labn_payments WHERE id = ?", {invoiceId}, function(result)
		if result then
			local amount = result.amount
			local society = result.society
			TriggerEvent("esx_addonaccount:getSharedAccount", society, function(account)
				if xPlayer.getMoney() >= amount then
					MySQL.update("UPDATE labn_payments SET status = ?, paid_date = ? WHERE id = ?", {"paid", os.date("%m-%m-%Y %H:%M:%S"), invoiceId}, function(affectedRows)
						xPlayer.removeMoney(amount)
						account.addMoney(amount)
						TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Pagas-te a invoice no Valor de $"..ESX.Math.GroupDigits(amount).."", type = "success"})
						cb()
					end)
				elseif xPlayer.getAccount("bank").money >= amount then
					MySQL.update("UPDATE labn_payments SET status = ?, paid_date = ? WHERE id = ?", {"paid", os.date("%m-%m-%Y %H:%M:%S"), invoiceId}, function(affectedRows)
						xPlayer.removeAccountMoney("bank", amount)
						account.addMoney(amount)
						TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Pagas-te a invoice no Valor de $"..ESX.Math.GroupDigits(amount).."", type = "success"})
						cb()
					end)
				else
					TriggerClientEvent("ox_lib:notify", xPlayer.source, {description = "Tu Não possuis Dinheiro Suficiente", type = "error"})
					cb()
				end
			end)
		end
	end)
end)
