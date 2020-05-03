-- Add debug blip to map
function AddDebugBlip(Item, Blip, text)

    if Blip==nil then Blip={ID=66,Color=2,Scale=1.0}end

    Item.Blip = AddBlipForCoord(Item.Pos.x, Item.Pos.y, Item.Pos.z)
    SetBlipSprite(Item.Blip, Blip.ID)
    SetBlipAsShortRange(Item.Blip, true)
    SetBlipColour(Item.Blip, Blip.Color)
    SetBlipScale(Item.Blip, Blip.Scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(Item.Blip)    
end

-- Draw debug
function RenderDebugHud(collectables)
    local active = 0
    local items = 0
    for k, v in pairs(collectables) do
        local ItemsCount = #v.Items
        for j = 1, ItemsCount do
            items = items + 1
            if v.Items[j].InRange then
                active = active + 1
            end
        end
    end

    RenderText(0.015, 0.60, 'No. of collectables:         ' .. items, 0.4)
    RenderText(0.015, 0.62, 'Draw Distance:                ' .. Config.DrawDistance, 0.4)
    RenderText(0.015, 0.64, 'Collectables in range:     ' .. active, 0.4)
end


function RenderText(x, y, text, scale)
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end