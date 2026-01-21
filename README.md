# v2rayN Linux Installer (RHEL/Fedora x86_64)

Скрипты для установки клиента **v2rayN** из официального rpm пакета.

## Быстрая установка

```bash
curl -fsSL https://raw.githubusercontent.com/Tinkerbells/v2rayn-install/main/install.sh | bash
```

## Что делает установщик

- Скачивает rpm `v2rayN-linux-rhel-64.rpm` (релиз 7.17.1) и ставит его через `dnf`
- Кладёт скрипт запуска `/usr/bin/v2rayn-run` (простая обёртка на `/opt/v2rayN/v2rayN`)
- Создаёт desktop-файл `~/.local/share/applications/v2rayN.desktop`
- Устанавливает иконку `/usr/share/icons/hicolor/128x128/apps/v2rayN.png`
- Обновляет кеш иконок и базу desktop-файлов

## Требования

- Linux на базе RHEL/Fedora с `dnf`
- Архитектура x86_64/amd64 (пакет именно под неё)
- `sudo` права, `wget` или `curl` для загрузки

## Ручная установка из репозитория

```bash
git clone <repository-url>
cd v2rayn-install
./install.sh
```

## Запуск

- Из меню приложений: **v2rayN**
- Из терминала: `v2rayn-run` или напрямую `/opt/v2rayN/v2rayN`

## Удаление

```bash
sudo dnf remove -y v2rayN
sudo rm -f /usr/bin/v2rayn-run
rm -f ~/.local/share/applications/v2rayN.desktop
sudo rm -f /usr/share/icons/hicolor/128x128/apps/v2rayN.png
```

## Структура файлов

```
.
├── install.sh          # Основной установщик
├── v2rayn-run          # Скрипт запуска
├── v2rayN.desktop      # Desktop файл
├── v2rayN.png          # Иконка приложения
└── README.md           # Документация
```
