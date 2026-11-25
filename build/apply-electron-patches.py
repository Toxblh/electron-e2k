#!/usr/bin/python3
# apply-electron-patches.py <src> : apply electron/patches/* to a non-gclient (ALT tarball + e2k) Chromium tree.
# Every patch: git apply --reject (in-place, breaks hard links). Log: ok / rejects per patch.
import json, os, subprocess, sys
src = os.path.abspath(sys.argv[1]); skip = {'squirrel.mac', 'ReactiveObjC', 'reclient-configs'}
cfg = json.load(open(os.path.join(src, 'electron/patches/config.json')))
tot = bad = 0
for e in cfg:
    pdir = os.path.join(src, e['patch_dir'][len('src/'):]); repo = os.path.join(src, e['repo'][len('src'):].lstrip('/'))
    name = os.path.basename(pdir)
    if name in skip: continue
    order = [l.strip() for l in open(os.path.join(pdir, '.patches')) if l.strip()]
    for p in order:
        tot += 1
        r = subprocess.run(['git', 'apply', '--reject', '--whitespace=nowarn', '-p1', os.path.join(pdir, p)],
                           cwd=repo, capture_output=True, text=True)
        if r.returncode:
            bad += 1
            errs = [l for l in r.stderr.splitlines() if 'Rejected' in l or 'error' in l or 'does not exist' in l]
            print('FAIL %s/%s' % (name, p)); [print('   ', l) for l in errs[:12]]
print('patches %d, with problems %d' % (tot, bad))
