#!/bin/sh
# Second lcc 1.29.16 instance of the same bug: [Basic]Env::SetInstanceData<T, fini = DefaultFini<T>> -> undefined
# Napi::[Basic]Env::DefaultFini<T> at run time. Name DefaultFini / DefaultFiniWithHint in the bodies.
D=$HOME/node26/dist/node-v26.13.1-linux-e2k-b3; G=$D/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js
cd /tmp/elnw/natbuild
for h in */node_modules/node-addon-api/napi-inl.h; do python3 - "$h" <<'PY'
import sys, re
p = sys.argv[1]; s = open(p).read()
if 'e2k-lcc2' in s: sys.exit()
n = 0
for cls in ('Env', 'BasicEnv'):
    a = 'inline void %s::SetInstanceData(T* data) const {\n' % cls
    if a in s: s = s.replace(a, a + '  (void)&%s::DefaultFini<T>;  // e2k-lcc2: force the instantiation (lcc 1.29.16)\n' % cls); n += 1
    b = 'inline void %s::SetInstanceData(DataType* data, HintType* hint) const {\n' % cls
    if b in s: s = s.replace(b, b + '  (void)&%s::DefaultFiniWithHint<DataType, HintType>;  // e2k-lcc2\n' % cls); n += 1
open(p, 'w').write(s); print('patched', n, p)
PY
done
for n in $(grep -rl "SetInstanceData" --include='*.cc' --include='*.cpp' --include='*.h' . 2>/dev/null | grep -v node_modules | cut -d/ -f2 | sort -u); do
  echo "=== $n"; (cd $n && JOBS=3 nice -n 19 taskset -c 3-5 $D/bin/node $G $([ -d build ] && echo build || echo rebuild) --nodedir=$HOME/node26/headers > ../$n-4.log 2>&1; echo rc=$?)
done
