#!/bin/bash

set -euo pipefail

RPM_URL="https://github.com/2dust/v2rayN/releases/download/7.17.0/v2rayN-linux-rhel-arm64.rpm"
RPM_FILE="${RPM_URL##*/}"
BASE_URL="https://raw.githubusercontent.com/Tinkerbells/v2rayn-install/main"
TEMP_DIR="$(mktemp -d -t v2rayn-install-XXXX)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_TARGET="$HOME/.local/share/applications/v2rayN.desktop"
ICON_TARGET="/usr/share/icons/hicolor/128x128/apps/v2rayN.png"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Установка v2rayN..."

if ! command -v dnf >/dev/null 2>&1; then
  echo "Ошибка: требуется пакетный менеджер dnf"
  exit 1
fi

if command -v wget >/dev/null 2>&1; then
  DOWNLOAD_CMD=(wget -q -O)
elif command -v curl >/dev/null 2>&1; then
  DOWNLOAD_CMD=(curl -s -L -o)
else
  echo "Ошибка: не найден wget или curl для скачивания файлов"
  exit 1
fi

ARCH="$(uname -m)"
if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
  echo "Предупреждение: пакет предназначен для arm64/aarch64, текущая архитектура: $ARCH"
fi

cd "$TEMP_DIR"
echo "Скачивание rpm пакета v2rayN..."
"${DOWNLOAD_CMD[@]}" "$RPM_FILE" "$RPM_URL"

if [ ! -f "$SCRIPT_DIR/v2rayn-run" ]; then
  echo "Загрузка вспомогательных файлов..."
  "${DOWNLOAD_CMD[@]}" "v2rayn-run" "$BASE_URL/v2rayn-run"
  "${DOWNLOAD_CMD[@]}" "v2rayN.desktop" "$BASE_URL/v2rayN.desktop"
  "${DOWNLOAD_CMD[@]}" "v2rayN.png" "$BASE_URL/v2rayN.png"
  SCRIPT_DIR="$TEMP_DIR"
fi

echo "Установка rpm через dnf (потребуются права sudo)..."
sudo dnf install -y "$RPM_FILE"

echo "Установка скрипта запуска..."
sudo install -m 755 "$SCRIPT_DIR/v2rayn-run" /usr/bin/v2rayn-run

echo "Установка desktop файла..."
mkdir -p "$(dirname "$DESKTOP_TARGET")"
install -m 644 "$SCRIPT_DIR/v2rayN.desktop" "$DESKTOP_TARGET"

echo "Установка иконки..."
sudo mkdir -p "$(dirname "$ICON_TARGET")"
sudo install -m 644 "$SCRIPT_DIR/v2rayN.png" "$ICON_TARGET"

sudo gtk-update-icon-cache /usr/share/icons/hicolor/ 2>/dev/null || true
update-desktop-database "$(dirname "$DESKTOP_TARGET")" 2>/dev/null || true

echo "Установка v2rayN завершена успешно!"
echo "Запуск: из меню приложений или командой '/opt/v2rayN/v2rayN'"
