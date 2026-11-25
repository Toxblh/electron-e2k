// e2k Electron smoke test: versions, renderer page, preload + contextBridge, IPC both ways, JIT/wasm in renderer,
// optional native addon, screenshot via capturePage. Results: $SMOKE_OUT/result.json and shot.png.
const { app, BrowserWindow, ipcMain } = require('electron');
const fs = require('fs'), path = require('path'), os = require('os');
const OUT = process.env.SMOKE_OUT || path.join(os.tmpdir(), 'e2k-smoke');
fs.mkdirSync(OUT, { recursive: true });
const res = { main: { versions: process.versions, arch: process.arch, platform: process.platform } };
try { const a = require(process.env.SMOKE_ADDON || './addon/build/Release/e2kaddon.node'); res.addon = { hello: a.hello(), add: a.add(2, 40) }; }
catch (e) { res.addon = { error: String(e.message).slice(0, 300) }; }
function t(f) { const s = process.hrtime.bigint(); const r = f(); return [r, Number(process.hrtime.bigint() - s) / 1e6]; }
res.main.fib30 = t(() => { const fib = n => n < 2 ? n : fib(n - 1) + fib(n - 2); return fib(30); });
ipcMain.handle('ping', (e, x) => ({ pong: x * 2, from: 'main', pid: process.pid }));
ipcMain.on('report', async (e, r) => {
  res.renderer = r;
  try { const img = await win.webContents.capturePage(); fs.writeFileSync(path.join(OUT, 'shot.png'), img.toPNG()); res.shot = 'ok'; }
  catch (err) { res.shot = String(err); }
  fs.writeFileSync(path.join(OUT, 'result.json'), JSON.stringify(res, null, 1));
  console.log('SMOKE-RESULT ' + JSON.stringify(res));
  if (!process.env.SMOKE_STAY) setTimeout(() => app.quit(), 1500);
});
let win;
app.whenReady().then(() => {
  win = new BrowserWindow({ width: 900, height: 700, webPreferences: { preload: path.join(__dirname, 'preload.js') } });
  win.loadFile('index.html');
});
app.on('window-all-closed', () => app.quit());
