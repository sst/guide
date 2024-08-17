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
        customDomain:
          stack.stage === "prod"
            ? {
              hostedZone: "sst.dev",
              domainName: "guide.sst.dev",
            }
            : stack.stage.startsWith("branchv")
              ? {
                hostedZone: "archives.sst.dev",
                domainName: `${stack.stage}.archives.sst.dev`,
              }
              : undefined,
        errorPage: "404.html",
        buildOutput: "_site",
        buildCommand: "bundle install && bundle exec jekyll build",
      });

      stack.addOutputs({
        Url: site.customDomainUrl || site.url,
      });
    });
  },
} satisfies SSTConfig;
