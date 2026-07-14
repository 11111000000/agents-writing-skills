import { PluginManifest } from "@quartz-community/types"

const manifest: PluginManifest = {
  name: "aws-landing",
  displayName: "AWS Landing",
  description: "Landing-page component for agents-writing-skills.",
  version: "1.5.2",
  category: "component",
  components: {
    AWSLanding: {
      name: "AWSLanding",
      displayName: "AWS Landing",
      description: "Full landing page (topbar, hero, before/after compare, skills, three passes, research, install, footer).",
      version: "1.5.2",
      defaultPosition: "body",
      defaultPriority: 0,
    },
  },
}

export default manifest
export type { PluginManifest }
