// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: "Promptly",
      logo: { src: "./src/assets/promptly_text_logo.svg", replacesTitle: true },
      social: {
        github: "https://github.com/zoocityboy/promptly",
      },
      sidebar: [
        {
          label: "Getting Started",
          autogenerate: { directory: "getting-started", collapsed: false },
        },
        {
          label: "Features",
          collapsed: true,
          items: [
            {
              label: "Components",
              autogenerate: { directory: "features/components" },
            },
            {
              label: "Messages",
              slug: "features/messages",
            },
            {
              label: "Footer",
              slug: "features/footer",
            },
          ],
        },
      ],
      customCss: ["./src/styles/landing.css", "./src/styles/custom.css"],
      expressiveCode: {
        useStarlightUiThemeColors: true,
        // styleOverrides: { borderRadius: "0rem" },
        // plugins: [pluginLineNumbers(), pluginCodeOutput()],
        // defaultProps: {
        //   showLineNumbers: false,
        // },
        themes: ["github-dark-default", "github-light-default"],
      },
      components: {
        Hero: "./src/components/Hero.astro",
      },
    }),
  ],
});
