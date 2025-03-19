import * as fs from "node:fs";

import {
  getPackageJson,
  getArchiveName,
  getReleaseUrl,
  getCategoryId,
  ASSET_TEMPLATE_PATH,
} from "./consts.js";

const packageJson = getPackageJson();

const pluginVersion = packageJson?.version;

if(!pluginVersion) {
  throw new Error('No "version" set in package.json')
}

const repositoryUrl = packageJson?.repository;

if(!repositoryUrl) {
  throw new Error('No "repository" set in package.json')
}

const archiveName = getArchiveName(packageJson?.name, pluginVersion);

if(!archiveName) {
  throw new Error('No "name" set in package.json')
}

const releaseUrl = getReleaseUrl(repositoryUrl, pluginVersion, archiveName);

const assetTemplate = {
  title: packageJson?.title,
  description: packageJson?.description,
  category_id: getCategoryId(packageJson?.category),
  godot_version: packageJson.godotVersion,
  version_string: pluginVersion,
  cost: packageJson.license,
  download_provider: "Custom",
  download_commit: releaseUrl,
  download_url: releaseUrl,
  browse_url: repositoryUrl,
  issues_url: `${repositoryUrl}/issues`,
  icon_url: packageJson?.icon,
}

fs.writeFileSync(
  ASSET_TEMPLATE_PATH,
  JSON.stringify(assetTemplate, null, 2)
);

console.log("Created asset template.");
