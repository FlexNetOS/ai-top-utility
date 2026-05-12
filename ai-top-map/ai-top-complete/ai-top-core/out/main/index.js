"use strict";
const electron = require("electron");
const path = require("path");
const utils = require("@electron-toolkit/utils");
const electronUpdater = require("electron-updater");
path.join(__dirname, "../../resources/icon.png");
const { execFile, exec, spawn, execSync } = require("child_process");
const sudo = require("sudo-prompt");
const fs = require("fs");
function getUbuntuVersion() {
  return execSync("lsb_release -a").toString();
}
const versionInfo = getUbuntuVersion();
({
  hostname: "",
  //獲取主機名
  cpuModel: "",
  //獲取CPU型號
  username: "",
  //獲取用戶名
  version: "",
  //獲取系統版本
  gpuModel: [],
  //獲取GPU型號
  cpu: 0,
  //獲取CPU使用率
  countCPUs: 0,
  //獲取CPU核心數
  freemem: 0,
  //獲取空閒內存
  totalmem: 0,
  //獲取總內存
  freememPercentage: 0,
  //獲取空閒內存百分比
  platform: process.platform,
  //獲取平台名稱
  loadavg: 0
  //獲取系統平均負載(每分鐘)
});
let dialogMultiFileOptions = {
  // defaultPath: 'c:/',
  filters: [
    { name: "All Files", extensions: ["*"] }
    // { name: "Images", extensions: ["jpg", "png", "gif"] },
    // { name: "Movies", extensions: ["mkv", "avi", "mp4"] }
  ],
  properties: ["multiSelections"]
  //'openFile', 'openDirectory', 'multiSelections'
};
let dialogFileOptions = {
  // defaultPath: 'c:/',
  filters: [
    { name: "All Files", extensions: ["*"] }
    // { name: "Images", extensions: ["jpg", "png", "gif"] },
    // { name: "Movies", extensions: ["mkv", "avi", "mp4"] }
  ],
  properties: ["openFile"]
  //'openFile', 'openDirectory', 'multiSelections'
};
let dialogFolderOptions = {
  // defaultPath: 'c:/',
  filters: [
    { name: "All Files", extensions: ["*"] }
  ],
  properties: ["openDirectory"]
  //'openFile', 'openDirectory', 'multiSelections'
};
let ubuntuProcess;
let serverPID = null;
process.arch === "arm64";
const isWSL = () => {
  const os2 = require("os");
  if (os2.release().toLowerCase().includes("microsoft")) {
    return true;
  }
  if (fs.existsSync("/proc/version") && fs.readFileSync("/proc/version", "utf8").toLowerCase().includes("microsoft")) {
    return true;
  }
  return false;
};
const killProcess = () => {
  if (serverPID) {
    exec(`kill -15 ${serverPID}`, (error, stdout, stderr) => {
      if (error) {
        console.error(`execution error: ${error}`);
        return;
      }
      serverPID = null;
    });
  }
};
const initialize = (mainWindow) => {
  electron.ipcMain.handle("evtb:isMaximized", () => {
    return mainWindow.isMaximized();
  });
  electron.ipcMain.handle("evtb:maximize", () => {
    mainWindow.maximize();
  });
  electron.ipcMain.handle("evtb:minimize", () => {
    mainWindow.minimize();
  });
  electron.ipcMain.handle("evtb:restore", () => {
    mainWindow.restore();
  });
  electron.ipcMain.handle("evtb:close", () => {
    let isLinux = process.platform === "linux";
    if (ubuntuProcess && isLinux && serverPID) {
      exec(`kill -15 ${serverPID}`, (error, stdout, stderr) => {
        if (error) {
          console.error(`execution error: ${error}`);
          return;
        }
        serverPID = null;
        mainWindow.close();
      });
    } else {
      mainWindow.close();
    }
  });
  electron.ipcMain.handle("evtb:getPlatform", () => {
    return process.platform;
  });
  electron.ipcMain.handle("evtb:isUbuntu", () => {
    return process.platform === "linux" && require("os").release();
  });
  electron.ipcMain.handle("evtb:osRelease", () => {
    return require("os").release();
  });
  electron.ipcMain.handle("evtb:getMultiFilePath", (_, defaultPath) => {
    dialogMultiFileOptions.defaultPath = defaultPath;
    return electron.dialog.showOpenDialog(dialogMultiFileOptions);
  });
  electron.ipcMain.handle("evtb:getFilePath", (_, defaultPath) => {
    dialogFileOptions.defaultPath = defaultPath;
    return electron.dialog.showOpenDialog(dialogFileOptions);
  });
  electron.ipcMain.handle("evtb:getFolderPath", (_, defaultPath) => {
    dialogFolderOptions.defaultPath = defaultPath;
    return electron.dialog.showOpenDialog(dialogFolderOptions);
  });
  electron.ipcMain.handle("evtb:getLocalImagePath", (_, defaultPath) => {
    if (defaultPath.startsWith("~")) {
      defaultPath = path.join(os.homedir(), defaultPath.slice(1));
    }
    return `file://${defaultPath.startsWith("/") ? "" : "/"}${defaultPath}`;
  });
  electron.ipcMain.handle("evtb:getLocalVideoPath", (_, defaultPath) => {
    if (defaultPath.startsWith("~")) {
      defaultPath = path.join(os.homedir(), defaultPath.slice(1));
    }
    return `file://${defaultPath.startsWith("/") ? "" : "/"}${defaultPath}`;
  });
  electron.ipcMain.handle("evtb:getVersion", () => {
    return electron.app.getVersion();
  });
  electron.ipcMain.handle("evtb:openUrl", (_, url) => {
    console.log(url);
    electron.shell.openExternal(url);
  });
  electron.ipcMain.handle("evtb:openPDF", () => {
    console.log(`file://!!!!!`);
    let isLinux = process.platform === "linux";
    if (isLinux) {
      const appPath = electron.app.getAppPath();
      let filePath;
      if (appPath.includes("app.asar")) {
        filePath = path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "User Manual for AI TOP Utility 1.0.pdf");
      } else {
        filePath = path.join(appPath, "resources", "User Manual for AI TOP Utility 1.0.pdf");
      }
      electron.shell.openExternal(`file://${filePath}`);
    }
  });
  electron.ipcMain.handle("evtb:openMLPdf", (_, fileName) => {
    console.log(fileName);
    let isLinux = process.platform === "linux";
    if (isLinux) {
      const appPath = electron.app.getAppPath();
      let filePath;
      if (appPath.includes("app.asar")) {
        filePath = path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "MLpdf", "MLCompare - " + fileName + ".pdf");
      } else {
        filePath = path.join(appPath, "resources", "MLpdf", "MLCompare - " + fileName + ".pdf");
      }
      console.log(`file://${filePath}`);
      return `file://${filePath}`;
    }
  });
  electron.ipcMain.handle("evtb:getVGAType", async () => {
    try {
      const gpuType = await detectGpu();
      return gpuType;
    } catch (error) {
      console.error("Error detecting GPU type:", error);
      return "Unknown";
    }
  });
  electron.ipcMain.handle("evtb:isWSL", () => {
    return isWSL();
  });
  electron.ipcMain.handle("evtb:isArm64", () => {
    return process.arch === "arm64";
  });
};
const resolve = (relativePath) => path.resolve(__dirname, relativePath);
const getIcon = () => {
  if (process.platform === "darwin") {
    return resolve("../../resources/icons/icon.icns");
  } else if (process.platform === "win32") {
    return resolve("../../resources/icons/icon.ico");
  } else if (process.platform === "linux") {
    return resolve("../../resources/icons/256x256.png");
  } else {
    return resolve("../../resources/icons/256x256.png");
  }
};
const initBackendMainFile = (mainWindow) => {
  let isLinux = process.platform === "linux";
  if (isLinux) {
    const appPath = electron.app.getAppPath();
    let unpackedScriptPath;
    if (appPath.includes("app.asar")) {
      if (process.arch === "arm64") {
        unpackedScriptPath = path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "scripts", "mainArm64");
      } else {
        unpackedScriptPath = path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "scripts", "main2404");
      }
    } else {
      if (process.arch === "arm64") {
        unpackedScriptPath = path.join(appPath, "resources", "scripts", "mainArm64");
      } else {
        unpackedScriptPath = path.join(appPath, "resources", "scripts", "main2404");
      }
    }
    let llamaPath;
    if (appPath.includes("app.asar")) {
      llamaPath = path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "Install", "LLaMA-Factory");
    } else {
      llamaPath = path.join(appPath, "resources", "Install", "LLaMA-Factory");
    }
    let videoLLaVAPath;
    if (appPath.includes("app.asar")) {
      videoLLaVAPath = path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "Install", "Video-LLaVA");
    } else {
      videoLLaVAPath = path.join(appPath, "resources", "Install", "Video-LLaVA");
    }
    let megatronDeepSpeedPath;
    if (appPath.includes("app.asar")) {
      megatronDeepSpeedPath = path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "Install", "Megatron-DeepSpeed");
    } else {
      megatronDeepSpeedPath = path.join(appPath, "resources", "Install", "Megatron-DeepSpeed");
    }
    const fs2 = require("fs");
    if (!fs2.existsSync(unpackedScriptPath)) {
      electron.dialog.showErrorBox("Error", `Script not found: ${unpackedScriptPath}`);
      console.error(`Script not found: ${unpackedScriptPath}`);
      return;
    }
    ubuntuProcess = spawn("TORCH_DISABLE_DYNAMO=1 TRITON_DISABLE_CUDA_KERNELS=1", [unpackedScriptPath, llamaPath, videoLLaVAPath, megatronDeepSpeedPath], { shell: true });
    ubuntuProcess.stdout.on("data", (data) => {
    });
    ubuntuProcess.stderr.on("data", (data) => {
      const output = data.toString();
      const match = output.match(/Started server process \[(\d+)\]/);
      if (match) {
        serverPID = parseInt(match[1]);
      }
      let timer = setInterval(() => {
        if (data.includes("Uvicorn running on http://")) {
          clearInterval(timer);
          setTimeout(() => {
            if (utils.is.dev && process.env["ELECTRON_RENDERER_URL"]) {
              mainWindow.loadURL(process.env["ELECTRON_RENDERER_URL"]);
            } else {
              mainWindow.loadFile(path.join(__dirname, "../renderer/index.html"));
            }
          }, 1e3);
        }
      }, 1e3);
    });
    ubuntuProcess.on("close", (code) => {
    });
    ubuntuProcess.on("exit", (code, signal) => {
    });
  } else {
    if (utils.is.dev && process.env["ELECTRON_RENDERER_URL"]) {
      mainWindow.loadURL(process.env["ELECTRON_RENDERER_URL"]);
    } else {
      mainWindow.loadFile(path.join(__dirname, "../renderer/index.html"));
    }
  }
};
const checkFileExists = (filePath) => {
  return new Promise((resolve2) => {
    const interval = setInterval(() => {
      if (fs.existsSync(filePath)) {
        clearInterval(interval);
        resolve2(true);
      }
    }, 1e3);
  });
};
const executeScriptsSequentially = async (mainWindow, shList, index = 0) => {
  const appPath = electron.app.getAppPath();
  const exePath = electron.app.getPath("userData");
  if (index >= shList.length) {
    const firstRunFile = path.join(exePath, "first-run.txt");
    try {
      if (!fs.existsSync(firstRunFile)) {
        fs.writeFileSync(firstRunFile, "This is a first run file.");
      } else {
      }
    } catch (error) {
      console.error("Error creating or writing to the first run file:", error);
    }
    initBackendMainFile(mainWindow);
    return;
  } else {
    let unpackedScriptPath;
    if (appPath.includes("app.asar")) {
      unpackedScriptPath = path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "Install", shList[index]);
    } else {
      unpackedScriptPath = path.join(appPath, "resources", "Install", shList[index]);
    }
    if (isWSL())
      ;
    const tempFilePath = path.join(electron.app.getPath("temp"), `script_complete_${index}`);
    const finalCommand = `${unpackedScriptPath}; touch ${tempFilePath}`;
    let scriptProcess = "";
    if (isWSL()) {
      scriptProcess = spawn("dbus-launch", ["gnome-terminal", "--", "bash", "-c", finalCommand]);
    } else {
      scriptProcess = spawn("gnome-terminal", ["--", "bash", "-c", finalCommand]);
    }
    scriptProcess.on("close", async (code) => {
      if (code !== 0) {
        console.error(`Script ${shList[index]} exited with code ${code} or was manually closed. Execution stopped.`);
        return;
      }
      await checkFileExists(tempFilePath).then((exists) => {
        if (exists) {
          fs.unlinkSync(tempFilePath);
          executeScriptsSequentially(mainWindow, shList, index + 1);
        }
      });
    });
  }
};
const initUserFirstOpen = (mainWindow, shList) => {
  executeScriptsSequentially(mainWindow, shList);
};
const detectGpu = async () => {
  if (isWSL()) {
    return new Promise((resolve2, reject) => {
      exec('wsl.exe powershell.exe "Get-WmiObject Win32_VideoController | Select-Object Name"', (error, stdout, stderr) => {
        if (error) {
          reject(`Error: ${error}`);
        }
        const gpuInfo = stdout.trim();
        if (gpuInfo.includes("NVIDIA")) {
          resolve2("NVIDIA");
          console.log(`VGA Info: NVIDIA`);
        } else if (gpuInfo.includes("AMD") || gpuInfo.includes("Radeon")) {
          resolve2("AMD");
          console.log(`VGA Info: AMD`);
        } else {
          resolve2("Unknown");
          console.log(`VGA Info: Unknown`);
        }
      });
    });
  } else {
    return new Promise((resolve2, reject) => {
      exec("lspci | grep VGA", (error, stdout, stderr) => {
        if (error) {
          reject(`Error: ${error}`);
        }
        if (stdout.includes("NVIDIA")) {
          resolve2("NVIDIA");
          console.log(`VGA Info: NVIDIA`);
        } else if (stdout.includes("AMD") || stdout.includes("Radeon")) {
          resolve2("AMD");
          console.log(`VGA Info: AMD`);
        } else {
          resolve2("Unknown");
          console.log(`VGA Info: Unknown`);
        }
      });
    });
  }
};
const runCommand = (mainWindow, shList) => {
  const fs2 = require("fs");
  const appPath = electron.app.getAppPath();
  const userDataPath = electron.app.getPath("userData");
  const isFirstOpenFilePath = path.join(userDataPath, "first-run.txt");
  let unpackedScriptPaths = [];
  if (appPath.includes("app.asar")) {
    unpackedScriptPaths = shList.map((sh) => {
      return path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "Install", sh);
    });
    if (process.arch === "arm64") {
      console.log("mainArm64");
      unpackedScriptPaths.push(path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "scripts", "mainArm64"));
    } else {
      console.log("ubuntu 2404");
      unpackedScriptPaths.push(path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "scripts", "main2404"));
      unpackedScriptPaths.push(path.join(path.dirname(appPath), "app.asar.unpacked", "resources", "Install", "LLaMA-Factory"));
    }
  } else {
    unpackedScriptPaths = shList.map((sh) => {
      return path.join(appPath, "resources", "Install", sh);
    });
    if (process.arch === "arm64") {
      console.log("mainArm64");
      unpackedScriptPaths.push(path.join(appPath, "resources", "scripts", "mainArm64"));
    } else {
      console.log("ubuntu 2404");
      unpackedScriptPaths.push(path.join(appPath, "resources", "scripts", "main2404"));
      unpackedScriptPaths.push(path.join(appPath, "resources", "Install", "LLaMA-Factory"));
    }
  }
  let command;
  if (isWSL()) {
    command = unpackedScriptPaths.map((scriptPath) => `sudo chmod +x "${scriptPath}"`).join(" && ");
  } else {
    command = unpackedScriptPaths.map((scriptPath) => `chmod +x "${scriptPath}"`).join(" && ");
  }
  const options = {
    name: "GIGABYTE AI Top Utility"
  };
  const handleExecution = (error, stdout, stderr) => {
    if (error) {
      electron.dialog.showErrorBox("Error", `InitUserFirstOpen : Error executing scripts: ${error.message}`);
      console.error(`Error executing scripts: ${error.message}`);
      mainWindow.close();
      return;
    }
    if (stdout)
      console.log(`stdout: ${stdout}`);
    if (stderr)
      console.error(`stderr: ${stderr}`);
    initUserFirstOpen(mainWindow, shList);
  };
  if (process.platform === "linux") {
    if (!fs2.existsSync(isFirstOpenFilePath)) {
      if (isWSL()) {
        exec(command, options, handleExecution);
      } else {
        sudo.exec(command, options, handleExecution);
      }
    } else {
      initBackendMainFile(mainWindow);
    }
  } else {
    initBackendMainFile(mainWindow);
  }
  mainWindow.on("ready-to-show", () => {
    mainWindow.show();
  });
  mainWindow.webContents.on("did-finish-load", () => {
    try {
      const version = versionInfo.match(/Description:\s+(.*)/)[1].trim();
      console.log(version);
      if (version !== "Ubuntu 24.04.4 LTS" && version !== "Pop!_OS 24.04 LTS") {
        electron.dialog.showErrorBox("Version Mismatch", `The current version ${version} is not supported by AI TOP Utility software. Please ensure you are using Ubuntu 24.04.4 LTS. `);
        electron.app.quit();
      }
    } catch (error) {
      console.error("Error getting Ubuntu version:", error);
      electron.dialog.showErrorBox("Error", "Error getting Ubuntu version");
      electron.app.quit();
    }
  });
  mainWindow.webContents.setWindowOpenHandler((details) => {
    electron.shell.openExternal(details.url);
    return { action: "deny" };
  });
  mainWindow.on("close", (event) => {
    console.log("Main window is closing...");
    killProcess();
  });
};
function createWindow() {
  const mainWindow = new electron.BrowserWindow({
    width: 1440,
    height: 800,
    minWidth: 1440,
    minHeight: 800,
    show: false,
    autoHideMenuBar: true,
    icon: getIcon(),
    webPreferences: {
      preload: path.join(__dirname, "../preload/index.js"),
      sandbox: false,
      nodeIntegration: true,
      contextIsolation: false,
      webSecurity: false
      // 停用安全性來允許 file:// 協議
    },
    frame: false,
    titleBarStyle: "hidden",
    titleBarOverlay: {
      color: "#181F31",
      height: 35,
      symbolColor: "white"
    }
  });
  initialize(mainWindow);
  require("fs");
  electron.app.getAppPath();
  let ARM64ShList = [];
  let NVshList = [];
  let AMDshList = [];
  if (process.arch === "arm64") {
    console.log("Arm64 install");
    ARM64ShList = [
      "1_conda_arm64.sh",
      "llama_cpp_arm64.sh"
    ];
  } else {
    console.log("Ubuntu 2404 install");
    NVshList = [
      "1_wsl2404.sh",
      "2_apt.sh",
      "3_conda_2404.sh",
      "5_conda_lmmllava.sh",
      "llama_cpp.sh",
      "power_install.sh"
    ];
    AMDshList = [
      "amd_2_rocm.sh",
      "amd_3_apt.sh",
      "amd_4_conda_2404.sh",
      "amd_6_conda_lmmllava.sh",
      "llama_cpp.sh",
      "power_install.sh"
    ];
  }
  let shList = [];
  detectGpu().then((gpuType) => {
    if (process.arch === "arm64") {
      console.log("Arm64 architecture detected");
      shList = ARM64ShList;
      runCommand(mainWindow, shList);
    } else {
      if (gpuType === "NVIDIA") {
        shList = NVshList;
        runCommand(mainWindow, shList);
      } else if (gpuType === "AMD") {
        shList = AMDshList;
        runCommand(mainWindow, shList);
      } else {
        electron.dialog.showErrorBox("Error", "Unable to detect known graphics card brand. GIGABYTE AI Top Utility will now close.");
      }
    }
  }).catch((error) => {
  });
}
electron.app.whenReady().then(() => {
  utils.electronApp.setAppUserModelId("com.gigabyte");
  electron.app.on("browser-window-created", (_, window) => {
    utils.optimizer.watchWindowShortcuts(window);
  });
  electron.ipcMain.on("ping", () => console.log("pong"));
  createWindow();
  electron.app.on("activate", function() {
    if (electron.BrowserWindow.getAllWindows().length === 0)
      createWindow();
  });
});
electron.app.on("window-all-closed", () => {
  console.log("All windows closed");
  killProcess();
  if (process.platform !== "darwin") {
    electron.app.quit();
  }
});
let checkForUpdateStatus = "Idle";
electron.ipcMain.handle("evtb:getUpdateStatus", () => {
  return checkForUpdateStatus;
});
electron.ipcMain.handle("evtb:checkForUpdates", () => {
  electronUpdater.autoUpdater.checkForUpdates();
  checkForUpdateStatus = "Checking for updates…";
});
electron.ipcMain.on("check-for-update", () => {
  console.log("觸發檢查更新");
  electronUpdater.autoUpdater.checkForUpdates();
  checkForUpdateStatus = "Checking for updates…";
});
electronUpdater.autoUpdater.autoDownload = false;
electronUpdater.autoUpdater.on("error", (error) => {
  console.log(error);
  checkForUpdateStatus = "Idle";
  electron.dialog.showErrorBox("Update exception", "Something mistake");
});
electronUpdater.autoUpdater.on("checking-for-update", () => {
  console.log("正在檢查更新…");
  checkForUpdateStatus = "Checking for updates…";
});
electronUpdater.autoUpdater.on("update-available", (releaseInfo) => {
  checkForUpdateStatus = "Available";
  const releaseNotes = releaseInfo.releaseNotes;
  let releaseContent = "";
  if (releaseNotes) {
    if (typeof releaseNotes === "string") {
      releaseContent = releaseNotes;
    } else if (releaseNotes instanceof Array) {
      releaseNotes.forEach((releaseNote) => {
        releaseContent += `${releaseNote}
`;
      });
    }
  } else {
    releaseContent = "No update instructions yet";
  }
  electron.dialog.showMessageBox({
    type: "info",
    title: "The app has new updates",
    detail: releaseContent,
    message: "A new version was found. Do you want to update now?",
    buttons: ["No", "Yes"]
  }).then(({ response }) => {
    if (response === 1) {
      electronUpdater.autoUpdater.downloadUpdate();
      checkForUpdateStatus = "Downloading...0%";
    }
  });
});
electronUpdater.autoUpdater.on("update-not-available", () => {
  checkForUpdateStatus = "newest";
  electron.dialog.showMessageBox({ title: "No updates available", message: "It is currently the latest version" });
});
electronUpdater.autoUpdater.on("download-progress", (progress) => {
  checkForUpdateStatus = "Downloading..." + progress.percent.toFixed(2) + "%";
});
electronUpdater.autoUpdater.on("update-downloaded", () => {
  checkForUpdateStatus = "Downloaded";
  electron.dialog.showMessageBox({
    title: "Install updates",
    message: "Once the update has been downloaded, the application will restart and install"
  }).then(() => {
    setImmediate(() => electronUpdater.autoUpdater.quitAndInstall());
  });
});
