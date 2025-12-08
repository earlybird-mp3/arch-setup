#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/arch-setup}"
PKG_DIR="$REPO_DIR/packages"

echo "[*] Starte Arch-Hyprland-Setup aus $REPO_DIR"

# 1. Sicherstellen, dass wir auf Arch sind
if ! grep -qi "arch" /etc/os-release; then
  echo "Dieses Script ist nur für Arch Linux gedacht."
  exit 1
fi

# 2. System aktualisieren
echo "[*] System-Update..."
sudo pacman -Syu --noconfirm

# 3. Basis-Pakete, damit AUR (falls benutzt) funktioniert
echo "[*] Installiere Basis-Pakete (git, base-devel)..."
sudo pacman -S --needed --noconfirm git base-devel

# Helper-Funktion: Liste aus Datei lesen (ohne Kommentare/Leerzeilen)
read_pkg_list() {
  local file="$1"
  mapfile -t _pkgs < <(grep -vE '^\s*($|#)' "$file" || true)
  printf '%s\n' "${_pkgs[@]}"
}

# 4. Offizielle Pacman-Pakete installieren
if [[ -f "$PKG_DIR/pacman.txt" ]]; then
  echo "[*] Installiere Pacman-Pakete aus $PKG_DIR/pacman.txt ..."
  mapfile -t pkgs < <(read_pkg_list "$PKG_DIR/pacman.txt")
  if ((${#pkgs[@]})); then
    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  else
    echo "[*] (Liste ist leer, überspringe Pacman-Pakete)"
  fi
else
  echo "[!] $PKG_DIR/pacman.txt nicht gefunden – überspringe Pacman-Pakete."
fi

# 5. AUR-Helper yay installieren (falls wir später AUR nutzen wollen)
if ! command -v yay >/dev/null 2>&1; then
  echo "[*] Installiere yay (AUR Helper)..."
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
  (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

# 6. AUR-Pakete installieren (falls in aur.txt eingetragen)
if [[ -f "$PKG_DIR/aur.txt" ]]; then
  echo "[*] Installiere AUR-Pakete aus $PKG_DIR/aur.txt ..."
  mapfile -t aurpkgs < <(read_pkg_list "$PKG_DIR/aur.txt")
  if ((${#aurpkgs[@]})); then
    yay -S --needed --noconfirm "${aurpkgs[@]}"
  else
    echo "[*] (Liste ist leer, überspringe AUR-Pakete)"
  fi
else
  echo "[!] $PKG_DIR/aur.txt nicht gefunden – überspringe AUR-Pakete."
fi

echo
echo "[+] Paket-Setup fertig."
echo "    Nächste Schritte (manuell):"
echo "      - NetworkManager aktivieren: sudo systemctl enable --now NetworkManager"
echo "      - Hyprland-Konfig schreiben (~/.config/hypr/hyprland.conf)"
echo "      - Waybar/Rofi/Ghostty/Dolphin konfigurieren"
echo
echo "Danach kannst du dich in Hyprland einloggen (z.B. über TTY: 'Hyprland' starten)."
