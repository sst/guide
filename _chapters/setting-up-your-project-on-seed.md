---
layout: post
title: Setting up Your Project on Seed
date: 2018-03-12 00:00:00
lang: en
description: To automate our serverless deployments, we will use a service called Seed. We will sign up for a free account, add our project repository, and set our AWS IAM credentials.
ref: setting-up-your-project-on-seed
comments_id: setting-up-your-project-on-seed/175
---

We are going to use [Seed](https://seed.run) to automate our serverless deployments and manage our environments.

Start by [**signing up for a free account here**](https://console.seed.run/signup).

![Create new Seed account](/assets/part2/create-new-seed-account.png)

Let's **Add your first app**.

![Add your first Seed app](/assets/part2/add-your-first-seed-app.png)

Now to add your project, select **GitHub** as your git provider. You'll be asked to give Seed permission to your GitHub account.

![Select Git provider](/assets/part2/select-git-provider.png)

Select the repo we've been using so far.

Next, Seed will automatically detect the `sst.config.ts` file in your repo. Click **Add Service**.

![SST app detected](/assets/part2/sst-app-detected.png)

Seed uses an IAM role to deploy to your AWS account on your behalf. It's more secure than the IAM user we created previously in this guide. An IAM role gives Seed temporary IAM credentials to deploy your app. These credentials expire after a short period of time.

![Seed AWS IAM Role form](/assets/part2/seed-aws-iam-role-form.png)

You should create this IAM role with the exact permissions that your project needs. You can read more about this [here](https://seed.run/docs/customizing-your-iam-policy). But for now we'll simply use the default one.

![Seed create IAM role](/assets/part2/seed-create-iam-role.png)

Click the **Create an IAM Role using CloudFormation** button. This will send you to the AWS Console and ask you to create a CloudFormation stack.

![AWS create CloudFormation stack](/assets/part2/aws-create-cloudformation-stack.png)

Scroll down, **confirm** the checkbox at the bottom and click **Create stack**.

![AWS click create CloudFormation stack](/assets/part2/aws-click-create-cloudformation-stack.png)

It will take a couple of minutes to create the stack. Once complete, click the **Outputs** tab.

![AWS CloudFormation stack outputs](/assets/part2/aws-cloudformation-stack-outputs.png)

Copy the **RoleArn value**. Ours looks something like this.

```text
arn:aws:iam::206899313015:role/seed/seed-role-SeedRole-BXQYLZX7AB8J
```

Now back in Seed, you can paste the credentials.

![Add AWS IAM credentials](/assets/part2/add-aws-iam-credentials.png)

Seed will also create a couple of stages (or environments) for you. By default, it'll create a **dev** and a **prod** stage using the same AWS credentials. You can customize these but we'll use the defaults.

Finally click **Add a New App**.

Your new app is created. You'll notice a few things here. First, we have a service called **notes**. It's picking up the name from our `sst.config.ts` file. You can choose to change this by clicking on the service and editing its name.  You'll also notice the two stages that have been created.

![Seed app homepage](/assets/part2/seed-app-homepage.png)

Our app can have multiple services within it. A service (roughly speaking) is a reference to a `sst.config.ts` or `serverless.yml` file (for Serverless Framework). In our case we just have the one service.

Now before we proceed to deploying our app, we need to enable running unit tests as a part of our build process. You'll recall that we had added a couple of tests back in the [unit tests]({% link _chapters/unit-tests-in-serverless.md %}) chapter. And we want to run those before we deploy our app.

To do this, hit the **Settings** link and click **Enable Unit Tests**.

![Click Enable Unit Tests in Seed](/assets/part2/click-enable-unit-tsts-in-seed.png)

Back in our pipeline, you'll notice that our **dev** stage is hooked up to `main`. This means that any commits to `main` will trigger a build in dev. To keep things simple, we'll want to deploy to prod when we push to `main`.

Let's do that next.
