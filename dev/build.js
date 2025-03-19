import * as fs from "node:fs";
import path from "node:path";
import AdmZip from "adm-zip";

import {
  BUILD_PATH,
  getPackageJson,
  getArchiveName,
  ADDON_PATH
} from "./consts.js";

function createBuildFolder() {
  if(fs.existsSync(BUILD_PATH)) {
    fs.rmSync(BUILD_PATH, { recursive: true });
  }
  fs.mkdirSync(BUILD_PATH);

  fs.writeFileSync(path.join(BUILD_PATH, ".gdignore"), "");
}

function createBuild(buildPath) {
  fs.mkdirSync(buildPath);
  
  const addonName = ADDON_PATH.split(path.sep).pop()

  fs.cpSync(ADDON_PATH, path.join(buildPath, "addons", addonName), {
    recursive: true,
    preserveTimestamps: true,
  });
}

function createBuildArchive(buildPath, archiveName) {
  const zip = new AdmZip();
  
  zip.addLocalFolder(buildPath, archiveName);
  
  zip.writeZip(`${buildPath}.zip`);
}

function main() {
  const packageJson = getPackageJson();
  
  const pluginName = packageJson?.name;
  const pluginVersion = packageJson?.version;
  
  if(pluginName === undefined) {
    throw new Error(`No plugin "name" defined in package.json`);
  }
  
  const archiveName = getArchiveName(pluginName, pluginVersion);
  const archivePath = path.join(BUILD_PATH, archiveName);
  
  createBuildFolder();
  
  console.log("Created build folder.");
  
  createBuild(archivePath);
  
  console.log(`Created ${archiveName} files.`);
  
  createBuildArchive(archivePath, archiveName);
  
  console.log(`Created ${archiveName}.zip archive.`);
}

main();
