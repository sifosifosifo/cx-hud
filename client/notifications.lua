local function normalizeNotificationType(color)
    if color == 2 or color == 'error' then return 'error' end
    if color == 3 or color == 'warning' then return 'warning' end
    if color == 'info' or color == 'inform' then return 'info' end
    return 'success'
end

local function sendNotification(color, message, duration)
    local text = type(message) == 'string' and message or tostring(message or '')
    local lifetime = tonumber(duration) or 5000
    if lifetime ~= lifetime then lifetime = 5000 end
    lifetime = math.max(1, math.min(lifetime, 60000))

    SendNUIMessage({
        action = 'notify',
        data = {
            type = normalizeNotificationType(color),
            text = text,
            duration = lifetime,
        },
    })
end

RegisterNetEvent('notifications:sendNotification', function(color, message, duration)
    sendNotification(color, message, duration)
end)

RegisterNetEvent('notifications:closeUI', function()
    SendNUIMessage({ action = 'clearNotifications' })
end)

RegisterCommand('testnotfy', function(_, args)
    local color = tonumber(args[1]) or 1
    local message = #args > 1 and table.concat(args, ' ', 2) or 'Test notification from cx-hud'
    sendNotification(color, message, 5000)
end, false)
