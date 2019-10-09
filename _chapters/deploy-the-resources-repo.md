---
layout: post
title: Deploy the Resources Repo
description: In this chapter we'll deploy our demo resources GitHub repo of our Serverless app to multiple AWS environments. We'll be using Seed to manage our deployments and environments.
date: 2019-10-08 00:00:00
comments_id: 
---

First, add the resources repo on Seed. If you haven't yet, you can create a free account [here](https://console.seed.run/signup).

Go in to your [Seed account](https://console.seed.run) and click **Add an App**, and select your Git provider.

![Select Add an App in Seed](/assets/best-practices/deploy-resources-repo-to-seed/select-add-an-app-in-seed.png)

After authenticating GitHub, search for the resources repo, and select it.

![Search for Git repository](/assets/best-practices/deploy-resources-repo-to-seed/search-for-git-repository.png)

Click **Select Repo**.

![Select Git repository to add](/assets/best-practices/deploy-resources-repo-to-seed/select-git-repository-to-add.png)

Seed will now automatically detect the Serverless services in the repo. After detection, select a service. Let's select the **auth** service. Then click **Add Service**.

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

Now, let's add the other services in the resources repo. Click **Add a Service**.

![Select Add a Service](/assets/best-practices/deploy-resources-repo-to-seed/select-add-a-service.png)

Enter the path to the **database** service `services/database`. Then hit **Search**.

![Set new service path](/assets/best-practices/deploy-resources-repo-to-seed/set-new-service-path.png)

Seed will search for the `serverless.yml` file in the path, to ensure you entered the right path. Hit **Add Service**.

![Search serverless.yml in new service](/assets/best-practices/deploy-resources-repo-to-seed/search-serverless.yml-in-new-service.png)

Now you have 2 services.

![Added a service in Seed](/assets/best-practices/deploy-resources-repo-to-seed/added-a-service-in-seed.png)

Repeat the process and add the **uploads** service in `services/uploads`.

![Added all services in Seed](/assets/best-practices/deploy-resources-repo-to-seed/added-all-services-in-seed.png)

Before we deploy, let's make sure the services will deploy in the desired order. Recall from the [Deploy a Serverless app with dependencies]({% link _chapters/deploy-a-serverless-app-with-dependencies.md %}) chapter that you can configure the phases by heading to the app settings.

![Select app settings in Seed](/assets/best-practices/deploy-resources-repo-to-seed/select-app-settings-in-seed.png)

Scroll down and select **Manage Deploy Phases**.

![Hit Manage Deploy Phases screenshot](/assets/best-practices/deploy-resources-repo-to-seed/hit-manage-deploy-phases-screenshot.png)

Here you'll notice that by default all the services are deployed concurrently.

![Default Deploy Phase screenshot](/assets/best-practices/deploy-resources-repo-to-seed/default-deploy-phase-screenshot.png)

Select **Add a phase** and move the **auth** service to **Phase 2**. And hit **Update Phases**.

![Edit Deploy Phase screenshot](/assets/best-practices/deploy-resources-repo-to-seed/edit-deploy-phase-screenshot.png)

Now let's make our first deployment. Click **Deploy** under the **dev** stage.

![Select Deploy in dev stage](/assets/best-practices/deploy-resources-repo-to-seed/select-deploy-in-dev-stage.png)

We are deploying the `master` branch here. Confirm this by clicking **Deploy**.

![Select master branch to deploy](/assets/best-practices/deploy-resources-repo-to-seed/select-master-branch-to-deploy.png)

You'll notice that all the services are being deployed.

![Show services are deploying in dev stage](/assets/best-practices/deploy-resources-repo-to-seed/show-services-are-deploying-in-dev-stage.png)

After all services are successfully deployed. Click the build **v1**.

![Select Build v1 in dev stage](/assets/best-practices/deploy-resources-repo-to-seed/select-build-v1-in-dev-stage.png)

You can see that the deployments are carried out in the order specified by the deploy phases.

![Deployed with Deploy Phase screenshot](/assets/best-practices/deploy-resources-repo-to-seed/deployed-with-deploy-phase-screenshot.png)

Go back to the app dashboard, and hit **Promote** to deploy this to the **prod** stage.

![Select Promote in dev stage](/assets/best-practices/deploy-resources-repo-to-seed/select-promote-in-dev-stage.png)

You will see a list of changes in resources. Since this is the first time we are deploying to the `prod` stage, the change list shows all the resources that will be created. We'll take a look at this in detail later in the [Promoting to production]({% link _chapters/promoting-to-production.md %}) chapter.

Click **Promote to Production**.

![Promote dev stage to prod stage](/assets/best-practices/deploy-resources-repo-to-seed/promote-dev-stage-to-prod-stage.png)

This will trigger the services to deploy in the same order we specified.

![Show services are deploying in prod stage](/assets/best-practices/deploy-resources-repo-to-seed/show-services-are-deploying-in-prod-stage.png)

Now our resources have been deployed to both **dev** and **prod**.

![Show services are deployed in prod stage](/assets/best-practices/deploy-resources-repo-to-seed/show-services-are-deployed-in-prod-stage.png)

Next, let's deploy our API services repo.
