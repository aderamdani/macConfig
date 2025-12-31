#!/usr/bin/env bash
# filename: mac_animations_tool.sh
# Aplikasi terminal interaktif untuk mengelola animasi di macOS (tested di macOS Tahoe).
# Fitur:
# - Disable: meminimalkan/mematikan animasi sistem
# - Revert: mengembalikan perubahan ke default menggunakan backup atau defaults delete
# - Status: menampilkan status beberapa key utama
#
# Catatan:
# - Beberapa key mungkin diabaikan oleh versi macOS tertentu; aman untuk dijalankan.
# - Jangan gunakan sudo, cukup user biasa.
# - Reduce Motion di Tahoe menggunakan domain com.apple.Accessibility ReduceMotionEnabled.

set -euo pipefail

APP_NAME="Mac Animations Tool"
BACKUP_ROOT="$HOME/.mac_anim_backup"
mkdir -p "$BACKUP_ROOT"

# Warna untuk UI
RED="$(printf '\033[31m')"
GREEN="$(printf '\033[32m')"
YELLOW="$(printf '\033[33m')"
BLUE="$(printf '\033[34m')"
BOLD="$(printf '\033[1m')"
RESET="$(printf '\033[0m')"

print_header() {
  clear || true
  echo "${BOLD}${BLUE}${APP_NAME}${RESET}"
  echo "Tanggal: $(date)"
  echo
}

pause() {
  read -rp "Tekan Enter untuk melanjutkan..."
}

