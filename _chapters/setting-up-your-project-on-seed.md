---
layout: post
title: Setting up your project on Seed
date: 2017-05-30 00:00:00
description:
comments_id:
---

We are going to be using [Seed](https://seed.run) to automate our serverless dpeloyments and manage our environments.

Start by signing up for an account [here](https://console.seed.run/signup-account).

- Screenshot

Now to add your project, select **GitHub** as your git provider.

- Screenshot

You'll be asked to give Seed permission to your GitHub account.

- Screenshot

Next, select the repo we've been using so far.

- Screenshot

Seed deploys to your AWS account on your behalf. You should create a separate IAM user with exact permissions that your project needs. But for now we'll simply use the one we've used in this tutorial so far.

Run the following command.

``` bash
$ cat ~/.aws/credentials
```

The output should look something like this.

```
[default]
aws_access_key_id = YOUR_IAM_ACCESS_KEY
aws_secret_access_key = YOUR_IAM_SECRET_KEY
```

Fill these in to the form. And click **Create**.

- Screenshot

You'll notice we have two stages (environments) set up by default. Our **dev** stage is hooked up to master. This means that any commits to master will trigger a build in dev.

If you click on **dev**, you'll see that the stage is waiting to be deployed.

- Screenshot

However, before we do that, we'll need to add our secret environment variables.
