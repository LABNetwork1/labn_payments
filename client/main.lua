RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent("esx:onPlayerLogout")
AddEventHandler("esx:onPlayerLogout", function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

local isDead = false

RegisterNetEvent("labn_payments:client:showMenuPayments", function()
    if ESX.PlayerLoaded and not isDead then
        local jobName = ""
        local isAllowed = false
        local isAllowed1 = false
        for k, v in pairs(Config.SocietyEmergencys) do
            if v == ESX.PlayerData.job.name then
                jobName = v
                isAllowed = true
            end
        end
        for k, v in pairs(Config.SocietyBarsAndRestaurants) do
            if v == ESX.PlayerData.job.name then
                jobName = v
                isAllowed1 = true
            end
        end
        local elements = {}
        table.insert(elements, {
            title = "📄 Invoices",
            description = "View My Unpaid Invoices",
            event = "labn_payments:client:ShowInvoicesMenu"
        })
        table.insert(elements, {
            title = "📑 Fines",
            description = "View My Unpaid Fines",
            event = "labn_payments:client:ShowFinesMenu"
        })
        if Config.SocietyEmergencys and isAllowed then
            table.insert(elements, {
                title = "📑 Create Fine",
                description = "Create Fine to the Nearest Civilian",
                event = "labn_payments:client:CreateFine"
            })
            table.insert(elements, {
                title = "📑 Check Fines",
                description = "Check Fines from the Nearest Civilian",
            })
        elseif Config.SocietyBarsAndRestaurants and isAllowed1 then
            table.insert(elements, {
                title = "📄 Create Invoice",
                description = "Create Invoice to Nearest Civilian",
                event = "labn_payments:client:CreateInvoice"
            })
            table.insert(elements, {
                title = "📄 Check Invoices",
                description = "Check Invoices from the nearest Civilian",
            })
        end
        lib.registerContext({id = "show_payments_menu", title = "📑 Menu (Invoices / Fines)", options = elements})
        lib.showContext("show_payments_menu")
    end
end)

RegisterNetEvent("labn_payments:client:ShowInvoicesMenu", function()
    if ESX.PlayerLoaded and not isDead then
        ESX.TriggerServerCallback("labn_payments:server:getInvoices", function(invoices)
            if #invoices > 0 then
                ESX.UI.Menu.CloseAll()
                local elements = {}
                for k, v in ipairs(invoices) do
                    table.insert(elements, {
                        title = ""..v.label.."",
                        description = "Invoice Amount: $"..ESX.Math.GroupDigits(v.amount).."",
                        event = "labn_payments:client:payInvoices",
                        args = {invoiceId = v.id}
                    })
                end
                lib.registerContext({id = "show_invoices_menu", title = "Unpaid Invoices", menu = "show_payments_menu", options = elements})
                lib.showContext("show_invoices_menu")
            else
                lib.notify({description = "You Have No Invoice!", type = "inform"})
            end
        end)
    end
end)

RegisterNetEvent("labn_payments:client:CreateInvoice", function()
    if ESX.PlayerLoaded and not isDead then
        local closestPlayer, playerDistance = ESX.Game.GetClosestPlayer()
		target = GetPlayerServerId(closestPlayer)
        if closestPlayer == -1 or playerDistance > 3.0 then
            local input = lib.inputDialog("Criar Fatura", {"Invoice Label", "Invoice Amount"})
            if input then
                local Invoicelabel = input[1]
                local InvoiceAmount = tonumber(input[2])
                TriggerServerEvent("labn_payments:server:sendInvoice", target, Invoicelabel, InvoiceAmount)
            end
        end
    end
end)

RegisterNetEvent("labn_payments:client:payInvoices", function(data)
    if ESX.PlayerLoaded and not isDead then
        selectedInvoice = data.invoiceId
        local alert = lib.alertDialog({
            header = "Do you really want to pay that invoice?",
            centered = true,
            cancel = true
        })
        if alert == "confirm" then
            ESX.TriggerServerCallback("labn_payments:server:payInvoice", function()
                TriggerEvent("labn_payments:client:ShowInvoicesMenu")
            end, selectedInvoice)
        end
    end
end)

RegisterNetEvent("labn_payments:client:ShowFinesMenu", function()
    if ESX.PlayerLoaded and not isDead then
        ESX.TriggerServerCallback("labn_payments:server:getFines", function(fines)
            if #fines > 0 then
                ESX.UI.Menu.CloseAll()
                local elements = {}
                for k, v in ipairs(fines) do
                    table.insert(elements, {
                        title = ""..v.label.."",
                        description = "Fine Amount: $"..ESX.Math.GroupDigits(v.amount).."",
                        event = "labn_payments:client:payFines",
                        args = {fineId = v.id}
                    })
                end
                lib.registerContext({id = "show_fines_menu", title = "Unpaid Fines", menu = "show_payments_menu", options = elements})
                lib.showContext("show_fines_menu")
            else
                lib.notify({description = "You Have No Fines!", type = "inform"})
            end
        end)
    end
end)

RegisterNetEvent("labn_payments:client:CreateFine", function()
    if ESX.PlayerLoaded and not isDead then
        local closestPlayer, playerDistance = ESX.Game.GetClosestPlayer()
		target = GetPlayerServerId(closestPlayer)
        if closestPlayer == -1 or playerDistance > 3.0 then
            local input = lib.inputDialog("Criar Multa", {"Fine Label", "Fine Amount"})
            if input then
                local labelFine = input[1]
                local amountFine = tonumber(input[2])
                TriggerServerEvent("labn_payments:server:sendFine", target, labelFine, amountFine)
            end
        end
    end
end)

RegisterNetEvent("labn_payments:client:payFines", function(data)
    if ESX.PlayerLoaded and not isDead then
        selectedFine = data.fineId
        local alert = lib.alertDialog({
            header = "Do you really want to pay that fine?",
            centered = true,
            cancel = true
        })
        if alert == "confirm" then
            ESX.TriggerServerCallback("labn_payments:server:payFine", function()
                TriggerEvent("labn_payments:client:ShowFinesMenu")
            end, selectedFine)
        end
    end
end)

AddEventHandler("esx:onPlayerDeath", function()
    isDead = true
end)

AddEventHandler("esx:onPlayerSpawn", function(spawn)
    isDead = false
end)

RegisterCommand("showMenuPayments", function()
	if ESX.PlayerLoaded and not isDead then
        TriggerEvent("labn_payments:client:showMenuPayments")
	end
end)

RegisterKeyMapping("showMenuPayments", "Show Menu (Invoices / Fines)", "keyboard", "F7")