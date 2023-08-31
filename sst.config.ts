import { SSTConfig } from "sst";
import { StaticSite } from "sst/constructs";
import { HostedZone } from "aws-cdk-lib/aws-route53";
import { HttpsRedirect } from "aws-cdk-lib/aws-route53-patterns";

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
                domainName: "sst.dev",
                domainAlias: "www.sst.dev",
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

      // Redirect serverless-stack.com to sst.dev
      if (stack.stage === "prod") {
        new HttpsRedirect(stack, "Redirect", {
          recordNames: ["serverless-stack.com", "www.serverless-stack.com"],
          targetDomain: "sst.dev",
          zone: HostedZone.fromLookup(stack, "HostedZone", {
            domainName: "serverless-stack.com",
          }),
        });
      }

      stack.addOutputs({
        Url: site.url,
      });
    });
  },
} satisfies SSTConfig;
