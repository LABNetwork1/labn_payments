local QBCore = exports["qb-core"]:GetCoreObject()

RegisterServerEvent("labn_payments:server:sendFine")
AddEventHandler("labn_payments:server:sendFine", function(playerId, label, amount, society)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local xTarget = QBCore.Functions.GetPlayer(playerId)
	if xTarget then
		MySQL.insert("INSERT INTO labn_payments (type, identifier, sender, label, amount, send_date, status, society) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {"fine", xTarget.PlayerData.citizenid, xPlayer.PlayerData.citizenid, label, amount, os.date("%m-%m-%Y %H:%M:%S"), "unpaid", society}, function(rowsChanged)
			TriggerClientEvent("ox_lib:notify", xTarget.source, {description = "You received a fine", type = "inform"})
		end)
	end
end)

RegisterServerEvent("labn_payments:server:sendInvoice")
AddEventHandler("labn_payments:server:sendInvoice", function(playerId, label, amount, society)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local xTarget = QBCore.Functions.GetPlayer(playerId)
	if xTarget then
		MySQL.insert("INSERT INTO labn_payments (type, identifier, sender, label, amount, send_date, status, society) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {"fine", xTarget.PlayerData.citizenid, xPlayer.PlayerData.citizenid, label, amount, os.date("%m-%m-%Y %H:%M:%S"), "unpaid", society}, function(rowsChanged)
			TriggerClientEvent("ox_lib:notify", xTarget.source, {description = "You received an Invoice", type = "inform"})
		end)
	end
end)

QBCore.Functions.CreateCallback("labn_payments:server:getFines", function(source, cb)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'fine'", {xPlayer.PlayerData.citizenid}, function(result)
		cb(result)
	end)
end)

QBCore.Functions.CreateCallback("labn_payments:server:getInvoices", function(source, cb)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'invoice'", {xPlayer.PlayerData.citizenid}, function(result)
		cb(result)
	end)
end)

QBCore.Functions.CreateCallback("labn_payments:server:getFinesPaid", function(source, cb)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'paid' AND type = 'fine'", {xPlayer.PlayerData.citizenid}, function(result)
		cb(result)
	end)
end)

QBCore.Functions.CreateCallback("labn_payments:server:getInvoicesPaid", function(source, cb)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'paid' AND type = 'invoice'", {xPlayer.PlayerData.citizenid}, function(result)
		cb(result)
	end)
end)

QBCore.Functions.CreateCallback("labn_payments:server:getTargetFines", function(source, cb, target)
	local xPlayer = QBCore.Functions.GetPlayer(target)
	if xPlayer then
		MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'fine'", {xPlayer.PlayerData.citizenid}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

QBCore.Functions.CreateCallback("labn_payments:server:getTargetInvoices", function(source, cb, target)
	local xPlayer = QBCore.Functions.GetPlayer(target)
	if xPlayer then
		MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'unpaid' AND type = 'invoice'", {xPlayer.PlayerData.citizenid}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

QBCore.Functions.CreateCallback("labn_payments:server:getTargetFinesPaid", function(source, cb, target)
	local xPlayer = QBCore.Functions.GetPlayer(target)
	if xPlayer then
		MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'paid' AND type = 'fine'", {xPlayer.PlayerData.citizenid}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

QBCore.Functions.CreateCallback("labn_payments:server:getTargetInvoicesPaid", function(source, cb, target)
	local xPlayer = QBCore.Functions.GetPlayer(target)
	if xPlayer then
		MySQL.query("SELECT * FROM labn_payments WHERE identifier = ? AND status = 'paid' AND type = 'invoice'", {xPlayer.PlayerData.citizenid}, function(result)
			cb(result)
		end)
	else
		cb({})
	end
end)

QBCore.Functions.CreateCallback("labn_payments:server:payFine", function(source, cb, fineId)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	MySQL.single("SELECT * FROM labn_payments WHERE id = ?", {fineId}, function(result)
		if result then
			local amount = result.amount
			local society = result.society
			if xPlayer.PlayerData.money["cash"] >= amount then
				MySQL.update("UPDATE labn_payments SET status = ?, paid_date = ? WHERE id = ?", {"paid", os.date("%m-%m-%Y %H:%M:%S"), fineId}, function(affectedRows)
					xPlayer.Functions.RemoveMoney("cash", amount)
					exports["qb-management"]:AddMoney(society, amount)
					TriggerClientEvent("ox_lib:notify", source, {description = "Tu Pagas-te a fine no Valor de $"..amount.."", type = "success"})
					cb()
				end)
			elseif xPlayer.PlayerData.money["bank"] >= amount then
				MySQL.update("UPDATE labn_payments SET status = ?, paid_date = ? WHERE id = ?", {"paid", os.date("%m-%m-%Y %H:%M:%S"), fineId}, function(affectedRows)
					xPlayer.Functions.RemoveMoney("bank", amount)
					exports["qb-management"]:AddMoney(society, amount)
					TriggerClientEvent("ox_lib:notify", source, {description = "Tu Pagas-te a fine no Valor de $"..amount.."", type = "success"})
					cb()
				end)
			else
				TriggerClientEvent("ox_lib:notify", source, {description = "Tu Não possuis Dinheiro Suficiente", type = "error"})
				cb()
			end
		end
	end)
end)

QBCore.Functions.CreateCallback("labn_payments:server:payInvoice", function(source, cb, invoiceId)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	MySQL.single("SELECT * FROM labn_payments WHERE id = ?", {invoiceId}, function(result)
		if result then
			local amount = result.amount
			local society = result.society
			if xPlayer.PlayerData.money["cash"] >= amount then
				MySQL.update("UPDATE labn_payments SET status = ?, paid_date = ? WHERE id = ?", {"paid", os.date("%m-%m-%Y %H:%M:%S"), invoiceId}, function(affectedRows)
					xPlayer.Functions.RemoveMoney("cash", amount)
					exports["qb-management"]:AddMoney(society, amount)
					TriggerClientEvent("ox_lib:notify", source, {description = "Tu Pagas-te a invoice no Valor de $"..amount.."", type = "success"})
					cb()
				end)
			elseif xPlayer.PlayerData.money["bank"] >= amount then
				MySQL.update("UPDATE labn_payments SET status = ?, paid_date = ? WHERE id = ?", {"paid", os.date("%m-%m-%Y %H:%M:%S"), invoiceId}, function(affectedRows)
					xPlayer.Functions.RemoveMoney("bank", amount)
					exports["qb-management"]:AddMoney(society, amount)
					TriggerClientEvent("ox_lib:notify", source, {description = "Tu Pagas-te a invoice no Valor de $"..amount.."", type = "success"})
					cb()
				end)
			else
				TriggerClientEvent("ox_lib:notify", source, {description = "Tu Não possuis Dinheiro Suficiente", type = "error"})
				cb()
			end
		end
	end)
end)