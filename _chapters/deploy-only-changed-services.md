---
layout: post
title: Deploy only changed services
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

Notice when we merged the `recommendations` branch to the `master` branch, on Seed app page, only the `recommendations-api` service showed a solid check. The other four services showed a greyed out check. Grey check means there is no change to be deployed for this service.

![](/assets/best-practices/deploy-only-changed-services-1.png)

In a Serverless app with a single service, the deployment strategy in your CI/CD pipeline is straight forward: deploy my app on every git push.

However in a monorepo setup, an app is made up of many [Serverless Framework](https://serverless.com/) services. It’s not uncommon for teams to have apps with over 40 services in a single repo on [Seed](https://seed.run/). For these setups, it does not make sense to deploy all the services when all you are trying to do is fix a typo! You only want to deploy the services that have been updated because deploying all your services on every commit is:

1. Slow: deploying all services can take very long, especially when you are not deploying them concurrently.
2. Expensive: traditional CI services charge extra for concurrency. As of writing this post, it costs $50 for each added level of concurrency on [CircleCI](https://circleci.com/), hence it can be very costly to deploy all your services concurrently.

There are a couple of ways to only deploy the services that have been updated in your Serverless CI/CD pipeline.

# Strategy 1: Skip deployments in Serverless Framework

The `serverless deploy` command has built-in support to skip a deployment if the deployment package has not changed. A bit of a background, when you run `serverless deploy`, two things are done behind the scenes. It first does a `serverless package` to generate a deployment package. This includes the CloudFormation template and the zipped Lambda code. Next, it does a `serverless deploy -p path/to/package` to deploy the package that was created. Before Serverless deploys the package in the second step, it first computes the hash of the package and compares it with that of the previous deployment. If the hash is the same, the deployment is skipped. We are simplifying the process here but that’s the basic idea.

However, there are two downsides to this.

1. Serverless still has to generate the deployment package first. For a Node.js application, this could mean installing the dependencies, linting, running Webpack, and finally packaging the code. Meaning that the entire process can still be pretty slow even if you skip the deployment.
2. If your previous deployment had failed due to an external cause, after you fix the issue and re-run `serverless deploy`, the deployment will be skipped. For example, you tried to create an S3 bucket in your `serverless.yml`, but you hit the 100 S3 buckets per account limit. You talked to AWS support and had the limit lifted. Now you re-run `serverless deploy` , but since neither the CloudFormation template or the Lambda code changed, the deployment will be skipped. To fix this, you need to use the `--force` flag to skip the check and force a deployment.

# Strategy 2: Check the Git log for changes

A better approach here is to check if there are any commits in a service directory before deploying that service.

When some code is pushed, you can run the following command to get a list of updated files:
``` bash
$ git diff --name-only **${**prevCommitSHA**}** **${**currentCommitSHA**}**
```
This will give you a list of files that have changed between the two commits. With the list of changed files, there are three scenarios from the perspective of a given service. We are going to use `carts-api` as an example:

1. A file was changed in my service folder (ie. `services/carts-api`) ⇒ deploy carts-api
2. A file was changed in other service folder (ie. `services/recommendations-api`) ⇒ do not deploy carts-api
3. Or, a file was changed in `libs/` ⇒ deploy carts-api

Your repo setup can look different, but the general concept holds true. You have to figure out which file change affect an individual service, and which affects all the services. The advantage of this strategy is that you know upfront which services can be skipped. Allowing you to skip the entire build process!
