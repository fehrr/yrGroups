local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
local config = module(GetCurrentResourceName(), "config") --GetCurrentResourceName()
local vRP = Proxy.getInterface("vRP")
local vRPC = Tunnel.getInterface("vRP")
--

local yraks = "false"
--
vRP.prepare("yrGroups/getBank", "SELECT bank FROM yrgroups_bank WHERE org = @org")
vRP.prepare("yrGroups/setBank", "UPDATE yrgroups_bank SET bank = @newBank WHERE org = @org")
vRP.prepare("yrGroups/getSets", "SELECT * FROM yrgroups_set WHERE org = @org ORDER BY cargo ASC")
vRP.prepare("yrGroups/getSetUser", "SELECT * FROM yrgroups_set WHERE org = @org AND id = @id")
vRP.prepare("yrGroups/setUser", "INSERT INTO yrgroups_set (org, id, cargo) VALUES (@org, @id, @cargo);")
vRP.prepare("yrGroups/delUser", "DELETE FROM yrgroups_set WHERE id = @id")
--

function rgbToHex(r,g,b)
    local rgb = (r * 0x10000) + (g * 0x100) + b
    return string.format("%x", rgb)
end
function SendWebhook(webhook, data)
    PerformHttpRequest(webhook, function(a, b, c) end, "POST", json.encode(data), { ["Content-Type"] = "application/json" })
end

RegisterServerEvent("yrGroups:UpdateTablet", function(idd, refresh)
    if yraks == "true" then
        local user_id = idd
        local source = vRP.getUserSource(user_id)
    
        local orga = false
    
        for k,v in pairs(config.orgs) do
            if vRP.hasPermission(user_id, config.orgs[k]["Membro"]) then
                orga = k
                break
            end
        end
    
        
        if orga then
    
            local players = vRP.query("yrGroups/getSets", { org = config.orgs[orga]["Nome"] })
        
            local mbonline = 0
            local mbtotais = 0
            
            local membrosDaFac = {}
            for k,v in pairs(players) do
                local identity = vRP.userIdentity(tonumber(players[k]["id"]))
                mbtotais = mbtotais + 1
                membrosDaFac[k] = {}
                membrosDaFac[k][1] = identity.name.." "..identity.name2
                membrosDaFac[k][2] = players[k]["id"]
                membrosDaFac[k][3] = players[k]["cargo"]
                if vRP.getUserSource(tonumber(players[k]["id"])) then
                    membrosDaFac[k][4] = true
                    mbonline = mbonline + 1
                else
                    membrosDaFac[k][4] = false
                end
            end
            
            local query = vRP.query("yrGroups/getSetUser", { id = user_id, org = config.orgs[orga]["Nome"] })[1]["cargo"]
            local identity = vRP.userIdentity(user_id)
            local bank = vRP.query("yrGroups/getBank", { org = config.orgs[orga]["Nome"] })
    
            if vRP.hasPermission(user_id, config.orgs[orga]["Lider"]) and query == "Lider" then
                local data = { identity.name.." "..identity.name2, config.orgs[orga]["cor"], config.orgs[orga]["Nome"], "Líder", bank[1]["bank"], config.orgs[orga]["imagem"], membrosDaFac, mbonline, mbtotais}
                TriggerClientEvent("yrGroups:"..refresh.."NUIlider", source, json.encode(data))
            else
                if vRP.hasPermission(user_id, config.orgs[orga]["Vice-Lider"]) and query == "Vice-Lider" then
                    local data = { identity.name.." "..identity.name2, config.orgs[orga]["cor"], config.orgs[orga]["Nome"], "Vice-Líder", bank[1]["bank"], config.orgs[orga]["imagem"], membrosDaFac, mbonline, mbtotais}
                    TriggerClientEvent("yrGroups:"..refresh.."NUIlider", source, json.encode(data))
                else
                    if vRP.hasPermission(user_id, config.orgs[orga]["Gerente"]) and query == "Gerente" then
                        local data = { identity.name.." "..identity.name2, config.orgs[orga]["cor"], config.orgs[orga]["Nome"], "Gerente", bank[1]["bank"], config.orgs[orga]["imagem"], membrosDaFac, mbonline, mbtotais}
                        TriggerClientEvent("yrGroups:"..refresh.."NUIgerente", source, json.encode(data))
                    else
                        if vRP.hasPermission(user_id, config.orgs[orga]["Membro"]) and query == "Membro" then
                            local data = { identity.name.." "..identity.name2, config.orgs[orga]["cor"], config.orgs[orga]["Nome"], "Membro", bank[1]["bank"], config.orgs[orga]["imagem"], membrosDaFac, mbonline, mbtotais}
                            TriggerClientEvent("yrGroups:"..refresh.."NUImembro", source, json.encode(data))
                        end
                    end
                end
            end
        end
    end
end)

