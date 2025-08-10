#!/usr/bin/env node

/**
 * Enhanced Package Manager Detection Script
 *
 * This script detects which package manager is being used and enforces pnpm.
 * It uses multiple detection methods for maximum reliability.
 */

const { execSync } = require("child_process");
const fs = require("fs");

// Configuration
const REQUIRED_PM = "pnpm";
const REQUIRED_PM_VERSION = "8.0.0";

function detectFromLockFiles() {
  const lockFiles = {
    "pnpm-lock.yaml": "pnpm",
    "yarn.lock": "yarn",
    "package-lock.json": "npm",
  };

  for (const [lockFile, pm] of Object.entries(lockFiles)) {
    if (fs.existsSync(lockFile)) {
      return { pm, method: `lock file (${lockFile})` };
    }
  }

  return { pm: null, method: "lock file detection" };
}

function detectFromUserAgent() {
  const ua = process.env.npm_config_user_agent || "";

  if (ua.includes("pnpm")) {
    return { pm: "pnpm", method: "user agent" };
  } else if (ua.includes("yarn")) {
    return { pm: "yarn", method: "user agent" };
  } else if (ua.includes("npm")) {
    return { pm: "npm", method: "user agent" };
  }

  return { pm: null, method: "user agent" };
}

function detectPackageManager() {
  const methods = [detectFromUserAgent, detectFromLockFiles];

  for (const method of methods) {
    const result = method();
    if (result.pm) {
      return result;
    }
  }

  return { pm: "unknown", method: "fallback" };
}

function checkPnpmVersion() {
  try {
    const version = execSync("pnpm --version", { encoding: "utf8" }).trim();
    const versionNum = version.split(".")[0];
    const requiredNum = REQUIRED_PM_VERSION.split(".")[0];

    if (parseInt(versionNum) >= parseInt(requiredNum)) {
      return { valid: true, version };
    } else {
      return { valid: false, version, required: REQUIRED_PM_VERSION };
    }
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

function box(message) {
  const lines = message.trim().split("\n");
  const width = lines.reduce((a, b) => Math.max(a, b.length), 0);
  const surround = (x) => "║   \x1b[0m" + x.padEnd(width) + "\x1b[31m   ║";
  const bar = "═".repeat(width);
  const top = "\x1b[31m╔═══" + bar + "═══╗";
  const pad = surround("");
  const bottom = "╚═══" + bar + "═══╝\x1b[0m";
  return [top, pad, ...lines.map(surround), pad, bottom].join("\n");
}

function showError(detectedPM, method) {
  const errorMessage =
    `❌ Package Manager Error\n\n` +
    `🔍 Detected: "${detectedPM}" (via ${method})\n` +
    `📦 Required: "${REQUIRED_PM}"\n\n` +
    `💡 Solutions:\n` +
    `   1. Install pnpm: npm install -g pnpm\n` +
    `   2. Use pnpm commands: pnpm install, pnpm run build, etc.\n` +
    `   3. Run: pnpm run check-pm (to verify)\n\n` +
    `🔗 Learn more: https://pnpm.io/installation`;

  console.log(box(errorMessage));
  process.exit(1);
}

function showSuccess(detectedPM, method) {
  console.log(
    `✅ Package Manager Check: Using "${detectedPM}" (detected via ${method})`
  );

  // Check pnpm version if using pnpm
  if (detectedPM === "pnpm") {
    const versionCheck = checkPnpmVersion();
    if (versionCheck.valid) {
      console.log(`✅ pnpm version: ${versionCheck.version}`);
    } else {
      console.log(
        `⚠️  Warning: pnpm version ${versionCheck.version} detected, but ${REQUIRED_PM_VERSION}+ is recommended`
      );
    }
  }
}

// Main execution
function main() {
  const { pm: detectedPM, method } = detectPackageManager();

  if (detectedPM === REQUIRED_PM) {
    showSuccess(detectedPM, method);
  } else {
    showError(detectedPM, method);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = {
  detectPackageManager,
  checkPnpmVersion,
  showError,
  showSuccess,
};
