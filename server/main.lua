ESX = nil

Items = {}
Collected = {}
Collectables = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_collectables:ready', function(source, cb)
    LoadCollected(source, cb)
end)

function LoadCollected(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Enabled then
        MySQL.Async.fetchAll('SELECT * FROM user_collectables WHERE identifier = @identifier', {
            ['@identifier'] =  xPlayer.identifier,
        }, function(result)

            if #result > 0 then
                Items = result[1]
            else
                local Columns = {
                    ['@indentifier'] = xPlayer.identifier
                }
                local Values = {'identifier'}
                local Params = {'@indentifier'}

                for k, v in pairs(Config.Collectables) do
                    Columns['@' .. v.ID] = json.encode({})
                    table.insert(Values, v.ID)
                    table.insert(Params, '@' .. v.ID)
                end

                MySQL.Async.execute('INSERT INTO user_collectables (' .. table.concat(Values,",") .. ') VALUES (' .. table.concat(Params,",") .. ')', Columns, function()
                    LoadCollected(source, cb)
                end)

                return
            end

            for k, v in pairs(Config.Collectables) do
                if Items[v.ID] ~= nil then
                    SetCollected(k, Items[v.ID])
                end
            end
        
            cb(xPlayer, Collectables)
        end)
    end
end

function SetCollected(Type, _Collected)
    if Config.Collectables[Type].Enabled then
        local Collected = json.decode(_Collected)
        Collectables[Type] = Config.Collectables[Type]
        if #Collected then
            for i = 1, #Collectables[Type].Items do             
                if inTable(Collected, Collectables[Type].Items[i].ID) then
                    Collectables[Type].Items[i].Collected = true
                end
            end
        end

        Collectables[Type].Completed = false
        if #Collectables[Type].Items == #Collected then
            Collectables[Type].Completed = true
        end
            
        Collectables[Type].Title = SnakeToWord(Collectables[Type].ID)
        Collectables[Type].Collected = Collected
    end
end

ESX.RegisterServerCallback('esx_collectables:collected', function(source, cb, Collectable, Type, Group)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.execute('UPDATE user_collectables SET ' .. Group.ID .. ' = @' .. Group.ID, {
        ['@identifier'] = xPlayer.identifier,
        ['@' .. Group.ID] = json.encode(Group.Collected),
    }, function(changed)

        Completed = false
        if #Group.Collected == #Config.Collectables[Type].Items then
            Completed = true
        end

        TriggerEvent("esx_collectables:itemCollected", xPlayer, Collectable, Group)

        if Completed then
            TriggerEvent("esCollectables:completed", source, xPlayer, Collectable, Group)
        end

        cb(true, Type, Completed)
    end)
end)