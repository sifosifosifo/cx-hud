const notifyWrapper = document.getElementById('notifyWrapper')
const notifyVolumeInput = document.getElementById('notifyVolume')
const notifyVolumeValue = document.getElementById('notifyVolumeValue')
const notifyPositionInput = document.getElementById('notifyPosition')
const NOTIFY_VOLUME_KEY = 'cx_hud_notify_volume_v1'
const NOTIFY_POSITION_KEY = 'cx_hud_notify_position_v1'
const NOTIFY_POSITIONS = new Set([
    'top-left', 'top-center', 'top-right',
    'middle-left', 'center', 'middle-right',
    'bottom-left', 'bottom-center', 'bottom-right',
])

function loadNotificationVolume() {
    const saved = localStorage.getItem(NOTIFY_VOLUME_KEY)
    if (saved === null) return 25
    const value = Number(saved)
    return Number.isFinite(value) ? Math.max(0, Math.min(100, Math.round(value))) : 25
}

function loadNotificationPosition() {
    const value = localStorage.getItem(NOTIFY_POSITION_KEY)
    return NOTIFY_POSITIONS.has(value) ? value : 'top-center'
}

let notificationVolume = loadNotificationVolume()
notifyVolumeInput.value = String(notificationVolume)
notifyVolumeValue.value = `${notificationVolume}%`
notifyVolumeValue.textContent = `${notificationVolume}%`
notifyWrapper.dataset.position = loadNotificationPosition()
notifyPositionInput.value = notifyWrapper.dataset.position

notifyVolumeInput.addEventListener('input', () => {
    notificationVolume = Number(notifyVolumeInput.value)
    notifyVolumeValue.value = `${notificationVolume}%`
    notifyVolumeValue.textContent = `${notificationVolume}%`
    localStorage.setItem(NOTIFY_VOLUME_KEY, String(notificationVolume))
})

notifyPositionInput.addEventListener('change', () => {
    const position = notifyPositionInput.value
    if (!NOTIFY_POSITIONS.has(position)) return
    notifyWrapper.dataset.position = position
    localStorage.setItem(NOTIFY_POSITION_KEY, position)
})

function playNotificationSound(type) {
    if (notificationVolume === 0) return

    const soundType = type === 'info' ? 'success' : type
    const audio = new Audio(`sounds/${soundType}.mp3`)
    audio.volume = notificationVolume / 100
    audio.play().catch(error => {
        try {
            const AudioContextClass = window.AudioContext || window.webkitAudioContext
            if (!AudioContextClass) throw new Error('Web Audio API is unavailable')
            const context = new AudioContextClass()
            const oscillator = context.createOscillator()
            const gain = context.createGain()
            const now = context.currentTime
            const settings = {
                success: { frequency: 880, duration: 0.18, wave: 'sine' },
                error: { frequency: 220, duration: 0.45, wave: 'square' },
                warning: { frequency: 440, duration: 0.28, wave: 'sawtooth' },
                info: { frequency: 660, duration: 0.18, wave: 'sine' },
            }[type]
            oscillator.type = settings.wave
            oscillator.frequency.setValueAtTime(settings.frequency, now)
            gain.gain.setValueAtTime(0.0001, now)
            gain.gain.exponentialRampToValueAtTime(0.05 * notificationVolume / 25, now + 0.01)
            gain.gain.exponentialRampToValueAtTime(0.0001, now + settings.duration)
            oscillator.connect(gain)
            gain.connect(context.destination)
            oscillator.start(now)
            oscillator.stop(now + settings.duration + 0.05)
            oscillator.addEventListener('ended', () => context.close(), { once: true })
        } catch (fallbackError) {
            console.warn('Notification sound could not be played:', error, fallbackError)
        }
    })
}

function createNotification(text, type, duration) {
    const notification = document.createElement('div')
    notification.className = `notify ${type}`

    const head = document.createElement('div')
    head.className = 'notify-head'
    const tag = document.createElement('div')
    tag.className = 'notify-tag'
    tag.textContent = type
    const time = document.createElement('div')
    time.className = 'notify-time'
    time.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    head.append(tag, time)

    const message = document.createElement('div')
    message.className = 'notify-text'
    message.textContent = String(text ?? '')

    const bar = document.createElement('div')
    bar.className = 'notify-bar'
    notification.append(head, message, bar)
    notifyWrapper.appendChild(notification)
    playNotificationSound(type)

    bar.style.transition = `width ${duration}ms linear`
    setTimeout(() => { bar.style.width = '0%' }, 10)
    setTimeout(() => {
        notification.classList.add('is-closing')
        setTimeout(() => notification.remove(), 300)
    }, duration)
}

window.addEventListener('message', event => {
    const data = event.data
    if (data?.action === 'notify') {
        const type = ['success', 'error', 'warning', 'info'].includes(data.data?.type)
            ? data.data.type
            : 'success'
        const duration = Number(data.data?.duration)
        createNotification(
            data.data?.text,
            type,
            Number.isFinite(duration) && duration > 0 ? duration : 5000
        )
    } else if (data?.action === 'clearNotifications') {
        notifyWrapper.replaceChildren()
    }
})