RegisterCommand(config.addgroup, function(a, b)
    if yraks == "true" then
        local user_id = vRP.getUserId(a)
        
        if vRP.hasPermission(user_id, config.admin) and vRP.getUserSource(b[1]) and b[2] then
            local exists = false
            local orga = true
            for k,v in pairs(config.orgs) do
                if config.orgs[k]["Nome"] == b[2] then
                    exists = true
                    orga = k
                    break
                end
            end
            local hasSet = false
            for k,v in pairs(config.orgs) do
                local query = vRP.query("yrGroups/getSetUser", { id = b[1], org = config.orgs[k]["Nome"] })[1]
                if not query then
                    hasSet = false
                else
                    hasSet = true
                    break
                end
            end
            if exists then
                if hasSet then
                    TriggerClientEvent("Notify", a, "vermelho", "A pessoa já faz parte de um grupo.", 3 * 1000)
                else
                    local identity = vRP.userIdentity(user_id)
                    local nidentity = vRP.userIdentity(b[1])
    
                    vRP.execute("yrGroups/setUser", { id = b[1], org = b[2], cargo = "Lider" })
                    vRP.setPermission(b[1], config.orgs[orga]["Lider"])
                    vRP.setPermission(b[1], config.orgs[orga]["Membro"])
                    
                    TriggerClientEvent("Notify", a, "verde", "Set realizado com sucesso!", 3 * 1000)
                    
                    SendWebhook(config.admWebhook, {
                        embeds = {
                            {
                                author = {
                                    name = "Líder adicionado"
                                },
                                color = config.admColor,
                                fields  = {
                                    {
                                        name = "Administrador",
                                        value = identity.name.." "..identity.name2.." - "..user_id,
                                        inline = false
                                    },
                                    {
                                        name = "Novo Líder",
                                        value = nidentity.name.." "..nidentity.name2.." - "..b[1],
                                        inline = false
                                    },
                                    {
                                        name = "Organização",
                                        value = config.orgs[orga]["Nome"],
                                        inline = false
                                    }
                                },
                                footer = {
                                    text = "Yuri Resouces • "..os.date("*t").day.."/"..os.date("*t").month.."/"..os.date("*t").year.." "..os.date("*t").hour..":"..os.date("*t").min,
                                }
                            }
                        }
                    })
                end
            else
                TriggerClientEvent("Notify", a, "vermelho", "Este grupo não existe.", 3 * 1000)
            end
        else
            TriggerClientEvent("Notify", a, "vermelho", "Morador está fora da cidade.", 3 * 1000)
        end
    end
end)
RegisterCommand(config.remgroup, function(a, b)
    local user_id = vRP.getUserId(a)

    if vRP.hasPermission(user_id, config.admin) and vRP.getUserSource(b[1]) and b[2] then
        local exists = false
        local orga = true
        for k,v in pairs(config.orgs) do
            if config.orgs[k]["Nome"] == b[2] then
                exists = true
                orga = k
                break
            end
        end
        if exists then

            local query = vRP.query("yrGroups/getSetUser", { id = b[1], org = config.orgs[orga]["Nome"] })[1]
            if not query then
                TriggerClientEvent("Notify", a, "vermelho", "A pessoa não faz parte deste grupo.", 3 * 1000)
            else
                local identity = vRP.userIdentity(user_id)
                local nidentity = vRP.userIdentity(b[1])

                vRP.execute("yrGroups/delUser", { id = b[1] })
                vRP.remPermission(b[1], config.orgs[orga]["Lider"])
                vRP.remPermission(b[1], config.orgs[orga]["Membro"])
                
                TriggerClientEvent("Notify", a, "verde", "Retirado set com sucesso!", 3 * 1000)
                
                SendWebhook(config.admWebhook, {
                    embeds = {
                        {
                            author = {
                                name = "Líder removido"
                            },
                            color = config.admColor,
                            fields  = {
                                {
                                    name = "Administrador",
                                    value = identity.name.." "..identity.name2.." - "..user_id,
                                    inline = false
                                },
                                {
                                    name = "Antigo Líder",
                                    value = nidentity.name.." "..nidentity.name2.." - "..b[1],
                                    inline = false
                                },
                                {
                                    name = "Organização",
                                    value = config.orgs[orga]["Nome"],
                                    inline = false
                                },
                            }
                        }
                    }
                })
            end
        else
            TriggerClientEvent("Notify", a, "vermelho", "Este grupo não existe.", 3 * 1000)
        end
    else
        TriggerClientEvent("Notify", a, "vermelho", "Morador está fora da cidade.", 3 * 1000)
    end
end)

