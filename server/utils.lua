function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return true end
    end
    return false
end

function SnakeToWord(str)
    local w = {}
    for word in string.gmatch(str, '([^_]+)') do
        table.insert(w, (word:gsub("^%l", string.upper)))
    end
    return table.concat(w, ' ')
end

function RewardPlayer(xPlayer, Reward)
    if Reward ~= nil and tonumber(Reward) ~= nil then
        xPlayer.addMoney(math.floor(Reward))
    end
end