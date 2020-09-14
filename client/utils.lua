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