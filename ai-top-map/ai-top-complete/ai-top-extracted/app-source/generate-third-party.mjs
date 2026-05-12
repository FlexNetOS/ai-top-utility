import { execSync } from "child_process";
import fs from "fs";
import path from "path";
import fetch from "node-fetch";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


const distPath = path.join(__dirname, "./dist/linux-arm64-unpacked/resources/app.asar");
const extractPath = path.join(__dirname, "./build/unpacked_app");
const licensesJson = path.join(__dirname, "./build/third-party.json");
const licenseFile = path.join(__dirname, "./build/THIRD-PARTY-NOTICES.txt");

const SPDX_BASE =
  "https://raw.githubusercontent.com/spdx/license-list-data/master/text";

// 1. 解壓 asar
console.log("📦 Extracting app.asar...");
if (fs.existsSync(extractPath)) {
  fs.rmSync(extractPath, { recursive: true, force: true });
}
execSync(`npx asar extract "${distPath}" "${extractPath}"`, { stdio: "inherit" });

// 2. 掃描解壓後的 node_modules
console.log("🔍 Running license-checker...");
execSync(
  `npx license-checker --production --json --out "${licensesJson}" --start "${extractPath}"`,
  { stdio: "inherit" }
);

// 3. 讀取 JSON 並輸出
const data = JSON.parse(fs.readFileSync(licensesJson, "utf-8"));

let output = "=========================================================\n";
output    += "                  THIRD PARTY LICENSES\n";
output    += "=========================================================\n\n";
output += "NOTICES\n\n";
output += "This repository incorporates material as listed below or described in the code.\n\n";

function findLicenseFile(dir) {
  const licenseFiles = ["LICENSE", "LICENSE.md", "LICENSE.txt", "license", "license.md"];
  for (const file of licenseFiles) {
    const fullPath = path.join(dir, file);
    if (fs.existsSync(fullPath)) {
      // console.log(`📄 Found ${file} in ${dir}`);
      return fullPath;
    }
  }
  return null;
}
function findLicenseInTxt(dir) {
  // *.txt 也常見 license名稱 前後 隨機文字 .txt
  const txtFiles = fs.readdirSync(dir).filter(f => f.toLowerCase().endsWith('.txt') && f.toLowerCase().includes('license'));
  for (const file of txtFiles) {
    const fullPath = path.join(dir, file);
    if (fs.existsSync(fullPath)) {
      console.log(`📄 Found ${file} in ${dir}`);
      return fullPath;
    }
  }
  return null;
}

