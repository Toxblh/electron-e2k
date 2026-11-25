#!/bin/sh
# lcc 1.29.16 does not instantiate a function template that is only named in a default template argument of another
# function template (node-addon-api: AttachData<FreeType, finalizer = default_[basic_]finalizer<FreeType>>) ->
# undefined symbol at dlopen. Workaround: name it once in the body of AttachData.
D=$HOME/node26/dist/node-v26.13.1-linux-e2k-b3; G=$D/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js
cd /tmp/elnw/natbuild
for h in */node_modules/node-addon-api/napi-inl.h; do python3 - "$h" <<'PY'
import sys, re
p = sys.argv[1]; s = open(p).read()
if 'e2k-lcc' in s: sys.exit()
m = re.search(r'(template <\s*typename FreeType,\s*\w+ finalizer = (default_\w*finalizer)<FreeType>>\s*inline napi_status AttachData\([^)]*\) \{\n)', s)
if not m: print('no match', p); sys.exit()
s = s[:m.end()] + '  (void)&%s<FreeType>;  // e2k-lcc: force the instantiation (lcc 1.29.16)\n' % m.group(2) + s[m.end():]
open(p, 'w').write(s); print('patched', p)
PY
done
for n in vscode-spdlog-0.15.8 node-pty-1.2.0-beta.18 parcel-watcher-2.5.6 vscode-policy-watcher-1.7.0 kerberos-2.1.1; do
  echo "=== $n"; (cd $n && JOBS=3 nice -n 19 taskset -c 3-5 $D/bin/node $G rebuild --nodedir=$HOME/node26/headers > ../$n-3.log 2>&1; echo rc=$?)
done
