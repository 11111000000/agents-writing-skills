#!/usr/bin/env node
/**
 * components/build-landing.mjs
 *
 * Pre-renders the landing pages (EN + RU) from components/awsLanding.tsx into
 * standalone HTML files inside the Quartz output directory. The landing comes
 * out of the same JSX source the local Quartz plugin would have used, but
 * skips Quartz's markdown pipeline (which strips raw HTML) so we get an
 * actual rendered <header>, <section>, <footer> with classes, SVG icons,
 * and inline <style>.
 *
 * Usage: QUARTZ_LANDING_OUT_DIR=/path/to/output QUARTZ_LANDING_TMP_DIR=/path/to/quartz-tmp node build-landing.mjs
 *
 * The script resolves its `preact` / `esbuild` / `preact-render-to-string` from
 * Quartz's tmp directory's node_modules (which is set up by scripts/build-site.sh).
 */

import { writeFileSync, mkdirSync } from "node:fs"
import { dirname, join, resolve } from "node:path"
import { pathToFileURL, fileURLToPath } from "node:url"
import { createRequire } from "node:module"

function requireFromQuartz() {
  const quartzTmp = process.env.QUARTZ_LANDING_TMP_DIR
  if (!quartzTmp) {
    throw new Error("Set QUARTZ_LANDING_TMP_DIR to the Quartz staging directory so we can reuse its node_modules.")
  }
  return createRequire(join(quartzTmp, "node_modules"))
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const REPO_ROOT = resolve(__dirname, "..")
const COMPONENTS_DIR = __dirname

const outDir = process.env.QUARTZ_LANDING_OUT_DIR || join(REPO_ROOT, "public")


async function transpile() {
  const quartzTmp = process.env.QUARTZ_LANDING_TMP_DIR
  if (!quartzTmp) {
    throw new Error("Set QUARTZ_LANDING_TMP_DIR to the Quartz staging directory so we can reuse its node_modules.")
  }
  const { build } = requireFromQuartz()("esbuild")
  // Symlink missing packages into a private node_modules so the bundle resolves
  // `preact/jsx-runtime` regardless of how Quartz's tmp dir is reused.
  const landingNm = join(COMPONENTS_DIR, ".node_modules")
  mkdirSync(landingNm, { recursive: true })
  for (const pkg of ["preact", "preact-render-to-string"]) {
    const from = join(quartzTmp, "node_modules", pkg)
    const to = join(landingNm, pkg)
    const { existsSync, symlinkSync, lstatSync, rmSync } = await import("node:fs")
    try {
      if (existsSync(to)) rmSync(to, { recursive: true, force: true })
      if (existsSync(from)) symlinkSync(from, to, "dir")
    } catch {
      /* ignore */
    }
  }
  return build({
    entryPoints: [join(COMPONENTS_DIR, "awsLanding.tsx")],
    bundle: true,
    format: "esm",
    platform: "node",
    target: "es2022",
    outfile: join(COMPONENTS_DIR, ".awsLanding.bundle.mjs"),
    loader: { ".tsx": "tsx", ".ts": "ts" },
    logLevel: "warning",
    jsx: "automatic",
    jsxImportSource: "preact",
    nodePaths: [join(quartzTmp, "node_modules"), landingNm],
  })
}

function shellOuter(html) {
  return `<!doctype html>
<html lang="\${LANG}" dir="ltr">
<head>
<meta charset="utf-8" />
<base href="\${BASE}" />
<title>\${TITLE}</title>
<meta name="description" content="\${DESCRIPTION}" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<link rel="icon" href="\${FAVICON}" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="\${FONT_CSS}" />
<link rel="stylesheet" href="\${LOCAL_CSS}" />
<link rel="alternate" hreflang="en" href="\${EN_URL}" />
<link rel="alternate" hreflang="ru" href="\${RU_URL}" />
</head>
<body data-slug="\${SLUG}" data-landing>
\${CONTENT}
<script>
\${AFTER_SCRIPT}
</script>
</body>
</html>`
}

function renderHtml(lang) {
  return new Promise((resolveProm, rejectProm) => {
    ;(async () => {
      try {
        const bundleUrl = pathToFileURL(join(COMPONENTS_DIR, ".awsLanding.bundle.mjs")).href
        const bundled = await import(bundleUrl)
        const component = bundled.default()
        const vnode = component({ fileData: { frontmatter: { lang } } })
        const renderModule = requireFromQuartz()("preact-render-to-string")
        return resolveProm(renderModule.renderToStaticMarkup(vnode))
      } catch (err) {
        return rejectProm(err)
      }
    })()
  })
}

function normalizeRoot(pathStr) {
  if (!pathStr) return "/"
  return pathStr.endsWith("/") ? pathStr : pathStr + "/"
}

function absUrl(root, slug) {
  return "https://11111000000.github.io" + root + slug
}

const EN = {
  lang: "en",
  slug: "",
  outPath: "index.html",
  title: "Agents Writing Skills — Write less like a model",
  description:
    "Skills, prompts, and an Obsidian knowledge base for agents that write, edit, and audit prose with measurable AI-pattern checks.",
}

const RU = {
  lang: "ru",
  slug: "ru",
  outPath: "ru/index.html",
  title: "Agents Writing Skills — Писать меньше, как модель",
  description:
    "Skills, prompts и Obsidian-база знаний для агентов, которые пишут, правят и проверяют прозу по измеримым AI-маркерам.",
}

async function writeOne(page, baseHref) {
  const html = await renderHtml(page.lang)
  const htmlStr = Array.isArray(html) ? html.join("") : String(html)
  const cssMatch = htmlStr.match(/<style>([\s\S]*?)<\/style>/)
  const inlineCss = cssMatch ? cssMatch[1] : ""
  const bodyMatch = htmlStr.match(/<body[^>]*>([\s\S]*?)<\/body>/)
  let bodyContent = bodyMatch ? bodyMatch[1] : htmlStr
  bodyContent = bodyContent.replace(/<script[\s\S]*?<\/script>/g, "")

  const root = normalizeRoot(baseHref)
  const pageRoot = root + (page.slug ? page.slug + "/" : "")
  const enUrl = absUrl(root, "")
  const ruUrl = absUrl(root, "ru/")
  const outFile = join(outDir, page.outPath)
  mkdirSync(dirname(outFile), { recursive: true })

  const out = `<!doctype html>
<html lang="${page.lang}" dir="ltr">
<head>
<meta charset="utf-8" />
<base href="${pageRoot}" />
<title>${page.title}</title>
<meta name="description" content="${page.description.replace(/"/g, "&quot;")}" />
<meta property="og:title" content="${page.title.replace(/"/g, "&quot;")}" />
<meta property="og:type" content="website" />
<meta property="og:description" content="${page.description.replace(/"/g, "&quot;")}" />
<meta property="og:url" content="${absUrl(root, page.slug ? page.slug + "/" : "")}" />
<meta property="og:locale" content="${page.lang}" />
<meta property="og:site_name" content="Agents Writing Skills" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="${page.title.replace(/"/g, "&quot;")}" />
<meta name="twitter:description" content="${page.description.replace(/"/g, "&quot;")}" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<link rel="icon" href="${pageRoot}static/icon.png" />
<link rel="alternate" hreflang="en" href="${enUrl}" />
<link rel="alternate" hreflang="ru" href="${ruUrl}" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Newsreader:ital,wght@0,400;0,600;1,400&family=Inter:wght@400;600;700&family=JetBrains+Mono:wght@400;700&display=swap" />
<style>
${inlineCss}
html, body { background: #f0e9d6; color: #1a140c; font-family: Inter, ui-sans-serif, system-ui, -apple-system, sans-serif; }
body { margin: 0; padding: 0; min-height: 100vh; }
a { color: inherit; }
</style>
</head>
<body data-slug="${page.slug || "index"}" data-landing="${page.lang}">
${bodyContent}
<script>
\(() => {
  if (typeof window === "undefined") return;
  const root = document.querySelector(".aws-landing");
  if (!root) return;
  const progress = root.querySelector(".aws-progress");
  const shell = root.querySelector(".aws-shell");
  const topbar = root.querySelector(".aws-topbar");
  function tick() {
    if (!progress || !shell) return;
    const rect = shell.getBoundingClientRect();
    const total = shell.scrollHeight - window.innerHeight;
    const scrolled = Math.min(Math.max(-rect.top, 0), total);
    const ratio = total > 0 ? scrolled / total : 0;
    shell.style.setProperty("--aws-scroll", ratio.toFixed(4));
    if (topbar) {
      if (rect.top < -10) topbar.classList.add("scrolled");
      else topbar.classList.remove("scrolled");
    }
  }
  function raf() { if ("requestAnimationFrame" in window) requestAnimationFrame(tick); else tick(); }
  window.addEventListener("scroll", raf);
  window.addEventListener("resize", tick);
  tick();
  if ("IntersectionObserver" in window) {
    const io = new IntersectionObserver((es) => {
      es.forEach((e) => { if (e.isIntersecting) { e.target.classList.add("is-in"); io.unobserve(e.target); } });
    }, { rootMargin: "-10% 0px", threshold: 0.08 });
    root.querySelectorAll(".aws-reveal").forEach((el) => io.observe(el));
  } else {
    root.querySelectorAll(".aws-reveal").forEach((el) => el.classList.add("is-in"));
  }
})();
</script>
</body>
</html>
`
  writeFileSync(outFile, out, "utf-8")
  console.log("[landing] wrote", outFile, "size=" + out.length)
}

async function main() {
  console.log("[landing] transpiling awsLanding.tsx ...")
  await transpile()
  console.log("[landing] out dir:", outDir)

  for (const page of [EN, RU]) {
    await writeOne(page, "/agents-writing-skills/")
  }
}

main().catch((err) => {
  console.error("[landing] fatal:", err && err.stack ? err.stack : err)
  process.exit(1)
})
