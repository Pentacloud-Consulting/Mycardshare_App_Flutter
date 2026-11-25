import net from "node:net";
import { spawn } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

/** Last port we'll try before giving up (inclusive). */
const SCAN_PORT_MAX = 3099;

/**
 * Parse CLI:
 * - `--port N` / `-p N` → MUST use that port (strict; fails if busy)
 * - `--from N` → scan N, N+1, … up to SCAN_PORT_MAX for first free (default scan starts at 3000)
 */
function parseCli() {
  const argv = process.argv.slice(2);
  let strictPort = null;
  let scanFrom = 3000;

  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if ((a === "--port" || a === "-p") && argv[i + 1]) {
      strictPort = Number(argv[i + 1]);
      i++;
      continue;
    }
    if (a === "--from" && argv[i + 1]) {
      scanFrom = Number(argv[i + 1]);
      i++;
    }
  }

  if (
    strictPort != null &&
    (!Number.isFinite(strictPort) || strictPort <= 0 || strictPort > 65535)
  ) {
    console.error("Invalid --port value");
    process.exit(1);
  }
  if (
    !Number.isFinite(scanFrom) ||
    scanFrom <= 0 ||
    scanFrom > 65535
  ) {
    console.error("Invalid --from value");
    process.exit(1);
  }

  return { strictPort, scanFrom };
}

/**
 * Match how `next dev` binds: no host → OS dual-stack (often `::` on Windows).
 */
function checkPortAvailable(portToCheck) {
  return new Promise((resolve, reject) => {
    const server = net.createServer();
    server.unref();
    server.on("error", (err) => {
      if (err && err.code === "EADDRINUSE") resolve(false);
      else reject(err);
    });
    server.listen(portToCheck, () => {
      server.close(() => resolve(true));
    });
  });
}

async function choosePort({ strictPort, scanFrom }) {
  if (strictPort != null) {
    const ok = await checkPortAvailable(strictPort);
    if (!ok) {
      console.error(
        [
          "",
          `❌ Port ${strictPort} is already in use (strict mode: --port ${strictPort}).`,
          "",
          "Why this happens:",
          "- Another process is listening on that port — usually a leftover `node.exe` / `next dev`,",
          "  a second terminal, or another dev tool (sometimes started by an IDE/agent).",
          "",
          "Fix — free the port (PowerShell):",
          `  Get-NetTCPConnection -LocalPort ${strictPort} | Select-Object OwningProcess`,
          `  Stop-Process -Id (Get-NetTCPConnection -LocalPort ${strictPort}).OwningProcess -Force`,
          "",
          "Or run without forcing a port (auto-picks first free 3000–3099):",
          "  npm run dev",
          "",
        ].join("\n"),
      );
      process.exit(1);
    }
    return strictPort;
  }

  const start = Math.min(scanFrom, SCAN_PORT_MAX);
  for (let p = start; p <= SCAN_PORT_MAX; p++) {
    if (await checkPortAvailable(p)) {
      if (p > start) {
        console.warn("");
        console.warn(
          `⚠️  Ports ${start}–${p - 1} are busy — starting on ${p} instead.`,
        );
        console.warn(
          "   (Root cause: another `node.exe` / `next dev` is still running—extra terminal, crash, or IDE.)",
        );
        console.warn("");
      }
      return p;
    }
  }

  console.error(
    [
      "",
      `❌ No free dev port between ${start} and ${SCAN_PORT_MAX}.`,
      "",
      "Kill leftover Node processes, then retry:",
      "  Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force",
      "",
    ].join("\n"),
  );
  process.exit(1);
}

const { strictPort, scanFrom } = parseCli();
const port = await choosePort({ strictPort, scanFrom });

const root = process.cwd();
const nextCli = path.join(root, "node_modules", "next", "dist", "bin", "next");

if (!fs.existsSync(nextCli)) {
  console.error(
    `Missing Next.js CLI at:\n  ${nextCli}\n\nRun: npm install\n`,
  );
  process.exit(1);
}

console.log(`▶ Next.js dev → http://localhost:${port}`);

const child = spawn(process.execPath, [nextCli, "dev", "-p", String(port)], {
  stdio: "inherit",
  cwd: root,
  env: { ...process.env, PORT: String(port) },
});

child.on("exit", (code) => process.exit(code ?? 0));
