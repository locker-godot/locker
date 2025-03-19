import path from "node:path";
import * as fs from "node:fs";

export const PACKAGE_PATH = "package.json";

export const ADDONS_PATH = "addons/";

export const ADDON_PATH = path.join(ADDONS_PATH, "locker");

export const PLUGIN_PATH = path.join(ADDON_PATH, "plugin.cfg");

export const README_PATH = "README.md";

export const LICENSE_PATH = "LICENSE";

export const ADDON_README_PATH = path.join(ADDON_PATH, "README.md");

export const ADDON_LICENSE_PATH = path.join(ADDON_PATH, "LICENSE");

export const BUILD_PATH = "build/";

export const ASSET_TEMPLATE_PATH = path.join(BUILD_PATH, "asset-template.json.hb");

export const CHANGELOG_PATH = "CHANGELOG.md";

/**
 * Map of category names and IDs used in the Godot Asset Library.
 */
const categoryMap = {
  "2D Tools": "1",
  "3D Tools": "2",
  "Shaders": "3",
  "Materials": "4",
  "Tools": "5",
  "Scripts": "6",
  "Misc": "7",
}

export function getPackageJson() {
  return JSON.parse(fs.readFileSync(PACKAGE_PATH, "utf-8"));
}

export function getPluginCfg() {
  return fs.readFileSync(PLUGIN_PATH, "utf-8");
}

export function getPluginField(pluginCfg, field) {
  const regex = new RegExp(`^${field}="([^"]+)"`, "m");
  const match = pluginCfg.match(regex);

  return match ? match[1] : null;
}

export function setPluginField(pluginCfg, field, value) {
  const regex = new RegExp(`${field}="[^"]+"`);

  if(regex.test(pluginCfg)) {
    return pluginCfg.replace(
      regex,
      `${field}="${value}"`
    );
  }

  return pluginCfg + `\n${field}="${value}"`;
}

export function getArchiveName(pluginName, pluginVersion) {
  if(!pluginName) {
    return;
  }

  return !pluginVersion ? `${pluginName}` : `${pluginName}_v${pluginVersion}`;
}

export function getReleaseUrl(repositoryUrl, version, archiveName) {
  if(!repositoryUrl || !version || ! archiveName) {
    return;
  }

  return `${repositoryUrl}/releases/download/v${version}/${archiveName}.zip`;
}

export function getCategoryId(categoryName) {
  return categoryMap[categoryName];
}
