return function(State, Utils, Minimap, Status, Vehicle, isReady, Config)
    RegisterCommand(Config.MenuCommand or 'hud', function()
        if not isReady() then return end
        State.menuIsOpen = true
        SetNuiFocus(true, true)
        Utils.sendNui('openMenu', {})
    end, false)

    local function sendKvpLayout()
        local raw = GetResourceKvpString('cx_hud_layout')
        if not raw or raw == '' then return end
        local ok, layout = pcall(json.decode, raw)
        if ok and type(layout) == 'table' then
            Utils.sendNui('playerLayout', { layout = layout })
        end
    end

    local radioChannel = 0

    local function sendRadioList(data)
        Utils.sendNui('radioList', data)
    end

    local function radioPlayerName(playerId, radioName)
        return radioName or GetPlayerName(GetPlayerFromServerId(playerId)) or ('Player ' .. tostring(playerId))
    end

    local function updateRadioChannel(channel)
        radioChannel = tonumber(channel) or 0
        sendRadioList({
            clearRadioList = radioChannel == 0,
            changeVisibility = true,
            visible = radioChannel > 0,
            channel = radioChannel > 0 and radioChannel or '',
        })
    end

    AddStateBagChangeHandler('radioChannel', nil, function(bagName, _, value)
        if bagName ~= ('player:%s'):format(GetPlayerServerId(PlayerId())) then return end
        updateRadioChannel(value)
    end)

    RegisterNetEvent('pma-voice:clSetPlayerRadio', function(channel)
        updateRadioChannel(channel)
    end)

    RegisterNetEvent('pma-voice:syncRadioData', function(radioTable, localRadioName)
        local localPlayerId = GetPlayerServerId(PlayerId())
        radioChannel = tonumber(LocalPlayer.state.radioChannel) or radioChannel
        sendRadioList({
            clearRadioList = true,
            changeVisibility = true,
            visible = radioChannel > 0,
            channel = radioChannel,
        })

        for playerId, _ in pairs(radioTable or {}) do
            local numericPlayerId = tonumber(playerId)
            if numericPlayerId then
                sendRadioList({
                    radioId = numericPlayerId,
                    radioName = numericPlayerId == localPlayerId and localRadioName or radioPlayerName(numericPlayerId),
                    self = numericPlayerId == localPlayerId,
                    channel = radioChannel,
                })
            end
        end

        CreateThread(function()
            for _ = 1, 20 do
                local syncedChannel = tonumber(LocalPlayer.state.radioChannel)
                if syncedChannel and syncedChannel ~= radioChannel then
                    updateRadioChannel(syncedChannel)
                    break
                end
                Wait(100)
            end
        end)
    end)

    RegisterNetEvent('pma-voice:addPlayerToRadio', function(playerId, radioName)
        sendRadioList({
            radioId = playerId,
            radioName = radioPlayerName(playerId, radioName),
            self = tonumber(playerId) == GetPlayerServerId(PlayerId()),
            channel = radioChannel,
        })
    end)

    RegisterNetEvent('pma-voice:removePlayerFromRadio', function(playerId)
        sendRadioList({ radioId = playerId, channel = radioChannel })
    end)

    RegisterNetEvent('pma-voice:setTalkingOnRadio', function(playerId, talking)
        sendRadioList({ radioId = playerId, radioTalking = talking })
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        Status.fetchPlayerData()
        State.coreLoaded    = true
        State.playerSpawned = true
        sendKvpLayout()
        TriggerServerEvent('cx-hud:requestDefaultLayout')
        CreateThread(function() Wait(1500); SetBigmapActive(false, false); Status.tryShowHud() end)
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        State.coreLoaded = false; State.playerSpawned = false; State.seatbeltOn = false
        Status.showHud(false); DisplayRadar(false)
    end)

    AddEventHandler('playerSpawned', function()
        if not State.coreLoaded then return end
        State.playerSpawned = true; Status.fetchPlayerData()
        CreateThread(function() Wait(1500); SetBigmapActive(false, false); Status.tryShowHud() end)
    end)

    AddEventHandler('onResourceStart', function(res)
        if res ~= GetCurrentResourceName() then return end
        Status.fetchPlayerData()
        if LocalPlayer.state.isLoggedIn then
            State.coreLoaded = true
            if NetworkIsPlayerActive(cache.playerId) and DoesEntityExist(cache.ped) then
                State.playerSpawned = true
            end
            sendKvpLayout()
            TriggerServerEvent('cx-hud:requestDefaultLayout')
            CreateThread(function() Wait(1000); SetBigmapActive(false, false); Status.tryShowHud() end)
        else
            Status.showHud(false)
        end

        -- show zone-pill immediately (default to red) and poll redzone export quickly
        Utils.sendNui('zoneCamera', { state = 'red' })

        CreateThread(function()
            local attempts = 0
            local maxAttempts = 15
            local found = false
            while attempts < maxAttempts do
                attempts = attempts + 1
                local ok, inZone, z = pcall(function()
                    if exports['redzone'] and type(exports['redzone'].IsInGreenZone) == 'function' then
                        return exports['redzone']:IsInGreenZone()
                    elseif exports['redzone'] and type(exports['redzone']) == 'table' and type(exports['redzone'].IsInGreenZone) == 'function' then
                        return exports['redzone']:IsInGreenZone()
                    else
                        error('export not available')
                    end
                end)

                if ok then
                    found = true
                    if inZone then
                        Utils.sendNui('zoneCamera', { state = 'green', name = (z and z.name) or nil })
                    else
                        Utils.sendNui('zoneCamera', { state = 'red' })
                    end
                    break
                end

                Wait(200)
            end

            if not found then
                print('[cx-hud] error: redzone export `IsInGreenZone` not available — zone integration disabled')
            end
        end)
    end)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(playerData)
        State.playerData = playerData or {}
        Status.refreshStaticCache()
        if State.hudShowing then Status.pushStatus(true) end
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
        State.playerData.job = job
        Status.refreshStaticCache()
        if State.hudShowing then Status.pushStatus(false) end
    end)

    RegisterNetEvent('QBCore:Client:OnMoneyChange', function(moneyType, amount, operation)
        State.playerData.money = State.playerData.money or {}
        local current = State.playerData.money[moneyType] or 0
        if     operation == 'add'    then State.playerData.money[moneyType] = current + amount
        elseif operation == 'remove' then State.playerData.money[moneyType] = math.max(0, current - amount)
        elseif operation == 'set'    then State.playerData.money[moneyType] = amount
        end
        Status.refreshMoneyCache()
        if State.hudShowing then Status.pushStatus(false) end
    end)

    RegisterNetEvent('hud:client:UpdateNeeds', function(hunger, thirst)
        State.playerData.metadata        = State.playerData.metadata or {}
        State.playerData.metadata.hunger = hunger
        State.playerData.metadata.thirst = thirst
        if State.hudShowing then Status.pushStatus(false) end
    end)

    RegisterNetEvent('pma-voice:setTalkingMode', function(mode)
        local modes = { [1] = 'Whisper', [2] = 'Normal', [3] = 'Shout' }
        State.voiceLabel = modes[mode] or Config.DefaultVoice
        if State.hudShowing then Status.pushStatus(false) end
    end)

    RegisterNetEvent('cx-hud:versionResult', function(current, latest, outdated)
        Utils.sendNui('versionInfo', { current = current, latest = latest, outdated = outdated })
    end)

    RegisterNetEvent('cx-hud:receiveDefaultLayout', function(defaultLayoutData, canSetDefault)
        Utils.sendNui('serverDefaultLayout', {
            layout        = defaultLayoutData and defaultLayoutData.layout or nil,
            name          = defaultLayoutData and defaultLayoutData.name  or nil,
            canSetDefault = canSetDefault or false,
        })
    end)

    RegisterNetEvent('cx-hud:saveDefaultResult', function(success, msg)
        Utils.sendNui('saveDefaultResult', { success = success, message = msg })
    end)

    RegisterNetEvent('hud:zoneStatus', function(status, name)
        local payload = { state = status or 'none' }
        if name then payload.name = name end
        Utils.sendNui('zoneCamera', payload)
    end)
end