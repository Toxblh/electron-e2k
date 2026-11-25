#!/bin/sh
# Запуск Electron для e2k: библиотеки из каталога пакета, без песочницы (chrome-sandbox не собран),
# программная отрисовка (GPU-процесс выключен). Использование: ./electron.sh <каталог приложения | app.asar> [ключи]
D=$(cd "$(dirname "$0")" && pwd)
export LD_LIBRARY_PATH="$D${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$D/electron" --no-sandbox ${ELECTRON_GPU:---disable-gpu} "$@"