RegisterCommand(config.comando, function(a, b)
    local user_id = vRP.getUserId(a)

    TriggerEvent("yrGroups:UpdateTablet", user_id, "")
end)

RegisterServerEvent("yrGroups:Sacar", function(value, orga)
    local source = source
    local user_id = vRP.getUserId(source)
    local banco = vRP.query("yrGroups/getBank", { org = orga })[1]["bank"]
    local bank = tonumber(banco)
    local valu = tonumber(value)

    local org = false

    for k,v in pairs(config.orgs) do
        if vRP.hasPermission(user_id, config.orgs[k]["Membro"]) then
            org = k
            break
        end
    end

    if valu > bank and valu > 0 then
        TriggerClientEvent("Notify", source, "vermelho", "A organização "..orga.." não possui este valor.", 3 * 1000)
    elseif valu <= bank and valu > 0 then
        if vRP.hasPermission(user_id, config.orgs[org]["Lider"]) or vRP.hasPermission(user_id, config.orgs[org]["Vice-Lider"])  or vRP.hasPermission(user_id, config.orgs[org]["Gerente"]) then
            local newBank = bank - valu
            vRP.execute("yrGroups/setBank", { org = orga, newBank = newBank })
            vRP.addBank(user_id, valu, "Private")
            TriggerClientEvent("Notify", source, "verde", "Você sacou "..value.." da organização "..orga..".", 3 * 1000)

            local identity = vRP.userIdentity(user_id)

            SendWebhook(config.orgs[org]["webhook"], {
                embeds = {
                    {
                        author = {
                            name = "Saque Realizado"
                        },
                        color = tonumber(rgbToHex(config.orgs[org]["cor"][1], config.orgs[org]["cor"][2], config.orgs[org]["cor"][3]), 16),
                        fields  = {
                            {
                                name = "Responsável",
                                value = identity.name.." "..identity.name2.." - "..user_id,
                                inline = false
                            },
                            {
                                name = "Valor do Saque",
                                value = valu,
                                inline = false
                            }
                        }
                    }
                }
            })
        end
    else
        TriggerClientEvent("Notify", source, "vermelho", "A organização "..orga.." não possui este valor.", 3 * 1000)
    end
    --
    TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
end)


