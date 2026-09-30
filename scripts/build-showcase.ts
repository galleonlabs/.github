import { copyFile, mkdir } from "node:fs/promises";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
await mkdir(resolve(root, "dist"), { recursive: true });
await copyFile(resolve(root, "showcase/index.html"), resolve(root, "dist/index.html"));
console.log("Built static public showcase in dist/index.html");
