---------------------------------------
--          Better RP Death          --
--          github.com/HNT8          --
---------------------------------------

-- DO NOT EDIT ANYTHING IN THIS FILE
-- UNLESS YOU KNOW WHAT YOU ARE DOING!

---------------------------------------

local dead = false

local reviveTimer = Config.ReviveTimer
local respawnTimer = Config.RespawnTimer

function revivePed(ped)
    local playerPos = GetEntityCoords(ped, true)
    NetworkResurrectLocalPlayer(playerPos, true, true, false)
    SetPlayerInvincible(ped, false)
    dead = false

    respawnTimer = Config.RespawnTimer
    reviveTimer = Config.ReviveTimer
end

local respawnPointData = Config.RespawnPoints
function respawnAtLocation(location)
    local ped = GetPlayerPed(-1)
    local playerPos = GetEntityCoords(ped, true)
    NetworkResurrectLocalPlayer(playerPos, true, true, false)
    SetPlayerInvincible(ped, false)

    for _, item in ipairs(respawnPointData) do
        if item[1] == location then
            SetEntityCoords(ped, item[2][1], item[2][2], item[2][3])
            SetEntityHeading(ped, item[2][4])
            FreezeEntityPosition(player, false)
            if item[3] ~= '' then
                ExecuteCommand("e " .. item[3])
            end
        end
    end
    
    Citizen.Wait(2000)
    DoScreenFadeIn(500)
    Citizen.Wait(2000)
    ExecuteCommand("e c")
    dead = false
    respawnTimer = Config.RespawnTimer
    reviveTimer = Config.ReviveTimer
end

pool = NativeUI.CreatePool()
menu = NativeUI.CreateMenu("Better Death", "Select a location to respawn at, then click respawn!")
pool:Add(menu)
local respawnPointNames = {}
for _, item in ipairs(respawnPointData) do
    table.insert(respawnPointNames, item[1])
end
local respawnPointSelector = NativeUI.CreateListItem("Location", respawnPointNames, 1)
menu:AddItem(respawnPointSelector)
local respawnButton = NativeUI.CreateItem("Respawn", "Respawns you at the selected location.")
menu:AddItem(respawnButton)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        pool:ProcessMenus()
        if IsControlJustPressed(1, 177) then
            menu:Visible(false)
        end
    end
end)
local currentRespawnPoint = "Paleto Hospital"
menu.OnListChange = function(sender, item, index) 
    if item == respawnPointSelector then
        currentRespawnPoint = respawnPointSelector:IndexToItem(index)
    end
end
menu.OnItemSelect = function(sender, item, index)
    if item == respawnButton then
        menu:Visible(false)
        DoScreenFadeOut(100)
        respawnAtLocation(currentRespawnPoint)
    end
end
function respawnPed(ped) 
    menu:Visible(true)
    pool:MouseControlsEnabled(false)
    pool:MouseEdgeEnabled(false)
end

function ShowInfo(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(true, true)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        ped = GetPlayerPed(-1)

        if IsEntityDead(ped) then
            if not dead then
                ShowInfo("~r~You have died! Use ~b~E~y~ to revive~r~, or use ~b~R~y~ to respawn~r~.")
                Citizen.CreateThread(function()
                    while true do
                        if reviveTimer ~= 0 then
                            reviveTimer = reviveTimer - 1
                        end
                        if respawnTimer ~= 0 then
                            respawnTimer = respawnTimer - 1
                        end
                        if respawnTimer == 0 and reviveTimer == 0 then
                            break
                        end
                        Citizen.Wait(1000)
                    end
                end)
            end

            dead = true

            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)

            if IsControlJustReleased(0, 38) and GetLastInputMethod(0) then
                if reviveTimer == 0 then
                    revivePed(ped)
                else
                    ShowInfo('~r~Wait ' .. reviveTimer .. ' more seconds before attempting to revive your character.')
                end
            end
            if IsControlJustReleased(0, 45) and GetLastInputMethod(0) then
                if reviveTimer == 0 then
                    respawnPed(ped)
                else
                    ShowInfo('~r~Wait ' .. reviveTimer .. ' more seconds before attempting to respawn your character.')
                end
            end
        end
    end
end)

AddEventHandler('onClientMapStart', function()
    exports.spawnmanager:spawnPlayer()
    Citizen.Wait(2500)
    exports.spawnmanager:setAutoSpawn(false)
end)