# 🍎 Utilitas & Konfigurasi macOS

[Bahasa Indonesia](#panduan-bahasa-indonesia) | [English](#english-guide)

---

<a name="panduan-bahasa-indonesia"></a>
## 🇮🇩 Panduan Bahasa Indonesia

Kumpulan skrip dan konfigurasi untuk menyesuaikan dan mengatur lingkungan macOS Anda agar lebih produktif dan estetis.

### 📂 Struktur Folder
- `macOS/`: Berisi skrip utilitas sistem (animasi, setup terminal).
- `apps/`: Berisi konfigurasi untuk berbagai aplikasi (Browser, iTerm, JDownloader, dll).

### 🛠️ Alat yang Disertakan

#### 1. Alat Animasi Mac (Mac Animations Tool)
Script interaktif untuk mengelola kecepatan animasi sistem. Sangat berguna untuk membuat antarmuka macOS terasa lebih cepat (snappy) atau mengembalikan pengaturan ke semula dengan aman.

**Fitur:**
- **Nonaktifkan**: Minimalkan/matikan animasi sistem untuk kinerja UI yang lebih cepat.
- **Kembalikan**: Pulihkan pengaturan default menggunakan backup atau standar sistem.
- **Status**: Cek status preferensi animasi saat ini.

**Cara Penggunaan:**
```bash
cd macOS
chmod +x mac_animations_tool.sh
./mac_animations_tool.sh
```

#### 2. Setup Terminal Stack
Installer otomatis untuk mendapatkan pengalaman terminal yang modern dan canggih dengan sekali jalan.

**Menginstall:**
- **Homebrew**: Manajer paket untuk macOS.
- **iTerm2**: Emulator terminal pengganti Terminal bawaan.
- **Oh My Posh**: Mesin tema prompt yang cantik dan informatif.
- **Fastfetch**: Penambil informasi sistem (alternatif neofetch).
- **Meslo Nerd Font**: Font khusus dengan dukungan ikon glyph.
- **Konfigurasi Zsh**: Mengatur alias dan tema agar langsung siap pakai.

**Cara Penggunaan:**
```bash
cd macOS
chmod +x setup_terminal_stack.sh
./setup_terminal_stack.sh
```

### ⚙️ Konfigurasi Aplikasi
Di dalam folder `apps/`, Anda akan menemukan pengaturan untuk aplikasi tertentu:
- **Apps/Browser**: Tema Stylus dan ekstensi.
- **Apps/iTerm**: Profil warna dan pengaturan jendel iTerm2.
- **Apps/JDownloader**: Konfigurasi untuk JDownloader.
- **Apps/MS-Office**: Pengaturan untuk Microsoft Office.

---

<a name="english-guide"></a>
## 🇺🇸 English Guide

A collection of scripts and tools to customize and configure your macOS environment for better productivity and aesthetics.

### 📂 Folder Structure
- `macOS/`: Contains system utility scripts (animations, terminal setup).
- `apps/`: Contains configurations for various apps (Browser, iTerm, JDownloader, etc).

### 🛠️ Included Tools

#### 1. Mac Animations Tool
Interactive utility to manage system animation speeds. Useful for speeding up the UI for a snappier feel or reverting changes safely.

**Features:**
- **Disable**: Minimize/disable system animations.
- **Revert**: Restore default settings using backups or system defaults.
- **Status**: Check current status of animation preferences.

**Usage:**
```bash
cd macOS
chmod +x mac_animations_tool.sh
./mac_animations_tool.sh
```

#### 2. Terminal Stack Setup
Automated installer for a modern terminal experience.

**Installs:**
- **Homebrew**: The missing package manager for macOS.
- **iTerm2**: Terminal emulator.
- **Oh My Posh**: Prompt theme engine.
- **Fastfetch**: System information fetcher.
- **Meslo Nerd Font**: Font with icon support.
- **Zsh Configuration**: Sets up aliases and themes.

**Usage:**
```bash
cd macOS
chmod +x setup_terminal_stack.sh
./setup_terminal_stack.sh
```

### ⚙️ App Configurations
Check the `apps/` folder for specific configs:
- **Apps/Browser**: Stylus themes and extensions.
- **Apps/iTerm**: iTerm2 profiles and window settings.
- **Apps/JDownloader**: Download manager configs.
- **Apps/MS-Office**: Microsoft Office settings.

---

> [!NOTE]
> **Penting / Important:**
>
> Jalankan skrip ini sebagai pengguna biasa. `sudo` tidak diperlukan dan umumnya tidak disarankan kecuali diminta secara eksplisit.
>
> Run these scripts as a normal user. `sudo` is not required and generally discouraged unless explicitly requested.