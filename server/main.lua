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

    MySQL.Async.execute('UPDATE user_collectables SET ' .. Group.ID .. ' = @group WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier,
        ['@group'] = json.encode(Group.Collected),
    }, function(changed)

        local Rewards = false

        if Config.Collectables[Type].Rewards ~= nil and #Config.Collectables[Type].Rewards then
            Rewards = true
        end

        Completed = false
        if #Group.Collected == #Config.Collectables[Type].Items then
            Completed = true
        end

        if Rewards then
            RewardPlayer(xPlayer, Config.Collectables[Type].Rewards.PerItem)
        end

        TriggerEvent("esx_collectables:itemCollected", xPlayer, Collectable, Group)

        if Completed then
            if Rewards then
                RewardPlayer(xPlayer, Config.Collectables[Type].Rewards.Completed)
            end
            TriggerEvent("esCollectables:completed", source, xPlayer, Collectable, Group)
        end

        cb(true, Type, Completed)
    end)
end)

-- Reset player progress
ESX.RegisterServerCallback('esx_collectables:reset', function(source, cb, group)
    local xPlayer = ESX.GetPlayerFromId(source)


    MySQL.Async.execute('UPDATE user_collectables SET ' .. group.ID .. ' = @group WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier,
        ['@group'] = json.encode({}),
    }, function(changed)

        local Total = 0

        -- Remove earned money to prevent player spamming collectables to build money up
        if group.Rewards ~= nil then
            -- Remove money for each item found
            if group.Rewards.PerItem ~= nil and tonumber(group.Rewards.PerItem) ~= nil then
                local Money = #group.Collected * group.Rewards.PerItem
                xPlayer.removeMoney(math.floor(Money))

                Total = Total + Money
            end

            -- Remove money for completing quest
            if group.Completed then
                if group.Rewards.Completed ~= nil and tonumber(group.Rewards.Completed) ~= nil then
                    xPlayer.removeMoney(math.floor(group.Rewards.Completed))

                    Total = Total + group.Rewards.Completed
                end
            end
        end

        TriggerEvent("esx_collectables:resetProgress", xPlayer, Collectable, Group, Total)

        cb(true, Total)
    end)
end)