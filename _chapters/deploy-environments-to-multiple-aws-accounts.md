---
layout: post
title: Deploy environments to multiple AWS accounts
description: 
date: 2019-09-30 00:00:00
comments_id: 
---

Now that you have a couple of AWS accounts created and your resources have been parameterized, let's look at how to deploy them. In this chapter, we'll deploy the following:

1. The [resources repo]({{ site.backend_ext_resources_github_repo }}) will be deployed in phases to the `dev` and `prod` stage. These two stages are configured in our `Development` and `Production` AWS accounts respectively.

2. Do the same with the [APIs repo]({{ site.backend_ext_api_github_repo }}).

We'll later configure a couple of ephemeral stages for our API services.

TODO: UPDATE CREDENTIALS SECTION

### Configure AWS Profiles

Follow [setup up IAM users]({% link _chapters/create-an-iam-user.md %}) chapter to create an IAM user in your `Development` account. And take a note of the **Access key ID** and **Secret access key** for the user.

Setup the credentials in your local machine using the AWS CLI:

``` bash
$ aws configure --profile default
```

This sets the default IAM credentials to those of the Development account. Meaning when you run `sls deploy`, a service will get deployed into the Development account.

Repeat the step to create an IAM user in your `Production` account. And take a note of the credentials. We will not add the IAM credentials for the Production account on our local machine. This is because we do not want us to be able to deploy code to the Production environment EVER from our local machine.

Production deployment should always go through our CI/CD pipeline.

### Configure environments on Seed

First, add the resources repo on Seed.

Go in to your Seed account and select **Add an App**, and select your Git provider.
![](/assets/best-practices/deploy-envs-1.png)

After authentication, search for the resources repo, and select it.
![](/assets/best-practices/deploy-envs-2.png)

Select **Select Repo**.
![](/assets/best-practices/deploy-envs-3.png)

Seed will now auto detect the serverless services in the repo. After detection, select a service. Let's select the **auth** service. Then select **Add Service**. (We will add the other services in the steps to follow.)
![](/assets/best-practices/deploy-envs-4.png)

By default, Seed let's you configure two stages out of the box, a **Development** and a **Production** stage. Serverless Framework has a concept of stages. They are synonymous with environments. Recall that, in the previous chapter we used this stage name to parameterize our resource names.

Let's first configure the **Development** stage. Enter:
- **Stage Name**: dev
- **AWS IAM Access Key**" and **AWS IAM Secret Key**: the IAM credentials of the IAM user you created in your **Development** AWS account.
![](/assets/best-practices/deploy-envs-5.png)

Next, let's configure the **Production** stage. Uncheck **Use the same IAM credentials as the dev stage** since we want to use a different AWS account for **Production**. Then enter:
- **Stage Name**: dev
- **AWS IAM Access Key**" and **AWS IAM Secret Key**: the IAM credentials of the IAM user you created in your **Prroduction** AWS account.

Finally select **Add a New App**.
![](/assets/best-practices/deploy-envs-6.png)

Now, let's add the other services in the resources repo. Select **Add a Service**.
![](/assets/best-practices/deploy-envs-7.png)

Enter the path to the **database** service `services/database`. Then select **Search**.
![](/assets/best-practices/deploy-envs-8.png)

Seed will search for the `serveless.yml` file in the path, to ensure you entered the right path. Select **Add Service**.
![](/assets/best-practices/deploy-envs-9.png)

Now you have 2 services.
![](/assets/best-practices/deploy-envs-10.png)

Repeat the process and add the **uploads** service in `services/uploads`. Now you have 3 services.
![](/assets/best-practices/deploy-envs-11.png)

Before we deploy, let's make sure the services will deploy in the desired order. Recall the deploying-in-phases chapter, you can configure the phases by heading to the app settings.
![](/assets/best-practices/deploy-envs-12.png)

Scroll down and select **Manage Deploy Phases**.
![Hit Manage Deploy Phases screenshot](/assets/best-practices/reploy-envs-13.png)

Here you'll notice that by default all the services are deployed concurrently.

![Default Deploy Phase screenshot](/assets/best-practices/reploy-envs-14.png)

Select **Add a phase** and move the **auth** service to **Phase 2**. And select **Update Phases**.

![Edit Deploy Phase screenshot](/assets/best-practices/reploy-envs-15.png)

Now let's make our first deployment. Select **Deploy** under the **dev** stage.
![](/assets/best-practices/deploy-envs-16.png)

Select **Deploy**.
![](/assets/best-practices/deploy-envs-17.png)

All services are being deployed.
![](/assets/best-practices/deploy-envs-18.png)

After all services are successfully deploy. Select the build **v1**.
![](/assets/best-practices/deploy-envs-19.png)

You can see the deployments are carried out according to the deploy phases specified.

![Deploying with Deploy Phase screenshot](/assets/best-practices/deploy-envs-20.png)


### Configure environments for the API repo

Let's repeat the steps and add the api repo on Seed.

Select **Add an App** again, and select your Git provider. This time, select the api repo.
![](/assets/best-practices/deploy-envs-21.png)

After detection, let's select the **notes-api** service.
![](/assets/best-practices/deploy-envs-22.png)

Since the environment setup for our api repo is identical to our resources repo. Instead of manually configuring **dev** and **prod**, we will copy our resources settings.

Select **Copy Settings** tab, and select the resources app. Then select **Add a New App**.
![](/assets/best-practices/deploy-envs-23.png)

The api app is created.
![](/assets/best-practices/deploy-envs-24.png)

Select **Add a service** to add the **billing-api** service at the `services/billing-api` path. And then repeat the step to add the **notify-job** service at the `services/notify-job` path.
![](/assets/best-practices/deploy-envs-25.png)

Heading to the app settings and go in to **Manage Deploy Phases**.
![](/assets/best-practices/reploy-envs-26.png)

Again you'll notice that by default all the services are deployed concurrently.

![](/assets/best-practices/reploy-envs-27.png)

Since the **billing-api** service depends on the **notes-api** service, and in turn the **notify-job** service depends on the **billing-api** service, we are going too add 2 phases. And move the **billing-api** service to **Phase 2**, and the **notify-job** service to **Phase 3**. Then select **Update Phases**.

![](/assets/best-practices/reploy-envs-28.png)

Now let's make our first deployment. You can see the deployments are carried out according to the deploy phases specified.

![](/assets/best-practices/reploy-envs-29.png)

Now that our entire app has been deployed, let's look at how we are sharing environment specific config across our services.
