---
layout: post
title: Environments in Serverless Apps
description: In this chapter, we are going to be looking at the best practices of configuring environments for your Serverless app. Serverless allows us to easily create new environments since it's completely pay per use. This makes it ideal for creating ephemeral environments for new features, bugfixes, or pull requests.
date: 2019-09-30 00:00:00
comments_id: environments-in-serverless-apps/1323
---

In this section, we are going to be looking at the best practices of configuring environments for your Serverless app. But before we do that, let's quickly go over some of the concepts involved.

### Pay per use = multiple dev environments

Serverless apps and their associated services (Lambda, API Gateway, DynamoDB, etc.) all have a pay per use model. And it seems very likely that more AWS services are moving towards that model. Also, thanks to the [infrastructure as code]({% link _chapters/what-is-infrastructure-as-code.md %}) idea that Serverless uses, it's very easy to replicate environments. So creating multiple dev/staging environments is something that is highly recommended.

### Long lived environments

Serverless doesn't change how you setup long lived stages. You still have the usual `dev` stage, `prod` stage. And the intermediate stages in between such as `staging`, `qa`, `preprod`, etc. The larger your team, the more intermediate stages you tend to have.

### Ephemeral environments

During development, you usually have a number of development Git branches like feature branches or hotfix branches. In the traditional server world, many teams don't setup an environment for each of their branches. This is due to the infrastructure cost of setting up a new environment. And the manual work involved in doing so. In addition, once a branch is ready to be merged, a pull request is usually created. Ideally you want to deploy the temporarily merged version of code to a pull request environment. If you've used Heroku in the past, this is the idea behind their [Review Apps](https://devcenter.heroku.com/articles/github-integration-review-apps).

However, since creating new environments in Serverless is both convenient and cheap,  it's considered best practice to create these ephemeral stages. You want to configure your CI/CD pipeline to automatically bring these stages up, test against them, and tear them down once you are done.

Seed can automatically create stages for a [feature branch on branch creation](https://seed.run/docs/working-with-branches) and for [PRs on PR creation](https://seed.run/docs/working-with-pull-requests). It'll also automatically remove the stage and all the associated resources once the branch is removed or the PR is merged.

Next, let's configure our environments!
