#!/bin/sh
# Запуск готового x86-приложения Electron (Obsidian, TickTick, ...) на этом Electron:
#   ./run-app.sh <каталог resources приложения> [ключи]
# Например: распаковать obsidian_*.deb и указать opt/Obsidian/resources.
# Создаётся копия пакета (жёсткие ссылки) в ~/.cache/electron-e2k-apps/<имя>, где resources/ — от приложения.
set -e
D=$(cd "$(dirname "$0")" && pwd); R=$(cd "$1" && pwd); shift
N=$(basename "$(dirname "$R")"); A=${XDG_CACHE_HOME:-$HOME/.cache}/electron-e2k-apps/$N
rm -rf "$A"; mkdir -p "$A"; cp -al "$D"/. "$A"/ 2>/dev/null || cp -a "$D"/. "$A"/
rm -rf "$A/resources"; cp -a "$R" "$A/resources"
# x86-модули .node в app.asar.unpacked не загрузятся на e2k: их надо пересобрать (см. README)
find "$A/resources" -name '*.node' | while read f; do file "$f" | grep -q 'x86-64' && echo "внимание: x86-модуль $f"; done
exec "$A/electron.sh" "$@"
