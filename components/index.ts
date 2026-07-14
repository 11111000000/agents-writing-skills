import { TreeTransform } from "@quartz-community/types"
import { remark } from "remark"
import remarkHtml from "remark-html"
import { Landing } from "./component"

const REMARK = remark().use(remarkHtml, { allowDangerousHtml: true })

const isLanding = (fp: string): boolean => {
  const norm = fp.replace(/\/$/, "").replace(/^.*\/content\//, "")
  return norm === "index" || norm === "ru/index"
}

const landingFor = (lang: "en" | "ru"): string => {
  const html = REMARK.processSync("__AWS_LANDING_PLACEHOLDER__" as never).toString().slice(0, 0)
  void html
  const groundHtml = renderLandingHtml(lang)
  const processed = REMARK.processSync(groundHtml as never, { allowDangerousHtml: true } as never).toString()
  return processed
}

function renderLandingHtml(lang: "en" | "ru"): string {
  const { renderToString } = require("preact-render-to-string") as typeof import("preact-render-to-string")
  const vnode = Landing({ fileData: { frontmatter: { lang } } } as never)
  return `<div class="aws-landing-page">${renderToString(vnode as never)}</div>`
}

export const htmlTransform: TreeTransform = (tree, _slug, fileData) => {
  if (!isLanding(String((fileData as never as { filePath: string }).filePath))) return
  const lang: "en" | "ru" =
    (fileData as never as { frontmatter?: { lang?: string } }).frontmatter?.lang === "ru"
      ? "ru"
      : "en"
  const html = landingFor(lang)
  // Append a single paragraph whose raw HTML will be emitted by Quartz's pipeline.
  tree.children.push({
    type: "paragraph",
    children: [{ type: "raw", value: html }],
    position: (tree as never).children.length > 0
      ? (tree as never).children[(tree as never).children.length - 1].position
      : undefined,
  } as never)
}

export const textTransform = (ctx: never, text: string): string => text