latest_backup_dir() {
  ls -dt "$BACKUP_ROOT"/* 2>/dev/null | head -n1
}

# Helper: backup value jika ada
backup_default() {
  local domain="$1"
  local key="$2"
  local backup_dir="$3"
  local outfile="$backup_dir/${domain//\./_}__${key}.txt"

  if defaults read "$domain" "$key" >/dev/null 2>&1; then
    defaults read "$domain" "$key" > "$outfile" || true
  else
    echo "__MISSING__" > "$outfile"
  fi
}

# Helper: tulis nilai dengan tipe yang benar
write_default_typed() {
  local domain="$1"
  local key="$2"
  local type="$3" # bool|float|string|int
  local value="$4"

  case "$type" in
    bool)  defaults write "$domain" "$key" -bool "$value" ;;
    float) defaults write "$domain" "$key" -float "$value" ;;
    string) defaults write "$domain" "$key" -string "$value" ;;
    int)   defaults write "$domain" "$key" -int "$value" ;;
    *)
      echo "${RED}Tipe tidak dikenali untuk $domain $key: $type${RESET}"
      return 1
      ;;
  esac
}

# Helper: restore dari backup jika ada, jika tidak delete
restore_or_delete() {
  local domain="$1"
  local key="$2"
  local backup_dir="$3"
  local path="$backup_dir/${domain//\./_}__${key}.txt"

  if [ -f "$path" ]; then
    local val
    val=$(cat "$path")
    if [ "$val" = "__MISSING__" ]; then
      defaults delete "$domain" "$key" >/dev/null 2>&1 || true
    else
      # Deteksi sederhana tipe
      if [[ "$val" == "1" || "$val" == "0" || "$val" == "true" || "$val" == "false" ]]; then
        if [[ "$val" == "1" || "$val" == "true" ]]; then
          write_default_typed "$domain" "$key" bool true
        else
          write_default_typed "$domain" "$key" bool false
        fi
      elif [[ "$val" =~ ^-?[0-9]+$ ]]; then
        write_default_typed "$domain" "$key" int "$val"
      elif [[ "$val" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
        write_default_typed "$domain" "$key" float "$val"
      else
        write_default_typed "$domain" "$key" string "$val"
      fi
    fi
  else
    defaults delete "$domain" "$key" >/dev/null 2>&1 || true
  fi
}

restart_processes() {
  echo "Restarting Dock, Finder, SystemUIServer, Safari..."
  killall Dock >/dev/null 2>&1 || true
  killall Finder >/dev/null 2>&1 || true
  killall SystemUIServer >/dev/null 2>&1 || true
  killall Safari >/dev/null 2>&1 || true
}

# Daftar konfigurasi yang akan diubah
# Format: domain|key|type|value
CONFIGS=(
  "NSGlobalDomain|NSAutomaticWindowAnimationsEnabled|bool|false"
  "NSGlobalDomain|NSWindowResizeTime|float|0.001"
  "NSGlobalDomain|NSScrollAnimationEnabled|bool|false"
  "NSGlobalDomain|QLPanelAnimationDuration|float|0"
  "NSGlobalDomain|NSToolbarTitleViewRolloverDelay|float|0"
  "com.apple.dock|launchanim|bool|false"
  "com.apple.dock|expose-animation-duration|float|0.1"
  "com.apple.dock|autohide-time-modifier|float|0"
  "com.apple.dock|autohide-delay|float|0"
  "com.apple.dock|mineffect|string|scale"
  "com.apple.finder|DisableAllAnimations|bool|true"
  "com.apple.spaces|spans-displays|bool|false"
  "com.apple.dock|workspaces-edge-delay|float|0"
  "NSGlobalDomain|NSDocumentSaveNewDocumentsToCloud|bool|false"
  "NSGlobalDomain|NSWindowShouldUseResolutionBasedSizing|bool|false"
  "com.apple.dock|showAppExposeAnimations|bool|false"
  "NSGlobalDomain|com.apple.springing.delay|float|0"
  "NSGlobalDomain|com.apple.springing.enabled|bool|true"
  "NSGlobalDomain|NSAutomaticMetricAnimationEnabled|bool|false"
  "NSGlobalDomain|NSWindowShouldAnimate|bool|false"
  "com.apple.Accessibility|ReduceMotionEnabled|bool|true"   # macOS Tahoe
  "com.apple.Safari|WebKitInitialTimedLayoutDelay|float|0.25"
  "com.apple.Safari|ShowOverlayStatusBar|bool|true"
)

disable_animations() {
  print_header
  echo "${YELLOW}Mode: Disable Animations${RESET}"
  echo "Membuat backup dan menerapkan perubahan..."
  local backup_dir="$BACKUP_ROOT/backup_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$backup_dir"

  for entry in "${CONFIGS[@]}"; do
    IFS='|' read -r domain key type value <<<"$entry"
    printf "• %-45s " "$domain $key"
    backup_default "$domain" "$key" "$backup_dir"
    write_default_typed "$domain" "$key" "$type" "$value"
    echo "${GREEN}OK${RESET}"
  done

  restart_processes
  echo
  echo "${GREEN}Selesai. Backup disimpan di: $backup_dir${RESET}"
  echo "Tips: logout/restart untuk efek penuh (Mission Control/Spaces)."
  pause
}

revert_animations() {
  print_header
  echo "${YELLOW}Mode: Revert to Default${RESET}"

  local latest
  latest="$(latest_backup_dir || true)"
  if [ -z "${latest:-}" ]; then
    echo "${RED}Tidak ada backup ditemukan.${RESET}"
    echo "Tetap mencoba revert dengan defaults delete pada key umum."
  else
    echo "Menggunakan backup: ${GREEN}$latest${RESET}"
  fi
  echo

  for entry in "${CONFIGS[@]}"; do
    IFS='|' read -r domain key _type _value <<<"$entry"
    printf "• %-45s " "$domain $key"
    if [ -n "${latest:-}" ]; then
      restore_or_delete "$domain" "$key" "$latest"
    else
      defaults delete "$domain" "$key" >/dev/null 2>&1 || true
    fi
    echo "${GREEN}OK${RESET}"
  done

  restart_processes
  echo
  echo "${GREEN}Selesai revert. Logout/restart mungkin diperlukan.${RESET}"
  pause
}

show_status() {
  print_header
  echo "${YELLOW}Mode: Status${RESET}"
  echo "Menampilkan nilai saat ini (jika ada):"
  echo

  for entry in "${CONFIGS[@]}"; do
    IFS='|' read -r domain key _type _value <<<"$entry"
    local val
    if val=$(defaults read "$domain" "$key" 2>/dev/null); then
      printf "%-48s = %s\n" "$domain $key" "$val"
    else
      printf "%-48s = %s\n" "$domain $key" "— (tidak diset)"
    fi
  done

  echo
  echo "Catatan:"
  echo "- Beberapa nilai mungkin tidak muncul karena versi macOS atau app tidak menggunakan key tersebut."
  pause
}

menu() {
  while true; do
    print_header
    echo "Pilih aksi:"
    echo "  1) Disable Animations"
    echo "  2) Revert to Default"
    echo "  3) Status"
    echo "  4) Keluar"
    echo
    read -rp "Masukkan pilihan [1-4]: " choice
    case "${choice:-}" in
      1) disable_animations ;;
      2) revert_animations ;;
      3) show_status ;;
      4) echo "Bye!"; exit 0 ;;
      *) echo "${RED}Pilihan tidak valid.${RESET}"; sleep 1 ;;
    esac
  done
}

menu
