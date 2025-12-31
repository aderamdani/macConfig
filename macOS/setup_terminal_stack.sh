#!/usr/bin/env bash
# filename: setup_terminal_stack.sh
# Installer untuk: Homebrew, iTerm2, Oh My Posh, Fastfetch, Nerd Font, dan konfigurasi zsh
# Tested: macOS Tahoe / Apple Silicon & Intel
# Jalankan tanpa sudo.

set -euo pipefail

# Warna
GREEN="$(printf '\033[32m')"
YELLOW="$(printf '\033[33m')"
RED="$(printf '\033[31m')"
BLUE="$(printf '\033[34m')"
BOLD="$(printf '\033[1m')"
RESET="$(printf '\033[0m')"

log() { echo "${BLUE}${BOLD}[*]${RESET} $*"; }
ok()  { echo "${GREEN}${BOLD}[OK]${RESET} $*"; }
warn(){ echo "${YELLOW}${BOLD}[! ]${RESET} $*"; }
err() { echo "${RED}${BOLD}[XX]${RESET} $*"; }

is_cmd() { command -v "$1" >/dev/null 2>&1; }

ARCH="$(uname -m)"
IS_APPLE_SILICON=false
if [[ "$ARCH" == "arm64" ]]; then
  IS_APPLE_SILICON=true
fi

ZSHRC="$HOME/.zshrc"
ZPROFILE="$HOME/.zprofile"
BREW_PREFIX_DEFAULT_APPLE="/opt/homebrew"
BREW_PREFIX_DEFAULT_INTEL="/usr/local"
BREW_PREFIX="$BREW_PREFIX_DEFAULT_INTEL"
$IS_APPLE_SILICON && BREW_PREFIX="$BREW_PREFIX_DEFAULT_APPLE"

require_xcode_clt() {
  if ! is_cmd gcc && ! is_cmd git; then
    warn "Xcode Command Line Tools tidak terdeteksi. Menginstall..."
    xcode-select --install || true
    echo "Jika muncul dialog installer CLT, selesaikan hingga selesai, lalu jalankan kembali script ini jika perlu."
  fi
}

install_homebrew() {
  if is_cmd brew; then
    ok "Homebrew sudah terpasang: $(brew --version | head -n1)"
    return
  fi
  log "Menginstall Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "Homebrew terpasang."
}

ensure_brew_shellenv() {
  # Pastikan brew ada di PATH untuk sesi saat ini dan startup shell
  if ! is_cmd brew && [[ -x "$BREW_PREFIX/bin/brew" ]]; then
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  fi

  # Tambahkan evaluasi ke file startup zsh
  if ! grep -q 'brew shellenv' "$ZPROFILE" 2>/dev/null; then
    log "Menambahkan brew shellenv ke $ZPROFILE"
    mkdir -p "$(dirname "$ZPROFILE")"
    echo "eval \"$(/opt/homebrew/bin/brew shellenv 2>/dev/null || $BREW_PREFIX/bin/brew shellenv)\"" >> "$ZPROFILE"
  fi

  # Untuk .zshrc juga berguna bila zprofile tidak dieksekusi dalam beberapa setup
  if ! grep -q 'brew shellenv' "$ZSHRC" 2>/dev/null; then
    log "Menambahkan brew shellenv ke $ZSHRC"
    mkdir -p "$(dirname "$ZSHRC")"
    echo "eval \"$(/opt/homebrew/bin/brew shellenv 2>/dev/null || $BREW_PREFIX/bin/brew shellenv)\"" >> "$ZSHRC"
  fi

  # Terapkan di sesi ini
  if is_cmd brew; then
    eval "$(brew shellenv)"
  elif [[ -x "$BREW_PREFIX/bin/brew" ]]; then
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  fi

  if ! is_cmd brew; then
    err "Gagal mengaktifkan brew di PATH. Coba buka terminal baru setelah instalasi dan jalankan lagi."
    exit 1
  fi
  ok "PATH untuk brew siap."
}

install_iterm() {
  if [[ -d "/Applications/iTerm.app" ]] || osascript -e 'id of app "iTerm"' >/dev/null 2>&1; then
    ok "iTerm2 sudah terpasang."
    return
  fi
  log "Menginstall iTerm2 via Homebrew Cask..."
  brew install --cask iterm2
  ok "iTerm2 terpasang."
}

