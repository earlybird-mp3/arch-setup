#!/usr/bin/env bash
set -euo pipefail

# REPO_DIR = eine Ebene über scripts/
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link() {
  local src="$REPO_DIR/dotfiles/$1"
  local dest="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    echo "[!] Quelle existiert nicht: $src"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  echo "[+] $dest -> $src"
}

echo "[*] Verlinke Dotfiles aus $REPO_DIR/dotfiles"

# ==== Links ====
link ".config/hypr" ".config/hypr"
link ".config/waybar" ".config/waybar"
link ".config/rofi" ".config/rofi"
# ===========================================================

echo "[*] Dotfiles-Verlinkung abgeschlossen."
