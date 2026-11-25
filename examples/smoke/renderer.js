(async () => {
  const v = window.e2k.versions, out = {};
  document.getElementById('info').innerHTML = '<table>' + ['electron', 'chrome', 'node', 'v8'].map(k => `<tr><td>${k}</td><td><b>${v[k]}</b></td></tr>`).join('') + `<tr><td>arch</td><td><b>${window.e2k.arch}</b></td></tr></table>`;
  let s = performance.now(); const fib = n => n < 2 ? n : fib(n - 1) + fib(n - 2); out.fib30 = [fib(30), +(performance.now() - s).toFixed(1)];
  s = performance.now(); const a = Array.from({ length: 200000 }, (_, i) => (i * 7919) % 100003); a.sort((x, y) => x - y); out.sort = +(performance.now() - s).toFixed(1);
  out.json = JSON.parse(JSON.stringify({ x: [1, 2, { y: 'ю' }] })).x[2].y;
  out.regexp = 'Эльбрус-8СВ 2026'.match(/(\p{L}+)-(\d+)(\p{L}+)/u).slice(1);
  out.intl = new Intl.NumberFormat('ru-RU').format(1234567.891);
  try { const w = await WebAssembly.instantiate(new Uint8Array([0,97,115,109,1,0,0,0,1,7,1,96,2,127,127,1,127,3,2,1,0,7,7,1,3,97,100,100,0,0,10,9,1,7,0,32,0,32,1,106,11])); out.wasm = w.instance.exports.add(20, 22); } catch (e) { out.wasm = String(e); }
  out.ipc = await window.e2k.ping(21);
  const c = document.getElementById('c').getContext('2d'); const g = c.createLinearGradient(0, 0, 300, 0); g.addColorStop(0, '#2a4d9b'); g.addColorStop(1, '#e05d2b');
  c.fillStyle = g; c.fillRect(0, 0, 300, 120); c.fillStyle = '#fff'; c.font = '28px sans-serif'; c.fillText('e2k canvas', 70, 70);
  out.userAgent = navigator.userAgent;
  document.getElementById('out').textContent = JSON.stringify(out, null, 1);
  await new Promise(r => setTimeout(r, 500));
  window.e2k.report(out);
})();
