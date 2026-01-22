#!/bin/bash

set -euo pipefail

RPM_URL="https://github.com/2dust/v2rayN/releases/download/7.17.1/v2rayN-linux-rhel-64.rpm"
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

download() {
  local out="$1" url="$2" ok=1

  if command -v wget >/dev/null 2>&1; then
    if wget --tries=3 --waitretry=2 --retry-connrefused --no-verbose -O "$out" "$url"; then
      ok=0
    fi
  fi

  if (( ok != 0 )) && command -v curl >/dev/null 2>&1; then
    if curl -fL --retry 3 --retry-all-errors --retry-delay 2 -o "$out" "$url"; then
      ok=0
    fi
  fi

  return $ok
}

if ! command -v wget >/dev/null 2>&1 && ! command -v curl >/dev/null 2>&1; then
  echo "Ошибка: не найден wget или curl для скачивания файлов"
  exit 1
fi

ARCH="$(uname -m)"
if [[ "$ARCH" != "x86_64" && "$ARCH" != "amd64" ]]; then
  echo "Предупреждение: пакет предназначен для x86_64/amd64, текущая архитектура: $ARCH"
fi

cd "$TEMP_DIR"

# 1) Явный путь до rpm, если передан аргументом
if [[ ${1-} && -f $1 ]]; then
  echo "Использую локальный rpm: $1"
  cp "$1" "$RPM_FILE"
# 2) Локальный файл рядом со скриптом
elif [[ -f "$SCRIPT_DIR/$RPM_FILE" ]]; then
  echo "Использую локальный rpm: $SCRIPT_DIR/$RPM_FILE"
  cp "$SCRIPT_DIR/$RPM_FILE" "$RPM_FILE"
# 3) Локальный файл в текущей директории запуска, если она не TEMP_DIR
elif [[ -f "$PWD/$RPM_FILE" && "$PWD" != "$TEMP_DIR" ]]; then
  echo "Использую локальный rpm: $PWD/$RPM_FILE"
  cp "$PWD/$RPM_FILE" "$RPM_FILE"
else
  echo "Скачивание rpm пакета v2rayN..."
  if ! download "$RPM_FILE" "$RPM_URL"; then
    echo "Не удалось скачать rpm (ошибка сети, например \"Recv failure: Connection reset by peer\"). Попробуйте ещё раз позже или проверьте соединение/прокси."
    exit 1
  fi
fi

if [ ! -f "$SCRIPT_DIR/v2rayn-run" ]; then
  echo "Загрузка вспомогательных файлов..."
  download "v2rayn-run" "$BASE_URL/v2rayn-run"
  download "v2rayN.desktop" "$BASE_URL/v2rayN.desktop"
  download "v2rayN.png" "$BASE_URL/v2rayN.png"
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
