---
layout: post
title: Deploying Only Updated Services
description: In this chapter we look at how to speed up deployments to our monorepo Serverless app by only redeploying the services that have been updated. We can do this by relying on the check Serverless Framework does. Or by looking at the Git log for the directories that have been updated.
date: 2019-10-02 00:00:00
comments_id: deploying-only-updated-services/1321
---

Once you are repeatedly deploying your Serverless application, you might notice that the Serverless deployments are not very fast. This is especially true if your app has a ton of service. There are a couple of things you can do here to speed up your builds. One of them is to only deploy the services that've been updated.

In this chapter we'll look at how to do that.

Note that, we are doing this by default in Seed. Recall that when we merged the **like** branch to the **master** branch, only the `like-api` service and the `notes-api` showed a solid check. The other two services showed a greyed out check mark. This means that there were no changes to be deployed for this service.

![Show deployment skipped in Seed](/assets/best-practices/deploy-only-changed-services/show-deployment-skipped-in-seed.png)

In a Serverless app with a single service, the deployment strategy in your CI/CD pipeline is straight forward: deploy my app on every git push.

However in a monorepo setup, an app is made up of many [Serverless Framework](https://serverless.com/) services. It’s not uncommon for teams to have apps with over 40 services in a single repo on [Seed](https://seed.run/). For these setups, it does not make sense to deploy all the services when all you are trying to do is fix a typo! You only want to deploy the services that have been updated because deploying all your services on every commit is:

1. Slow: deploying all services can take very long, especially when you are not deploying them concurrently.
2. Expensive: traditional CI services charge extra for concurrency. As of writing this chapter, it costs $50 for each added level of concurrency on [CircleCI](https://circleci.com/), hence it can be very costly to deploy all your services concurrently.

There are a couple of ways to only deploy the services that have been updated in your Serverless CI/CD pipeline.

### Strategy 1: Skip deployments in Serverless Framework

The `serverless deploy` command has built-in support to skip a deployment if the deployment package has not changed.

A bit of a background, when you run `serverless deploy`, two things are done behind the scenes. It first does a `serverless package` to generate a deployment package. This includes the CloudFormation template and the zipped Lambda code. Next, it does a `serverless deploy -p path/to/package` to deploy the package that was created. Before Serverless deploys the package in the second step, it first computes the hash of the package and compares it with that of the previous deployment. If the hash is the same, the deployment is skipped. We are simplifying the process here but that’s the basic idea.

However, there are two downsides to this.

1. Serverless still has to generate the deployment package first. For a Node.js application, this could mean installing the dependencies, linting, running Webpack, and finally packaging the code. Meaning that the entire process can still be pretty slow even if you skip the deployment.
2. If your previous deployment had failed due to an external cause, after you fix the issue and re-run `serverless deploy`, the deployment will be skipped. For example, you tried to create an S3 bucket in your `serverless.yml`, but you hit the 100 S3 buckets per account limit. You talked to AWS support and had the limit lifted. Now you re-run `serverless deploy` , but since neither the CloudFormation template or the Lambda code changed, the deployment will be skipped. To fix this, you need to use the `--force` flag to skip the check and force a deployment.

### Strategy 2: Check the Git log for changes

A better approach here is to check if there are any commits in a service directory before deploying that service.

When some code is pushed, you can run the following command to get a list of updated files:

``` bash
$ git diff --name-only ${prevCommitSHA} ${currentCommitSHA}
```

This will give you a list of files that have changed between the two commits. With the list of changed files, there are three scenarios from the perspective of a given service. We are going to use `notes-api` as an example:

1. A file was changed in my service directory (ie. `services/notes-api`) ⇒ we deploy the `notes-api` service
2. A file was changed in another service's directory (ie. `services/like-api`) ⇒ we do not deploy the `notes-api` service
3. Or, a file was changed in `libs/` ⇒ we deploy the `notes-api` service

Your repo setup can look different, but the general concept still holds true. You have to figure out which file change affects an individual service, and which affects all the services. The advantage of this strategy is that you know upfront which services can be skipped, allowing you to skip a portion of the entire build process!

And this concludes our section on the development workflow! Next, we'll look at how to trace our Serverless applications using AWS X-Ray.