function findLicenseInREADME(dir) {
  const readmeFiles = ["README", "README.md", "README.txt", "readme", "readme.md"];
  for (const file of readmeFiles) {
    const fullPath = path.join(dir, file);
    if (fs.existsSync(fullPath)) {
      const content = fs.readFileSync(fullPath, "utf-8");
      const licenseMatch = content.match(/##?\s*License\s*\n([\s\S]*?)(\n##?\s|\n#\s|$)/i);
      if (licenseMatch) {
        console.log(`📝 Found README: ${file} in ${dir}`);
        return licenseMatch[1].trim();
      }
    }
  }
  return null;
}

async function findLicenseInGitHub(repoUrl) {
  if (!repoUrl) return null;
  const githubMatch = repoUrl.match(/github\.com\/([^\/]+\/[^\/]+)(\/|$)/i);
  if (githubMatch) {
    const apiUrl = `https://raw.githubusercontent.com/${githubMatch[1]}/HEAD/LICENSE`;
    return fetch(apiUrl, { headers: { Accept: "application/vnd.github.v3.raw" } })
      .then(res => {
        if (res.ok) {
          console.log(`🐙 Fetching LICENSE from GitHub: ${githubMatch[1]}`);

          return res.text();
        }
      });
  }
  return null;
}

async function getSpdxText(licenseId, pkgName) {
  if (!licenseId) return null;
  const id = licenseId.split(" ")[0];
  const url = `${SPDX_BASE}/${id}.txt`;
  try {
    const res = await fetch(url);
    if (res.ok) {
      console.log(`🌐 Fetched SPDX license for ${pkgName}: ${id}`);
      return await res.text();
    }
  } catch (e) {
    console.warn(`⚠️ SPDX 下載失敗 (${id}): ${e.message}`);
  }
  return null;
}

for (const [pkg, info] of Object.entries(data)) {
  // output += `Package: ${pkg}\n`;
  // output += `License: ${info.licenses}\n`;
  // if (info.repository) output += `Repository: ${info.repository}\n`;
  // if (info.publisher) output += `Publisher: ${info.publisher}\n`;
  // if (info.email) output += `Email: ${info.email}\n`;

  // 附加 LICENSE 原文
  try {
    const pkgName = pkg.replace(/@[^@]+$/, ""); // 取掉版本號
    const modulePath = path.join(extractPath, "node_modules", pkgName);
    const licensePath = findLicenseFile(modulePath);

    // 如果遇到本專案 (gigabyte-gimate-coder) 就跳過
    if (pkgName === "gigabyte-gimate-coder") {
      console.log(`⏭️ Skipping own package: ${pkgName}`);
      continue;
    }

    // const licensePath = null;
    // // output += `\n---- ${pkg} LICENSE ----\n`;
    output += "---------------------------------------------------------\n";
    output += `\n${pkg}\n`;
    if (info.repository) output += `${info.repository}\n`;
    if (info.licenses) output += `${info.licenses}\n`;
    if (licensePath) {
      if (info.licenseFile){
        // 取代掉 info.licenseFile "unpacked_app"之前的隨機路徑 變成 resources/app.asar
        output += `${info.licenseFile.replace(/.*?\\unpacked_app\\/, "resources\\app.asar\\")}\n\n`;
      }
      output += fs.readFileSync(licensePath, "utf-8");
    }else{
      // 嘗試找其他可能的 LICENSE .txt 檔案
      const txtLicensePath = findLicenseInTxt(modulePath);
      if (txtLicensePath) {
        if (info.licenseFile){
            // 取代掉 info.licenseFile "unpacked_app"之前的隨機路徑 變成 resources/app.asar
            output += `${info.licenseFile.replace(/.*?\\unpacked_app\\/, "resources\\app.asar\\")}\n\n`;
        }
        output += fs.readFileSync(txtLicensePath, "utf-8");

      }else{
        // 嘗試從 node_modules/<pkg> 找 README
        const findREADMEPath = path.join("node_modules", pkgName);

        // 重新嘗試 從 findREADMEPath 找 LICENSE
        const tryLicensePath = findLicenseFile(path.join(extractPath, findREADMEPath));
        if (tryLicensePath) {
          output += fs.readFileSync(tryLicensePath, "utf-8");
        }else{
          // 嘗試從 README 找
          const readmeLicense = findLicenseInREADME(findREADMEPath);
          if (readmeLicense) {
            output += `${findREADMEPath}\n\n`;
            output += readmeLicense;
          }else{
            // 嘗試從 GitHub 取得
            const gitHubLicense = await findLicenseInGitHub(info.repository);
            if (gitHubLicense) {
              output += gitHubLicense;
            }else{
              // 嘗試從 SPDX 取得
              if (info.licenses) {
                const spdxText = await getSpdxText(info.licenses , pkgName);
                if (spdxText) {
                  output += spdxText.replace(/<copyright holders>/g, info.publisher || "");
                  continue;
                }
              }
            }
          }
        }
      }
    }

      // output += `\n---- END ${pkg} LICENSE ----\n`;

      output += "\n---------------------------------------------------------\n";
      output += "\n";
  } catch (e) {
    // console.warn(`⚠️ No LICENSE file for ${pkg}`);
  }
}

// 4. 附加 Electron LICENSE
const electronLicense = path.join('./dist/win-unpacked', "LICENSE.electron.txt");

if (fs.existsSync(electronLicense)) {
  output += "---------------------------------------------------------\n";
  output += "\nELECTRON\n";
  output += "https://github.com/electron/electron\n";
  output += "\\LICENSE.electron.txt\n";
  output += "\n\n";
  output += fs.readFileSync(electronLicense, "utf-8");
  output += "---------------------------------------------------------\n";
  output += "\n";
}

// 5. 附加 Chromium LICENSES
const chromiumLicense = path.join(
  './dist/win-unpacked',
  "LICENSES.chromium.html"
);
if (fs.existsSync(chromiumLicense)) {
  let chromiumText = fs.readFileSync(chromiumLicense, "utf-8");
  chromiumText = chromiumText
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
    .replace(/<[^>]+>/g, "")
    .replace(/\n\s*\n/g, "\n\n")
    .trim();
    // decode 常見 HTML entities
  chromiumText = chromiumText
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&");

  output += "---------------------------------------------------------\n";
  output += "\CHROMIUM\n";
  output += "https://github.com/chromium/chromium\n";
  output += "MIT\n";
  output += "\\LICENSES.chromium.html\n";
  output += "\n\n";
  output += chromiumText;
  output += "---------------------------------------------------------\n";
  output += "\n";
}

// 6. 輸出
fs.writeFileSync(licenseFile, output, "utf-8");
console.log(`✅ THIRD-PARTY-NOTICES.txt generated at: ${licenseFile}`);
