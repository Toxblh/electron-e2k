#!/bin/sh
# ccwrap: C compiler for the sqlite3 module build: sqlite3.c (the amalgamation) comes precompiled from the x86 cross
# clang (lcc -O3 on it takes ~an hour of CPU); everything else goes to cc (lcc).
for a in "$@"; do case $a in *sqlite3.c) is=1;; esac; done
if [ -n "$is" ]; then
  o=""; mf=""; p=""; for a in "$@"; do [ "$p" = "-o" ] && o=$a; [ "$p" = "-MF" ] && mf=$a; p=$a; done
  cp /tmp/elnw/sqlite3.prebuilt.o "$o" || exit 1
  [ -n "$mf" ] && echo "$o: " > "$mf"
  exit 0
fi
exec cc "$@"
