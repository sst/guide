---
layout: post
title: Deploy the API Services Repo
description: In this chapter we'll deploy our demo API services GitHub repo of our Serverless app to multiple AWS environments. We'll be using Seed to manage our deployments and environments.
date: 2019-10-08 00:00:00
comments_id: deploy-the-api-services-repo/1319
---

Just as the previous chapter we'll add the API repo on Seed and deploy it to our environments.

Click **Add an App** again, and select your Git provider. This time, select the API repo.

![Select Add an App in Seed](/assets/best-practices/deploy-api-services-repo-to-seed/select-add-an-app-in-seed.png)

After detection, let's select the **notes-api** service.

![Select Serverless service to add](/assets/best-practices/deploy-api-services-repo-to-seed/select-serverless-service-to-add.png)

The environments for our API repo are identical to our resources repo. So instead of manually configuring them, we'll copy the settings.

Select **Copy Settings** tab, and select the resources app. Then hit **Add a New App**.

![Set app settings from resources](/assets/best-practices/deploy-api-services-repo-to-seed/set-app-settings-from-resources.png)

The API app has been created.

![Create an App in Seed](/assets/best-practices/deploy-api-services-repo-to-seed/create-an-app-in-seed.png)

Click **Add a service** to add the **billing-api** service at the `services/billing-api` path. And then repeat the step to add the **notify-job** service at the `services/notify-job` path.

![[Added all services in Seed](/assets/best-practices/deploy-api-services-repo-to-seed/[added-all-services-in-seed.png)

Head over to the app settings and click on **Manage Deploy Phases**.

![Hit Manage Deploy Phases screenshot](/assets/best-practices/deploy-api-services-repo-to-seed/hit-manage-deploy-phases-screenshot.png)

Again you'll notice that by default all the services are deployed concurrently.

![Default Deploy Phase screenshot](/assets/best-practices/deploy-api-services-repo-to-seed/default-deploy-phase-screenshot.png)

Since the **billing-api** service depends on the **notes-api** service, and in turn the **notify-job** service depends on the **billing-api** service, we are going too add 2 phases. And move the **billing-api** service to **Phase 2**, and the **notify-job** service to **Phase 3**. Finally, click **Update Phases**.

![Edit Deploy Phase screenshot](/assets/best-practices/deploy-api-services-repo-to-seed/edit-deploy-phase-screenshot.png)

Now let's make our first deployment.

![Show services are deploying in dev stage](/assets/best-practices/deploy-api-services-repo-to-seed/show-services-are-deploying-in-dev-stage.png)

You can see the deployments are carried out according to the deploy phases specified.

Just as before, promote **dev** to **prod**.

![Select Promote in dev stage](/assets/best-practices/deploy-api-services-repo-to-seed/select-promote-in-dev-stage.png)

Hit **Promote to Production**.

![Promote dev stage to prod stage](/assets/best-practices/deploy-api-services-repo-to-seed/promote-dev-stage-to-prod-stage.png)

Now we have the API deployed to both **dev** and **prod**.

![Show services are deployed in prod stage](/assets/best-practices/deploy-api-services-repo-to-seed/show-services-are-deployed-in-prod-stage.png)

Now that our entire app has been deployed, let's look at how we are sharing environment specific configs across our services.
