import { SSTConfig } from "sst";
import { StaticSite } from "sst/constructs";

export default {
  config(_input) {
    return {
      name: "sst-dev",
      region: "us-east-1",
    };
  },
  stacks(app) {
    app.stack(function Site({ stack }) {
      const site = new StaticSite(stack, "site", {
        errorPage: "404.html",
        buildOutput: "_site",
        buildCommand: "bundle exec jekyll build",
      });

      stack.addOutputs({
        Url: site.url,
      });
    });
  },
} satisfies SSTConfig;