RegisterServerEvent("yrGroups:Depositar", function(value, orga)
    local source = source
    local user_id = vRP.getUserId(source)
    local bancoOrg = vRP.query("yrGroups/getBank", { org = orga })[1]["bank"]
    local banco = vRP.getBank(user_id)
    local bank = tonumber(banco)
    local valu = tonumber(value)

    local org = false

    for k,v in pairs(config.orgs) do
        if vRP.hasPermission(user_id, config.orgs[k]["Membro"]) then
            org = k
            break
        end
    end

    if valu > bank and valu > 0 then
        TriggerClientEvent("Notify", source, "vermelho", "Você não possui este valor.", 3 * 1000)
    elseif valu <= bank and valu > 0 then
        local newBank = tonumber(bancoOrg) + valu
        vRP.execute("yrGroups/setBank", { org = orga, newBank = newBank })
        vRP.delBank(user_id, valu, "Private")
        TriggerClientEvent("Notify", source, "verde", "Você depositou "..value.." na organização "..orga..".", 3 * 1000)
        
        local identity = vRP.userIdentity(user_id)

        SendWebhook(config.orgs[org]["webhook"], {
            embeds = {
                {
                    author = {
                        name = "Depósito Realizado"
                    },
                    color = tonumber(rgbToHex(config.orgs[org]["cor"][1], config.orgs[org]["cor"][2], config.orgs[org]["cor"][3]), 16),
                    fields  = {
                        {
                            name = "Responsável",
                            value = identity.name.." "..identity.name2.." - "..user_id,
                            inline = false
                        },
                        {
                            name = "Valor do Depósito",
                            value = valu,
                            inline = false
                        }
                    }
                }
            }
        })
    else
        TriggerClientEvent("Notify", source, "vermelho", "Você não possui este valor.", 3 * 1000)
    end
    --
    TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
end)

RegisterServerEvent("yrGroups:Contratar", function(id, org)
    local source = source
    local user_id = vRP.getUserId(source)
    local id = tonumber(id)

    local perm = false
    for k,v in pairs(config.orgs) do
        if vRP.hasPermission(user_id, config.orgs[k]["Lider"]) then
            perm = k
            break
        elseif  vRP.hasPermission(user_id, config.orgs[k]["Vice-Lider"]) then
            perm = k
            break
        end
    end

    local hasSet = false
    for k,v in pairs(config.orgs) do
        local query = vRP.query("yrGroups/getSetUser", { id = id, org = config.orgs[k]["Nome"] })[1]
        if not query then
            hasSet = false
        else
            hasSet = true
            break
        end
    end

    if user_id == id then
        TriggerClientEvent("Notify", source, "vermelho", "Você não pode contratar você mesmo.", 3 * 1000)
        TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
    elseif hasSet then
        TriggerClientEvent("Notify", source, "vermelho", "A pessoa já faz parte de um grupo.", 3 * 1000)
    else
        if perm then
            if vRP.getUserSource(id) then
                local orgg = false
                local sets = vRP.query("yrGroups/getSets", { org = config.orgs[perm]["Nome"] })
                for k,v in pairs(sets) do
                    if sets[k]["id"] == id then
                        orgg = true
                        break
                    end
                end
                if not orgg then
                    if vRP.request(vRP.getUserSource(id), "Você deseja ser contratado para "..org.."?") then
                        local identity = vRP.userIdentity(id)
                        TriggerClientEvent("Notify", source, "verde", "Você contratou "..identity.name.." "..identity.name2.." para "..org..".", 3 * 1000)
                        
                        vRP.execute("yrGroups/setUser", { id = id, org = config.orgs[perm]["Nome"], cargo = "Membro" })
                        vRP.setPermission(id, config.orgs[perm]["Membro"])
                        
                        local uidentity = vRP.userIdentity(user_id)

                        SendWebhook(config.orgs[org]["webhook"], {
                            embeds = {
                                {
                                    author = {
                                        name = "Contratação Realizado"
                                    },
                                    color = tonumber(rgbToHex(config.orgs[org]["cor"][1], config.orgs[org]["cor"][2], config.orgs[org]["cor"][3]), 16),
                                    fields  = {
                                        {
                                            name = "Responsável",
                                            value = uidentity.name.." "..uidentity.name2.." - "..user_id,
                                            inline = false
                                        },
                                        {
                                            name = "Contratado",
                                            value = identity.name.." "..identity.name2.." - "..id,
                                            inline = false
                                        }
                                    }
                                }
                            }
                        })
                    else
                        local identity = vRP.userIdentity(id)
                        TriggerClientEvent("Notify", source, "vermelho", "O passaporte "..id.." recusou seu convite para entrar em sua organização.", 3 * 1000)
                    end
                else
                    TriggerClientEvent("Notify", source, "vermelho", "O passaporte "..id.." já faz parte de uma organização.", 3 * 1000)
                end
            else
                local identity = vRP.userIdentity(id)
                TriggerClientEvent("Notify", source, "vermelho", "O passaporte "..id.." não está na cidade!", 3 * 1000)
            end
        end

        TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
    end
end)

