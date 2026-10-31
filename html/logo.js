function applyServerLogo(logoConfig) {
    const img = document.getElementById('logoImg')
    const placeholder = document.getElementById('logoPlaceholder')
    const slot = document.getElementById('comp-logo')
    if (!img || !placeholder || !slot) return

    const position = logoConfig?.position || {}
    const enabled = logoConfig?.enabled !== false
    const hasSource = typeof logoConfig?.url === 'string' && logoConfig.url !== ''

    slot.classList.remove('glass')
    slot.classList.toggle('hidden', !enabled || !hasSource)
    if (!enabled || !hasSource) return

    if (logoConfig.width) slot.style.setProperty('--logo-w', `${Number(logoConfig.width)}px`)
    if (logoConfig.height) slot.style.setProperty('--logo-h', `${Number(logoConfig.height)}px`)
    if (logoConfig.scale) slot.style.setProperty('--logo-scale', String(Number(logoConfig.scale)))
    if (position.top != null) slot.style.setProperty('--logo-top', `${Number(position.top)}%`)
    if (position.left != null) slot.style.setProperty('--logo-left', `${Number(position.left)}%`)
    if (logoConfig.zIndex != null) slot.style.setProperty('--logo-z', String(Number(logoConfig.zIndex)))

    img.src = logoConfig.url
    img.classList.remove('hidden')
    placeholder.classList.add('hidden')
    img.onerror = () => {
        img.classList.add('hidden')
        placeholder.classList.remove('hidden')
    }
}