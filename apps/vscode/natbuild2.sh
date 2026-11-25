#!/bin/sh
D=$HOME/node26/dist/node-v26.13.1-linux-e2k-b3; G=$D/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js
cd /tmp/elnw/natbuild
echo "=== sqlite3"; (cd vscode-sqlite3-5.1.12-vscode && NODE_PATH=$D/lib/node_modules/npm/node_modules JOBS=4 nice -n 19 taskset -c 0-3 $D/bin/node $G rebuild --nodedir=$HOME/node26/headers > ../sqlite3-2.log 2>&1; echo rc=$?; find build/Release -maxdepth 1 -name '*.node')
echo "=== native-keymap"; (cd native-keymap-3.3.9 && PKG_CONFIG_PATH=/tmp/elnw/xkbf/usr/lib64/pkgconfig CFLAGS=-I/tmp/elnw/xkbf/usr/include CXXFLAGS=-I/tmp/elnw/xkbf/usr/include JOBS=4 nice -n 19 taskset -c 0-3 $D/bin/node $G rebuild --nodedir=$HOME/node26/headers > ../keymap-2.log 2>&1; echo rc=$?; find build/Release -maxdepth 1 -name '*.node')