RegisterServerEvent("yrGroups:Demitir", function(id, org)
    local source = source
    local user_id = vRP.getUserId(source)
    local id = tonumber(id)

    local perm = false
    for k,v in pairs(config.orgs) do
        if vRP.hasPermission(user_id, config.orgs[k]["Lider"]) then
            perm = k
            break
        elseif  vRP.hasPermission(user_id, config.orgs[k]["Vice-Lider"]) then
            perm = k
            break
        end
    end

    if user_id == id then
        TriggerClientEvent("Notify", source, "vermelho", "Você não pode demitir você mesmo.", 3 * 1000)
        TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
    elseif vRP.hasPermission(id, config.orgs[perm]["Lider"]) then
        TriggerClientEvent("Notify", source, "vermelho", "Você não pode demitir o líder da organização.", 3 * 1000)
        TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
    else
        if perm then
            if vRP.getUserSource(id) then
                local identity = vRP.userIdentity(id)
                if vRP.request(vRP.getUserSource(user_id), "Você deseja demitir para "..identity.name.." "..identity.name2.." da organização "..org.."?") then
                    TriggerClientEvent("Notify", source, "verde", "Você demitiu "..identity.name.." "..identity.name2.." da organização "..org..".", 3 * 1000)
                    
                    vRP.execute("yrGroups/delUser", { id = id })
                    vRP.remPermission(id, config.orgs[perm]["Vice-Lider"])
                    vRP.remPermission(id, config.orgs[perm]["Gerente"])
                    vRP.remPermission(id, config.orgs[perm]["Membro"])

                    local uidentity = vRP.userIdentity(user_id)

                    SendWebhook(config.orgs[org]["webhook"], {
                        embeds = {
                            {
                                author = {
                                    name = "Demição Realizado"
                                },
                                color = tonumber(rgbToHex(config.orgs[org]["cor"][1], config.orgs[org]["cor"][2], config.orgs[org]["cor"][3]), 16),
                                fields  = {
                                    {
                                        name = "Responsável",
                                        value = uidentity.name.." "..uidentity.name2.." - "..user_id,
                                        inline = false
                                    },
                                    {
                                        name = "Demitido",
                                        value = identity.name.." "..identity.name2.." - "..id,
                                        inline = false
                                    }
                                }
                            }
                        }
                    })
                end
            else
                local identity = vRP.userIdentity(id)
                TriggerClientEvent("Notify", source, "vermelho", "O passaporte "..id.." não está na cidade!", 3 * 1000)
            end
        end
        TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
    end
end)

