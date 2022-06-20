-- Runs this query manually once:
-- CREATE TABLE IF NOT EXISTS `ac_eluna`.`lootcounter` (`timestamp_start` INT NOT NULL, `timestamp_end` INT NOT NULL, `item` VARCHAR(50), `amount` INT DEFAULT 0, PRIMARY KEY (`timestamp_start`, `item`) );

local PLAYER_EVENT_ON_LOOT_ITEM = 32        -- (event, player, item, count)
local ELUNA_EVENT_ON_LUA_STATE_CLOSE = 16   -- (event) - triggers just before shutting down eluna (on shutdown and restart)

local function returnIndex (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end

local lootlist = {
    [1] = 'Linen Cloth',
    [2] = 'Wool Cloth',
    [3] = 'Silk Cloth',
    [4] = 'Mageweave Cloth',
    [5] = 'Light Leather',
    [6] = 'Medium Leather',
    [7] = 'Heavy Leather',
    [8] = 'Thick Leather',
    [9] = 'Purple Lotus',
    [10] = 'Spotted Yellowtail',
}

local lootcounter = {}
local starttime = tonumber( tostring( GetGameTime() ) )

local function OnLootItem( event, player, item, count )
    local index = returnIndex( lootlist, item:GetName() )
    if index ~= false then
        lootcounter[index] =  lootcounter[index] + count
    end
end

local function SaveLootAmounts()
    local time = tonumber( tostring(GetGameTime()) )
    for n = 1, #lootlist do
        CharDBExecute('INSERT INTO `ac_eluna`.`lootcounter` VALUES (' .. starttime .. ', ' .. time .. ', \'' .. lootlist[n] .. '\', ' .. lootcounter[n] .. ');')
    end
end

RegisterPlayerEvent( PLAYER_EVENT_ON_LOOT_ITEM, OnLootItem )
RegisterServerEvent( ELUNA_EVENT_ON_LUA_STATE_CLOSE, SaveLootAmounts )

--initialize the counters at 0
for n = 1,#lootlist do
    lootcounter[n] = 0
end
