#!/bin/sh
# Запуск готового x86-приложения Electron (его JS) на этом Electron: ./run-app.sh <каталог resources приложения> [ключи]
# Копия пакета (жёсткие ссылки) в ~/.cache/electron-e2k-apps/<имя>, где resources/ — от приложения.
set -e
D=$(cd "$(dirname "$0")" && pwd); R=$(cd "$1" && pwd); shift
N=$(basename "$(dirname "$R")"); A=${XDG_CACHE_HOME:-$HOME/.cache}/electron-e2kv4-apps/$N
rm -rf "$A"; mkdir -p "$A"; cp -al "$D"/. "$A"/ 2>/dev/null || cp -a "$D"/. "$A"/
for f in electron chrome_crashpad_handler; do rm -f "$A/$f"; cp "$D/$f" "$A/$f"; done
rm -rf "$A/resources"; cp -a "$R" "$A/resources"; "$A/setup.sh" >/dev/null
exec "$A/electron.sh" "$@"
