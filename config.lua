config = {}

config.token = "" -- sua licença aqui
--
config.comando = "painel" -- Comando para abrir o tablet
--
config.admin = "" -- Permissão de Administrador
config.addgroup = "addgroup" -- Comando para adicionar set de líder de facção
config.remgroup = "remgroup" -- Comando para retirar set de líder de facção
config.admWebhook = "" -- Webhook para enviar logs dos sets acima
config.admColor = 3092790 -- cor temática da cidade( em Decimal ) / padrão = 3092790 
--
config.orgs = {
    {
        ["Nome"] = "",-- Nome da Organização / Banco de dados deve ser este nome
        
        ["Lider"] = "", -- Cargo de líder / Qualquer um com este cargo consegue realizar todos os tipod se ações
        ["Vice-Lider"] = "", -- Cargo de vice-líder / Qualquer um com este cargo consegue contratar e demitir
        ["Gerente"] = "", -- Cargo de gerente / Qualquer um com este cargo consegue realizar saque
        ["Membro"] = "", -- Cargo de membro / Qualquer um com este cargo consegue abrir o tablet

        ["cor"] = { 255, 255, 255 }, -- Cor da organização( em RGB )
        ["imagem"] = "", -- Imagem da organização

        ["webhook"] = "" -- Webhook onde serão enviadas logs de transações bancárias / contratações / alterações de cargo
    }
}
--

return config