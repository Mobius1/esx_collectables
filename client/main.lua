ESX = nil
Ready = false

Player = {}
Collected = {}
Collectables = {}

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(response)
            ESX = response
        end)
    end
    Wait(1000)
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()

    InitCollectables()
end)

-- Update player coords
Citizen.CreateThread(function()
    local delay = 100

    if Config.Debug then
        delay = 0
    end

    while true do
        if Ready then
            Player.Ped = PlayerPedId()
            Player.Pos = GetEntityCoords(Player.Ped)

            if Config.Debug then
                RenderDebugHud(Collectables)
            end
        end
        Citizen.Wait(delay)
    end
end)

function EnableCollectable(Type)
    local Collection = Collectables[Type]
    local ItemsCount = #Collection.Items
    Citizen.CreateThread(function()
        while true do
            if Ready and not Collection.Completed then
                for i = 1, ItemsCount do
                    local Item = Collection.Items[i]
                    local dist = #(Item.Pos - Player.Pos) 

                    -- Add debug blip
                    if Config.Debug and not Item.Blip and not Item.Collected then
                        AddDebugBlip(Item, Collection.Blip, Collection.Title)
                    end
                    
                    Item.InRange = false

                    -- Only do checks if player is in range
                    if dist < Config.DrawDistance then
                        if not Item.Collected then
                            Item.InRange = true
                            -- spawn entity when player is in range
                            if not Item.Spawned then
                                SpawnItem(Item, Collection.Prop)
                            end         

                            -- Only do collisions check if player is really close to collectable
                            if dist < 5 then
                                -- check if player has collided with collectable
                                if IsEntityTouchingEntity(Player.Ped, Item.Entity) then
                                    -- Trigger collection
                                    CollectItem(Item, Type)
                                end               
                            end               
                        end
                    end
                end
            end

            Citizen.Wait(0)
        end
    end)
end


-- Initialise
function InitCollectables()
    ESX.TriggerServerCallback("esx_collectables:ready", function(xPlayer, _collectables)
        Player.Ped = PlayerPedId()
        Player.Pos = GetEntityCoords(Player.Ped)

        Collectables = _collectables
        Ready = true

        for k, v in pairs(_collectables) do
            if v.Enabled then
                EnableCollectable(k)
            end
        end
    end)
end

function SpawnItem(item, prop)
    item.Spawned = true
    item.Collected = false

    ESX.Game.SpawnLocalObject(prop, item.Pos, function(entity)
        if Config.PlaceCollectables and not item.fixed then
            PlaceObjectOnGroundProperly(entity)
        end
        FreezeEntityPosition(entity, true)
    
        item.Entity = entity
    end)
end

function DespawnItem(item)
    ESX.Game.DeleteObject(item.Entity)
    item.Spawned = false    
    item.InRange = false    
end

-- Trigger player collected item
function CollectItem(item, type)
    local Collectable = Collectables[type]
    item.Collected = true

    -- Allow player to pass through entity
    SetEntityCollision(item.Entity, false, true)

    table.insert(Collectable.Collected, item.ID)

    ESX.TriggerServerCallback('esx_collectables:collected', function(success, _type, _completed)
        if success then
            -- Remove the item
            DespawnItem(item)

            Collectable.Completed = _completed
            -- Remove debug blip
            if Config.Debug then
                if DoesBlipExist(item.Blip) then
                    SetBlipAsMissionCreatorBlip(item.Blip,false)
                    RemoveBlip(item.Blip)
                    item.Blip = nil
                end
            end

            -- play sound
            PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
        
            -- show notification
            if Collectable.Completed then
                ESX.Scaleform.ShowFreemodeMessage(
                    _U('completed_title', Collectable.Title),
                    _U('completed_msg', #Collectable.Items, Collectable.Title),
                    3
                )
            else
                ESX.Scaleform.ShowFreemodeMessage(
                    _U('found_title', Collectable.Title),
                    _U('found_msg', #Collectable.Collected, #Collectable.Items, Collectable.Title),
                    3
                ) 
            end
        else
            -- there was a problem so respawn item
            SpawnItem(item)
        end
    end, item, type, Collectable)
end


-- Remove spawned items
function RemoveItems()
    for k, v in pairs(Collectables) do
        for i = 1, #Collectables[k].Items do
            local Item = Collectables[k].Items[i]
                            
            if not Item.Collected and Item.Entity then
                DespawnItem(Item)            
            end
        end   
    end 
end

-- Restart
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        if Ready then
            InitCollectables()
        end
    end
end)

-- Reset collectables on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        RemoveItems()
    end
end)