install_nerd_font() {
  # Meslo Nerd Font umum dipakai untuk oh-my-posh agar ikon tampil
  if fc-list | grep -qi "MesloLGS Nerd Font"; then
    ok "MesloLGS Nerd Font sudah terpasang."
    return
  fi
  log "Menginstall Meslo Nerd Font..."
  brew tap homebrew/cask-fonts || true
  brew install --cask font-meslo-lg-nerd-font
  ok "Nerd Font terpasang. Atur font di iTerm: Profiles > Text > Font: MesloLGS Nerd Font."
}

install_oh_my_posh() {
  if is_cmd oh-my-posh; then
    ok "Oh My Posh sudah terpasang: $(oh-my-posh --version || echo 'installed')"
    return
  fi
  log "Menginstall Oh My Posh..."
  brew install oh-my-posh
  ok "Oh My Posh terpasang."
}

install_fastfetch() {
  if is_cmd fastfetch; then
    ok "Fastfetch sudah terpasang: $(fastfetch --version | head -n1)"
    return
  fi
  log "Menginstall Fastfetch..."
  brew install fastfetch
  ok "Fastfetch terpasang."
}

setup_omp_config() {
  local THEMES_DIR="$HOME/.poshthemes"
  mkdir -p "$THEMES_DIR"

  # Unduh satu theme populer (paradox) sebagai default
  local PARADOX_URL="https://ohmyposh.dev/themes/paradox.omp.json"
  if [[ ! -f "$THEMES_DIR/paradox.omp.json" && ! -f "$THEMES_DIR/paradox.omp.json.gz" ]]; then
    log "Mengunduh tema Oh My Posh: paradox"
    curl -fsSL "$PARADOX_URL" -o "$THEMES_DIR/paradox.omp.json" || {
      warn "Gagal mengunduh langsung paradox theme. Coba fetch daftar theme bawaan."
      oh-my-posh get themes >/dev/null 2>&1 || true
    }
    # Kompres opsional agar cepat dibaca
    if [[ -f "$THEMES_DIR/paradox.omp.json" ]]; then
      gzip -f "$THEMES_DIR/paradox.omp.json"
    fi
  fi

  local CONFIG_PATH="$THEMES_DIR/paradox.omp.json.gz"
  [[ -f "$CONFIG_PATH" ]] || CONFIG_PATH="$THEMES_DIR/paradox.omp.json"

  # Tambahkan init ke .zshrc bila belum ada
  if ! grep -q 'oh-my-posh init zsh' "$ZSHRC" 2>/dev/null; then
    log "Menambahkan init Oh My Posh ke $ZSHRC"
    {
      echo
      echo "# Oh My Posh init"
      echo "eval \"\$(oh-my-posh init zsh --config $CONFIG_PATH)\""
    } >> "$ZSHRC"
  else
    warn "Baris init Oh My Posh sudah ada di $ZSHRC, tidak menambah duplikat."
  fi
  ok "Konfigurasi Oh My Posh selesai."
}

configure_fastfetch_alias() {
  # Tambah alias praktis di zshrc
  if ! grep -q 'alias sysinfo=' "$ZSHRC" 2>/dev/null; then
    log "Menambahkan alias sysinfo (fastfetch) ke $ZSHRC"
    {
      echo
      echo "# Fastfetch alias"
      echo "alias sysinfo='fastfetch --logo-color-override \"blue\"'"
    } >> "$ZSHRC"
  fi
}

prompt_reload() {
  echo
  warn "Buka iTerm dan pilih font: MesloLGS Nerd Font (iTerm > Settings > Profiles > Text)."
  warn "Muat ulang konfigurasi shell: 'source ~/.zshrc' atau buka jendela iTerm baru."
  echo
  ok "Instalasi lengkap. Nikmati prompt baru dan perintah sysinfo!"
}

# Konfirmasi
echo "${BOLD}Installer: Homebrew, iTerm2, Oh My Posh, Fastfetch${RESET}"
read -rp "Lanjutkan instalasi? [Y/n]: " ans
ans="${ans:-Y}"
if [[ "$ans" =~ ^[Nn]$ ]]; then
  echo "Dibatalkan."
  exit 0
fi

# Eksekusi
require_xcode_clt
install_homebrew
ensure_brew_shellenv
install_iterm
install_nerd_font
install_oh_my_posh
install_fastfetch
setup_omp_config
configure_fastfetch_alias
prompt_reload
