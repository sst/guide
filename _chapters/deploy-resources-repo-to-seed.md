---
layout: post
title: Deploy resources repo to Seed
description: In this chapter we'll deploy our demo resources GitHub repo of our Serverless app to multiple AWS environments. We'll be using Seed to manage our deployments and environments.
date: 2019-10-08 00:00:00
comments_id: 
---

First, add the resources repo on Seed. If you haven't yet, you can create a free account [here](https://console.seed.run/signup).

Go in to your [Seed account](https://console.seed.run) and click **Add an App**, and select your Git provider.

![](/assets/best-practices/deploy-envs-1.png)

After authenticating GitHub, search for the resources repo, and select it.

![](/assets/best-practices/deploy-envs-2.png)

Click **Select Repo**.

![](/assets/best-practices/deploy-envs-3.png)

Seed will now automatically detect the Serverless services in the repo. After detection, select a service. Let's select the **auth** service. Then click **Add Service**.

![](/assets/best-practices/deploy-envs-4.png)

By default, Seed lets you configure two stages out of the box, a **Development** and a **Production** stage. Serverless Framework has a concept of stages. They are synonymous with environments. Recall that in the previous chapter we used this stage name to parameterize our resource names.

Let's first configure the **Development** stage. Enter:
- **Stage Name**: dev
- **AWS IAM Access Key** and **AWS IAM Secret Key**: the IAM credentials of the IAM user you created in your **Development** AWS account above.

![](/assets/best-practices/deploy-envs-5.png)

Next, let's configure the **Production** stage. Uncheck **Use the same IAM credentials as the dev stage** checkbox since we want to use a different AWS account for **Production**. Then enter:
- **Stage Name**: dev
- **AWS IAM Access Key** and **AWS IAM Secret Key**: the IAM credentials of the IAM user you created in your **Production** AWS account above.

Finally hit **Add a New App**.

![](/assets/best-practices/deploy-envs-6.png)

Now, let's add the other services in the resources repo. Click **Add a Service**.

![](/assets/best-practices/deploy-envs-7.png)

Enter the path to the **database** service `services/database`. Then hit **Search**.

![](/assets/best-practices/deploy-envs-8.png)

Seed will search for the `serverless.yml` file in the path, to ensure you entered the right path. Hit **Add Service**.

![](/assets/best-practices/deploy-envs-9.png)

Now you have 2 services.

![](/assets/best-practices/deploy-envs-10.png)

Repeat the process and add the **uploads** service in `services/uploads`.

![](/assets/best-practices/deploy-envs-11.png)

TODO: UPDATE LINK

Before we deploy, let's make sure the services will deploy in the desired order. Recall from the [deploying-in-phases] chapter that you can configure the phases by heading to the app settings.

![](/assets/best-practices/deploy-envs-12.png)

Scroll down and select **Manage Deploy Phases**.

![Hit Manage Deploy Phases screenshot](/assets/best-practices/deploy-envs-13.png)

Here you'll notice that by default all the services are deployed concurrently.

![Default Deploy Phase screenshot](/assets/best-practices/deploy-envs-14.png)

Select **Add a phase** and move the **auth** service to **Phase 2**. And hit **Update Phases**.

![Edit Deploy Phase screenshot](/assets/best-practices/deploy-envs-15.png)

Now let's make our first deployment. Click **Deploy** under the **dev** stage.

![](/assets/best-practices/deploy-envs-16.png)

We are deploying the `master` branch here. Confirm this by clicking **Deploy**.

![](/assets/best-practices/deploy-envs-17.png)

You'll notice that all the services are being deployed.

![](/assets/best-practices/deploy-envs-18.png)

After all services are successfully deployed. Click the build **v1**.

![](/assets/best-practices/deploy-envs-19.png)

You can see that the deployments are carried out in the order specified by the deploy phases.

![Deploying with Deploy Phase screenshot](/assets/best-practices/deploy-envs-20.png)

Go back to the app dashboard, and hit **Promote** to deploy this to the **prod** stage.

![](/assets/best-practices/deploy-envs-20a.png)

TODO: UPDATE LINK

You will see a list of changes in resources. Since this is the first time we are deploying to the `prod` stage, the change list shows all the resources that will be created. We'll take a look at this in detail later in the [promote-to-production] chapter.

Click **Promote to Production**.

![](/assets/best-practices/deploy-envs-20b.png)

This will trigger the services to deploy in the same order we specified.

![](/assets/best-practices/deploy-envs-20c.png)

Now our resources have been deployed to both **dev** and **prod**.

![](/assets/best-practices/deploy-envs-20d.png)

Next, let's deploy our API services repo.
