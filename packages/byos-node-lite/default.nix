{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nodejs_22,
}:

buildNpmPackage {
  pname = "byos-node-lite";
  version = "unstable-2026-09-03";

  src = fetchFromGitHub {
    owner = "usetrmnl";
    repo = "byos_node_lite";
    rev = "840262d6cd1d31a04b96910f2e0db1473fd98d82";
    hash = "sha256-WJefIh32Q9VMN9nh6WL0LZi2idPnfzpXD3cC8O0qEr4=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    substituteInPlace package.json \
      --replace-fail '"name": "byos_node_lite",' \
        '"name": "byos_node_lite", "version": "0.0.0-unstable-20260903",'

    substituteInPlace src/Server.ts \
      --replace-fail 'from "Config.js"' 'from "./Config.js"' \
      --replace-fail 'from "Screen/Screen.js"' 'from "./Screen/Screen.js"' \
      --replace-fail 'from "BYOS/BYOSRoutes.js"' 'from "./BYOS/BYOSRoutes.js"' \
      --replace-fail 'from "Routes.js"' 'from "./Routes.js"'
    substituteInPlace src/BYOS/BYOSRoutes.ts \
      --replace-fail 'from "Config.js"' 'from "../Config.js"' \
      --replace-fail 'from "Routes.js"' 'from "../Routes.js"'
    substituteInPlace src/BYOS/Display.ts \
      --replace-fail 'from "Config.js"' 'from "../Config.js"' \
      --replace-fail 'from "Screen/Screen.js"' 'from "../Screen/Screen.js"'
    substituteInPlace src/BYOS/Log.ts src/BYOS/Setup.ts \
      --replace-fail 'from "Config.js"' 'from "../Config.js"'
    substituteInPlace src/Data/PrepareData.ts \
      --replace-fail 'from "Config.js"' 'from "../Config.js"'
    substituteInPlace src/Screen/BuildJSX.ts \
      --replace-fail 'from "Data/PrepareData.js"' 'from "../Data/PrepareData.js"'
    substituteInPlace src/Screen/BuildLiquid.ts \
      --replace-fail 'from "Config.js"' 'from "../Config.js"' \
      --replace-fail 'from "Data/PrepareData.js"' 'from "../Data/PrepareData.js"'
    substituteInPlace src/Screen/RenderHTML.ts \
      --replace-fail 'from "Config.js"' 'from "../Config.js"'
    substituteInPlace src/Screen/Screen.ts \
      --replace-fail 'from "Data/PrepareData.js"' 'from "../Data/PrepareData.js"' \
      --replace-fail 'from "Config.js"' 'from "../Config.js"' \
      --replace-fail 'from "Template/JSX/App.js"' 'from "../Template/JSX/App.js"'
    substituteInPlace src/Template/JSX/App.tsx \
      --replace-fail 'from "Data/PrepareData.js"' 'from "../../Data/PrepareData.js"'

    substituteInPlace src/Main.ts \
      --replace-fail "    import('./Server.js');" "    await import('./Server.js');"
    substituteInPlace src/Server.ts \
      --replace-fail '    app.listen(SERVER_PORT, SERVER_HOST, async (error) => {' \
        $'    await initPuppeteer();\n    app.listen(SERVER_PORT, SERVER_HOST, (error) => {' \
      --replace-fail '            await initPuppeteer();' \
        '            // Puppeteer is ready before the listening socket opens.'

    substituteInPlace src/Config.ts \
      --replace-fail "export const SERVER_PORT = 3000;" \
        "export const SERVER_PORT = Number(process.env['SERVER_PORT'] ?? 3000);" \
      --replace-fail "export const SERVER_HOST = '0.0.0.0';" \
        "export const SERVER_HOST = process.env['SERVER_HOST'] ?? '0.0.0.0';" \
      --replace-fail "export const REFRESH_RATE_SECONDS = 60;" \
        "export const REFRESH_RATE_SECONDS = Number(process.env['REFRESH_RATE_SECONDS'] ?? 60);" \
      --replace-fail "export const TIMEZONE = 'Europe/Warsaw';" \
        "export const TIMEZONE = process.env['TZ'] ?? 'Europe/Warsaw';" \
      --replace-fail "export const ALLOW_FIRMWARE_UPDATE = true;" \
        "export const ALLOW_FIRMWARE_UPDATE = (process.env['ALLOW_FIRMWARE_UPDATE'] ?? 'true') === 'true';" \
      --replace-fail "export const BUTTON_2_CLICK_FUNCTION = 'sleep';" \
        "export const BUTTON_2_CLICK_FUNCTION = process.env['BUTTON_2_CLICK_FUNCTION'] ?? 'sleep';" \
      --replace-fail "export let BYOS_ENABLED = false;" \
        "export let BYOS_ENABLED = process.env['BYOS_ENABLED'] === 'true';" \
      --replace-fail "export let BYOS_PROXY = false;" \
        "export let BYOS_PROXY = process.env['BYOS_PROXY'] === 'true';"
  '';

  npmDepsHash = "sha256-rgH1gNd5Qyb/jBpuP/2MJ6mP1/jSM411VsaBybOGiQc=";
  nodejs = nodejs_22;
  dontNpmBuild = true;
  doCheck = true;

  checkPhase = ''
    runHook preCheck
    npm exec tsc -- --noEmit
    runHook postCheck
  '';

  env.PUPPETEER_SKIP_DOWNLOAD = "true";

  meta = {
    description = "Lightweight Node.js BYOS image server for TRMNL";
    homepage = "https://github.com/usetrmnl/byos_node_lite";
    license = lib.licenses.mit;
  };
}
