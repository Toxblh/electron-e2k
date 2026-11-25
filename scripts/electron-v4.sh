#!/bin/sh
# Запуск Electron для e2k-v4: без песочницы, программная отрисовка. Сначала один раз ./setup.sh.
D=$(cd "$(dirname "$0")" && pwd)
exec "$D/electron" --no-sandbox ${ELECTRON_GPU:---disable-gpu} "$@"
