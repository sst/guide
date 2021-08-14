---
layout: post
title: Setting up Your Project on Seed
date: 2018-03-12 00:00:00
lang: en
description: To automate our Serverless deployments, we will use a service called Seed (https://seed.run). We will sign up for a free account, add our project repository, and set our AWS IAM credentials.
ref: setting-up-your-project-on-seed
comments_id: setting-up-your-project-on-seed/175
---

We are going to use [Seed](https://seed.run) to automate our serverless deployments and manage our environments.

Start by [**signing up for a free account here**](https://console.seed.run/signup).

![Create new Seed account screenshot](/assets/part2/create-new-seed-account.png)

Let's **Add your first app**.

![Add your first Seed app screenshot](/assets/part2/add-your-first-seed-app.png)

Now to add your project, select **GitHub** as your git provider. You'll be asked to give Seed permission to your GitHub account.

![Select Git provider screenshot](/assets/part2/select-git-provider.png)

Select the repo we've been using so far.

Next, Seed will automatically detect the `sst.json` config in your repo. Click **Add Service**.

![Serverless.yml detected screenshot](/assets/part2/sst-json-detected.png)
TODO: RENAME FILENAME

Seed deploys to your AWS account on your behalf. You should create a separate IAM user with exact permissions that your project needs. You can read more about this [here](https://seed.run/docs/customizing-your-iam-policy). But for now we'll simply use the one we've used in this tutorial.

{%change%} Run the following command.

``` bash
$ cat ~/.aws/credentials
```

The output should look something like this.

``` txt
[default]
aws_access_key_id = YOUR_IAM_ACCESS_KEY
aws_secret_access_key = YOUR_IAM_SECRET_KEY
```

Seed will also create a couple of stages (or environments) for you. By default, it'll create a **dev** and a **prod** stage using the same AWS credentials. You can customize these but for us this is perfect.

Fill in the credentials and click **Add a New App**.

![Add AWS IAM credentials screenshot](/assets/part2/add-aws-iam-credentials.png)

Your new app is created. You'll notice a few things here. First, we have a service called **notes**. It's picking up the name from our `sst.json`. You can choose to change this by clicking on the service and editing its name.  You'll also notice the two stages that have been created.

Our app can have multiple services within it. A service (roughly speaking) is a reference to a `sst.json` or `serverless.yml` file (for Serverless Framework). In our case we just have the one service.

TODO: SS OF HOME PAGE
![Click pipeline screenshot](/assets/part2/click-pipeline.png)

Now before we proceed to deploying our app, we need to enable running unit tests as a part of our build process. You'll recall that we had added a couple of tests back in the [unit tests]({% link _chapters/unit-tests-in-serverless.md %}) chapter. And we want to run those before we deploy our app.

To do this, hit the **Settings** link and click **Enable Unit Tests**.

![Click Enable Unit Tests in Seed screenshot](/assets/part2/click-enable-unit-tsts-in-seed.png)

Back in our pipeline, you'll notice that our **dev** stage is hooked up to master. This means that any commits to master will trigger a build in dev.

However, before we do that, we'll need to add our secret environment variables.
