"use strict";
const electron = require("electron");
const preload = require("@electron-toolkit/preload");
const evtbWindowApi = {
  isMaximized: () => electron.ipcRenderer.invoke("evtb:isMaximized"),
  maximize: () => electron.ipcRenderer.invoke("evtb:maximize"),
  minimize: () => electron.ipcRenderer.invoke("evtb:minimize"),
  restore: () => electron.ipcRenderer.invoke("evtb:restore"),
  close: () => electron.ipcRenderer.invoke("evtb:close"),
  getPlatform: () => electron.ipcRenderer.invoke("evtb:getPlatform"),
  isUbuntu: () => electron.ipcRenderer.invoke("evtb:isUbuntu"),
  osRelease: () => electron.ipcRenderer.invoke("evtb:osRelease"),
  checkForUpdates: () => electron.ipcRenderer.invoke("evtb:checkForUpdates"),
  getUpdateStatus: () => electron.ipcRenderer.invoke("evtb:getUpdateStatus"),
  getMultiFilePath: (defaultPath) => electron.ipcRenderer.invoke("evtb:getMultiFilePath", defaultPath),
  getFilePath: (defaultPath) => electron.ipcRenderer.invoke("evtb:getFilePath", defaultPath),
  getFolderPath: (defaultPath) => electron.ipcRenderer.invoke("evtb:getFolderPath", defaultPath),
  getVersion: () => electron.ipcRenderer.invoke("evtb:getVersion"),
  getLocalImagePath: (defaultPath) => electron.ipcRenderer.invoke("evtb:getLocalImagePath", defaultPath),
  getLocalVideoPath: (defaultPath) => electron.ipcRenderer.invoke("evtb:getLocalVideoPath", defaultPath),
  openUrl: (url) => electron.ipcRenderer.invoke("evtb:openUrl", url),
  openPDF: () => electron.ipcRenderer.invoke("evtb:openPDF"),
  openMLPdf: (fileName) => electron.ipcRenderer.invoke("evtb:openMLPdf", fileName),
  getVGAType: () => electron.ipcRenderer.invoke("evtb:getVGAType"),
  isWSL: () => electron.ipcRenderer.invoke("evtb:isWSL"),
  isArm64: () => electron.ipcRenderer.invoke("evtb:isArm64")
  // getOSInfo: () => ipcRenderer.invoke('evtb:getOSInfo'),
};
const api = {};
if (process.contextIsolated) {
  try {
    electron.contextBridge.exposeInMainWorld("electron", preload.electronAPI);
    electron.contextBridge.exposeInMainWorld("api", api);
    electron.contextBridge.exposeInMainWorld("evtb", evtbWindowApi);
  } catch (error) {
    console.error(error);
  }
} else {
  window.electron = preload.electronAPI;
  window.api = api;
  window.evtb = evtbWindowApi;
}
