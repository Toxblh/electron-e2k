#!/bin/sh
# vsc-setup.sh: VS Code 1.147 (x86 release, JS unchanged) on the e2k Electron: package copy with VS Code's resources,
# native modules rebuilt for e2k (N-API, node-gyp on the Elbrus) put in place of the x86 ones.
T=/tmp/elnw; V=$T/vscode-e2k; NB=$T/natbuild
rm -rf $V && cp -al $T/electron-v46n-e2k $V && rm -rf $V/resources && cp -a $T/vsc/VSCode-linux-x64/resources $V/resources
U=$V/resources/app/node_modules.asar.unpacked
put() { if [ -f "$NB/$1" ]; then cp "$NB/$1" "$U/$2" && echo "ok  $2"; else echo "MISSING $1"; fi; }
put kerberos-2.1.1/build/Release/kerberos.node kerberos/build/Release/kerberos.node
put native-is-elevated-0.9.0/build/Release/iselevated.node native-is-elevated/build/Release/iselevated.node
put node-pty-1.2.0-beta.18/build/Release/pty.node node-pty/build/Release/pty.node
[ -f $NB/node-pty-1.2.0-beta.18/build/Release/spawn-helper ] && cp $NB/node-pty-1.2.0-beta.18/build/Release/spawn-helper $U/node-pty/build/Release/ 2>/dev/null
put parcel-watcher-2.5.6/build/Release/watcher.node @parcel/watcher/build/Release/watcher.node
put vscode-native-watchdog-1.4.6/build/Release/watchdog.node @vscode/native-watchdog/build/Release/watchdog.node
put vscode-policy-watcher-1.7.0/build/Release/vscode-policy-watcher.node @vscode/policy-watcher/build/Release/vscode-policy-watcher.node
put vscode-spdlog-0.15.8/build/Release/spdlog.node @vscode/spdlog/build/Release/spdlog.node
put vscode-sqlite3-5.1.12-vscode/build/Release/vscode-sqlite3.node @vscode/sqlite3/build/Release/vscode-sqlite3.node
put native-keymap-3.3.9/build/Release/keymapping.node native-keymap/build/Release/keymapping.node
find $U -name '*.node' | while read f; do file -b "$f" | grep -q x86-64 && echo "x86 left: ${f#$U/}"; done
