# 📋 QScopy
** Glassmorphism-style Clipboard Manager for Wayland (Hyprland).**

---
✨ **Built with Vibe Coding**
This project was rapidly developed using AI-driven "Vibe Coding" with a focus on fluid aesthetics and UX.
---

## ✨ Features
- 🧊 **Glassmorphism UI:** Blurred, translucent background.
- 🏝️ **Island Preview:** Dynamic side-panel for text/image content.
- 📱 **Material You:** Smooth organic animations.
- ⚙️ **Integrated Settings:** Real-time transparency slider, Dark Mode, and Close on Copy.

## 🛠️ Requirements
- `quickshell`
- `wl-clipboard`
- `python3`
- `notify-send`

## 🚀 Installation & Execution

1. **Extract** the files to `~/.config/qscopy/`
2. **Make executable:**
```bash
chmod +x bin/qscopy bin/qscopy-daemon
```
3. **Start the Watcher (Add to your startup script):**
```bash
~/.config/qscopy/bin/qscopy-daemon watch &
```
4. **Open the UI (Toggle):**
```bash
~/.config/qscopy/bin/qscopy
```

## ⌨️ Hyprland Keybind
Add this to your Hyprland config:
```ini
# Window Rules
windowrule = match:title ^(qscopy-window)$, float on
windowrule = match:title ^(qscopy-window)$, center on
windowrule = match:title ^(qscopy-window)$, pin on
windowrule = match:title ^(qscopy-window)$, stayfocused on

# Keybind
bind = SUPER, V, exec, ~/.config/qscopy/bin/qscopy
```

## 📜 Credits
QScopy is a heavily redesigned version of [JCM](https://github.com/justanoobcoder/jcm) by **justanoobcoder**. It features a complete UI overhaul and an integrated settings system.
