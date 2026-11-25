#!/bin/sh
# pack-electron.sh <out dir> <dest dir name> : (inside the xs container) runtime files of an Electron Linux build
# (like dist.zip) for e2k, binaries stripped, into /tmp/<name>.tar.zst (= /tmp/xs-tmp on the host)
set -e
O=$1; N=$2; S=/opt/mcst/lcc-1.29.16.e2k-v5.8c2.linux-6.1/binutils/bin/e2k-linux-strip
D=/tmp/pack-$N; rm -rf $D; mkdir -p $D/$N; cd $O
for f in electron chrome_crashpad_handler chrome-sandbox libffmpeg.so libEGL.so libGLESv2.so libvulkan.so.1 \
  icudtl.dat snapshot_blob.bin v8_context_snapshot.bin resources.pak chrome_100_percent.pak chrome_200_percent.pak \
  resources locales LICENSE LICENSES.chromium.html version; do [ -e $f ] && cp -a $f $D/$N/; done
rm -f $D/$N/locales/*.info
for f in electron chrome_crashpad_handler libffmpeg.so libEGL.so libGLESv2.so libvulkan.so.1; do
  [ -f $D/$N/$f ] && $S --strip-unneeded $D/$N/$f; done
cd $D && tar cf - $N | zstd -q -T16 -12 -o /tmp/$N.tar.zst -f; ls -la /tmp/$N.tar.zst; du -sh $D/$N; rm -rf $D
