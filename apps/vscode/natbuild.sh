#!/bin/sh
# natbuild.sh: rebuild VS Code's native Node modules for e2k with node-gyp (node26 for e2k as the gyp host,
# N-API/NAN against the node26 headers dir), sources from npm (same versions as in VS Code 1.147).
D=$HOME/node26/dist/node-v26.13.1-linux-e2k-b3; G=$D/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js
W=/tmp/elnw/natbuild; rm -rf $W; mkdir -p $W; cd $W
mkdir -p common/node_modules; for p in node-addon-api nan; do mkdir -p common/node_modules/$p; tar xzf ../vsc/natsrc/$p-*.tgz -C common/node_modules/$p --strip-components=1; done
for t in ../vsc/natsrc/*.tgz; do n=$(basename $t .tgz); case $n in node-addon-api*|nan-*) continue;; esac
  mkdir -p $n && tar xzf $t -C $n --strip-components=1 && cp -a common/node_modules $n/
  echo "=== $n"; (cd $n && JOBS=4 nice -n 19 taskset -c 0-3 $D/bin/node $G rebuild --nodedir=$HOME/node26/headers > ../$n.log 2>&1; echo "rc=$?"; find build/Release -maxdepth 1 -name '*.node')
done
