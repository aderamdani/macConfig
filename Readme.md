# macOS Utilities & Configuration

A collection of scripts and tools to customize and configure your macOS environment.

## 🛠️ Included Tools

### 1. Mac Animations Tool
Interactive utility to manage system animations. Useful for speeding up the UI or reverting changes safely.

**Features:**
- **Disable**: Minimize/disable system animations for a snappier feel.
- **Revert**: Restore default settings using backups or system defaults.
- **Status**: Check current status of animation keys.

**Usage:**
```bash
# From the root of the repo (if applicable) or inside macOS folder
cd macOS 2>/dev/null || true
chmod +x mac_animations_tool.sh
./mac_animations_tool.sh
```

### 2. Terminal Stack Setup
Automated installer for a modern terminal experience.

**Installs:**
- **Homebrew**: Package manager.
- **iTerm2**: Terminal emulator.
- **Oh My Posh**: Prompt theme engine.
- **Fastfetch**: System information fetcher.
- **Meslo Nerd Font**: Font with icon support.
- **Zsh Configuration**: Sets up aliases and themes.

**Usage:**
```bash
cd macOS 2>/dev/null || true
chmod +x setup_terminal_stack.sh
./setup_terminal_stack.sh
```

> [!NOTE]
> Run these scripts as a normal user. `sudo` is not required and generally discouraged for these specific scripts.