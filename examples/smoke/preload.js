const { contextBridge, ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld('e2k', {
  versions: { ...process.versions }, arch: process.arch,
  ping: x => ipcRenderer.invoke('ping', x),
  report: r => ipcRenderer.send('report', r),
});
