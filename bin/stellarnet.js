#!/usr/bin/env node
const fs = require("fs");
const path = require("path");

function parseArgs(argv) {
    const args = {out: "StellarNet", force: false, skipIfPresent: false};
    for (let i = 0; i < argv.length; i++) {
        const arg = argv[i];
        if (arg === "--out" && argv[i + 1]) {
            args.out = argv[i + 1];
            i += 1;
        } else if (arg === "--force") {
            args.force = true;
        } else if (arg === "--skip-if-present") {
            args.skipIfPresent = true;
        } else if (arg === "--help" || arg === "-h") {
            args.help = true;
        }
    }
    return args;
}

function printHelp() {
    console.log("Usage: npx stellarnet [--out path] [--force] [--skip-if-present]");
    console.log("Copies the StellarNet source tree from the npm package into your workspace.");
}

function copyTree(src, dest, force) {
    if (fs.existsSync(dest)) {
        if (!force) {
            throw new Error(`Target path already exists: ${dest}. Use --force to overwrite.`);
        }
        fs.rmSync(dest, {recursive: true, force: true});
    }
    fs.mkdirSync(path.dirname(dest), {recursive: true});
    fs.cpSync(src, dest, {recursive: true});
}

function main() {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
        printHelp();
        return;
    }

    const packageRoot = path.resolve(__dirname, "..");
    const sourcePath = path.join(packageRoot, "StellarNet");
    const destPath = path.resolve(process.cwd(), args.out);

    if (!fs.existsSync(sourcePath)) {
        console.error("StellarNet source not found inside package.");
        process.exit(1);
    }

    if (fs.existsSync(destPath) && args.skipIfPresent && !args.force) {
        console.log(`[stellarnet] Skipping copy; target already exists at ${destPath}`);
        return;
    }

    try {
        copyTree(sourcePath, destPath, args.force);
        console.log(`[stellarnet] Copied StellarNet to ${destPath}`);
    } catch (err) {
        console.error(err.message || err);
        process.exit(1);
    }
}

main();