RegisterServerEvent("yrGroups:Rebaixar", function(id, org)
    local source = source
    local user_id = vRP.getUserId(source)
    local id = tonumber(id)

    local perma = false
    local perm = false
    for k,v in pairs(config.orgs) do
        if vRP.hasPermission(user_id, config.orgs[k]["Lider"]) then
            perma = "Lider"
            perm = k
            break
        elseif  vRP.hasPermission(user_id, config.orgs[k]["Vice-Lider"]) then
            perma = "Vice-Lider"
            perm = k
            break
        end
    end
    
    if perm then
        if vRP.getUserSource(id) then
            local query = vRP.query("yrGroups/getSetUser", { id = id, org = org })[1]
            if id == user_id then
                TriggerClientEvent("Notify", source, "vermelho", "Você não pode rebaixar você mesmo.", 3 * 1000)
                TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
            else
                if query["cargo"] == "Gerente" then
                    if perma == "Lider" or perma == "Vice-Lider" then
                        vRP.execute("yrGroups/delUser", { id = id })
                        vRP.remPermission(id, config.orgs[perm]["Gerente"])

                        vRP.execute("yrGroups/setUser", { id = id, org = config.orgs[perm]["Nome"], cargo = "Membro" })
                        vRP.setPermission(id, config.orgs[perm]["Membro"])
  
                        local identity = vRP.userIdentity(user_id)
                        local nidentity = vRP.userIdentity(id)

                        SendWebhook(config.orgs[org]["webhook"], {
                            embeds = {
                                {
                                    author = {
                                        name = "Rebaixamento Realizado"
                                    },
                                    color = tonumber(rgbToHex(config.orgs[org]["cor"][1], config.orgs[org]["cor"][2], config.orgs[org]["cor"][3]), 16),
                                    fields  = {
                                        {
                                            name = "Responsável",
                                            value = identity.name.." "..identity.name2.." - "..user_id,
                                            inline = false
                                        },
                                        {
                                            name = "Rebaixado",
                                            value = nidentity.name.." "..nidentity.name2.." - "..id,
                                            inline = false
                                        },
                                        {
                                            name = "Cargo Antigo",
                                            value = "Gerente",
                                            inline = false
                                        },
                                        {
                                            name = "Cargo Novo",
                                            value = "Membro",
                                            inline = false
                                        }
                                    }
                                }
                            }
                        })
                    end
                elseif query["cargo"] == "Vice-Lider" then
                    if perma == "Lider" then
                        vRP.execute("yrGroups/delUser", { id = id })
                        vRP.remPermission(id, config.orgs[perm]["Vice-Lider"])

                        vRP.execute("yrGroups/setUser", { id = id, org = config.orgs[perm]["Nome"], cargo = "Gerente" })
                        vRP.setPermission(id, config.orgs[perm]["Gerente"])

                        local identity = vRP.userIdentity(user_id)
                        local nidentity = vRP.userIdentity(id)

                        SendWebhook(config.orgs[org]["webhook"], {
                            embeds = {
                                {
                                    author = {
                                        name = "Rebaixamento Realizado"
                                    },
                                    color = tonumber(rgbToHex(config.orgs[org]["cor"][1], config.orgs[org]["cor"][2], config.orgs[org]["cor"][3]), 16),
                                    fields  = {
                                        {
                                            name = "Responsável",
                                            value = identity.name.." "..identity.name2.." - "..user_id,
                                            inline = false
                                        },
                                        {
                                            name = "Rebaixado",
                                            value = nidentity.name.." "..nidentity.name2.." - "..id,
                                            inline = false
                                        },
                                        {
                                            name = "Cargo Antigo",
                                            value = "Vice Líder",
                                            inline = false
                                        },
                                        {
                                            name = "Cargo Novo",
                                            value = "Gerente",
                                            inline = false
                                        }
                                    }
                                }
                            }
                        })
                    end
                end

                TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
            end
        else
            local identity = vRP.userIdentity(id)
            TriggerClientEvent("Notify", source, "vermelho", "O passaporte "..id.." não está na cidade!", 3 * 1000)
        end
    end
end)

