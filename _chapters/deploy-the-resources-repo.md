---
layout: post
title: Deploy the Resources Repo
description: In this chapter we'll deploy our demo resources GitHub repo of our Serverless app to multiple AWS environments. We'll be using Seed to manage our deployments and environments.
date: 2019-10-08 00:00:00
comments_id: deploy-the-resources-repo/1320
---

First, add the resources repo on Seed. If you haven't yet, you can create a free account [here](https://console.seed.run/signup).

Go in to your [Seed account](https://console.seed.run), add a new app, authenticate with GitHub, search for the resources repo, and select it.

![Search for Git repository](/assets/best-practices/deploy-resources-repo-to-seed/search-for-git-repository.png)

Seed will now automatically detect the SST service in the repo. After detection, select **Add Service**.

![Select Serverless service to add](/assets/best-practices/deploy-resources-repo-to-seed/select-serverless-service-to-add.png)

By default, Seed lets you configure two stages out of the box, a **Development** and a **Production** stage. Serverless Framework has a concept of stages. They are synonymous with environments. Recall that in the previous chapter we used this stage name to parameterize our resource names.

Let's first configure the **Development** stage. Enter:
- **Stage Name**: dev
- **AWS IAM Access Key** and **AWS IAM Secret Key**: the IAM credentials of the IAM user you created in your **Development** AWS account above.

![Set dev stage IAM credentials](/assets/best-practices/deploy-resources-repo-to-seed/set-dev-stage-iam-credentials.png)

Next, let's configure the **Production** stage. Uncheck **Use the same IAM credentials as the dev stage** checkbox since we want to use a different AWS account for **Production**. Then enter:
- **Stage Name**: prod
- **AWS IAM Access Key** and **AWS IAM Secret Key**: the IAM credentials of the IAM user you created in your **Production** AWS account above.

Finally hit **Add a New App**.

![Create an App in Seed](/assets/best-practices/deploy-resources-repo-to-seed/create-an-app-in-seed.png)

Now let's make our first deployment. Click **Trigger Deployment** under the **dev** stage.

![Select Deploy in dev stage](/assets/best-practices/deploy-resources-repo-to-seed/select-deploy-in-dev-stage.png)

We are deploying the `master` branch here. Confirm this by clicking **Deploy**.

![Select master branch to deploy](/assets/best-practices/deploy-resources-repo-to-seed/select-master-branch-to-deploy.png)

You'll notice that the service is being deployed.

![Show service is deploying in dev stage](/assets/best-practices/deploy-resources-repo-to-seed/show-service-is-deploying-in-dev-stage.png)

After the service is successfully deployed. Click **Promote** to deploy this to the **prod** stage.

![Select Promote in dev stage](/assets/best-practices/deploy-resources-repo-to-seed/select-promote-in-dev-stage.png)

You will see a list of changes in resources. Since this is the first time we are deploying to the `prod` stage, the change list shows all the resources that will be created. We'll take a look at this in detail later in the [Promoting to production]({% link _chapters/promoting-to-production.md %}) chapter.

Click **Promote to Production**.

![Promote dev stage to prod stage](/assets/best-practices/deploy-resources-repo-to-seed/promote-dev-stage-to-prod-stage.png)

Now our resources have been deployed to both **dev** and **prod**.

![Show service is deployed in prod stage](/assets/best-practices/deploy-resources-repo-to-seed/show-service-is-deployed-in-prod-stage.png)

Next, let's deploy our API services repo.