RegisterServerEvent("yrGroups:Promover", function(id, org)
    local source = source
    local user_id = vRP.getUserId(source)
    local id = tonumber(id)

    local perma = false
    local perm = false
    for k,v in pairs(config.orgs) do
        if vRP.hasPermission(user_id, config.orgs[k]["Lider"]) then
            perma = "Lider"
            perm = k
            break
        elseif  vRP.hasPermission(user_id, config.orgs[k]["Vice-Lider"]) then
            perma = "Vice-Lider"
            perm = k
            break
        end
    end

    if perm then
        local query = vRP.query("yrGroups/getSetUser", { id = id, org = org })[1]
        if id == user_id then
            TriggerClientEvent("Notify", source, "vermelho", "Você não pode promover você mesmo.", 3 * 1000)
            TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
        else
            if vRP.getUserSource(id) then
                if query["cargo"] == "Membro" then
                    if perma == "Lider" or perma == "Vice-Lider" then
                        vRP.execute("yrGroups/delUser", { id = id })

                        vRP.execute("yrGroups/setUser", { id = id, org = config.orgs[perm]["Nome"], cargo = "Gerente" })
                        vRP.setPermission(id, config.orgs[perm]["Gerente"])
                        
                        local identity = vRP.userIdentity(user_id)
                        local nidentity = vRP.userIdentity(id)

                        SendWebhook(config.orgs[org]["webhook"], {
                            embeds = {
                                {
                                    author = {
                                        name = "Promoção Realizado"
                                    },
                                    color = tonumber(rgbToHex(config.orgs[org]["cor"][1], config.orgs[org]["cor"][2], config.orgs[org]["cor"][3]), 16),
                                    fields  = {
                                        {
                                            name = "Responsável",
                                            value = identity.name.." "..identity.name2.." - "..user_id,
                                            inline = false
                                        },
                                        {
                                            name = "Promovido",
                                            value = nidentity.name.." "..nidentity.name2.." - "..id,
                                            inline = false
                                        },
                                        {
                                            name = "Cargo Antigo",
                                            value = "Membro",
                                            inline = false
                                        },
                                        {
                                            name = "Cargo Novo",
                                            value = "Gerente",
                                            inline = false
                                        }
                                    }
                                }
                            }
                        })
                    end
                elseif query["cargo"] == "Gerente" then
                    if perma == "Lider" then
                        vRP.execute("yrGroups/delUser", { id = id })
                        vRP.remPermission(id, config.orgs[perm]["Gerente"])

                        vRP.execute("yrGroups/setUser", { id = id, org = config.orgs[perm]["Nome"], cargo = "Vice-Lider" })
                        vRP.setPermission(id, config.orgs[perm]["Vice-Lider"])
                        
                        local identity = vRP.userIdentity(user_id)
                        local nidentity = vRP.userIdentity(id)

                        SendWebhook(config.orgs[org]["webhook"], {
                            embeds = {
                                {
                                    author = {
                                        name = "Promoção Realizado"
                                    },
                                    color = tonumber(rgbToHex(config.orgs[org]["cor"][1], config.orgs[org]["cor"][2], config.orgs[org]["cor"][3]), 16),
                                    fields  = {
                                        {
                                            name = "Responsável",
                                            value = identity.name.." "..identity.name2.." - "..user_id,
                                            inline = false
                                        },
                                        {
                                            name = "Promovido",
                                            value = nidentity.name.." "..nidentity.name2.." - "..id,
                                            inline = false
                                        },
                                        {
                                            name = "Cargo Antigo",
                                            value = "Gerente",
                                            inline = false
                                        },
                                        {
                                            name = "Cargo Novo",
                                            value = "Vice Líder",
                                            inline = false
                                        }
                                    }
                                }
                            }
                        })
                    end
                end
            else
                local identity = vRP.userIdentity(id)
                TriggerClientEvent("Notify", source, "vermelho", "O passaporte "..id.." não está na cidade!", 3 * 1000)
            end
            
            TriggerEvent("yrGroups:UpdateTablet", user_id, "Refresh")
        end
    end
end)