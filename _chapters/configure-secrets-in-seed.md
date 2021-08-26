---
layout: post
title: Configure Secrets in Seed
lang: en
date: 2018-03-13 00:00:00
description: To automate our serverless deployments with Seed, we will need to set our secrets in the Seed console. Move the environment variables from your .env.local to the stage we are deploying to.
ref: configure-secrets-in-seed
comments_id: configure-secrets-in-seed/176
---

Before we can make our first deployment, we need to make sure to configure our secret environment variables. If you'll recall, we have explicitly [not stored these in our code (or in Git)]({% link _chapters/handling-secrets-in-sst.md %}). This means that if somebody else on our team needs to deploy, we'll need to pass the `.env.local` file around. Instead we'll configure [Seed](https://seed.run) to deploy with our secrets for us.

We are also going to configure Seed to deploy our app to production when we push any changes to the `main` branch.

By default, Seed sets you up with two environments, `dev` and `prod`. Where pushing to the `main` branch would deploy to `dev`. And you'll need to promote your changes to `prod`. To keep things simple, we are only going to use the `prod` stage here and deploy directly to it.

To configure the above, click **dev** in your app **Settings**.

![Select dev stage in Settings](/assets/part2/select-dev-stage-in-settings.png)

Here **turn off the Auto-deploy** setting.

![Turn off auto-deploy for dev](/assets/part2/turn-off-auto-deploy-for-dev.png)

Then head over to the **prod** stage in your app **Settings**.

![Select prod stage in Settings](/assets/part2/select-prod-stage-in-settings.png)

Here **turn on the Auto-deploy** setting. 

![Turn on auto-deploy for prod](/assets/part2/turn-on-auto-deploy-for-prod.png)

You'll be prompted to select a branch. Select **main** and click **Enable**.

![Select branch to auto-deploy to prod](/assets/part2/select-branch-to-auto-deploy-to-prod.png)

Next, scroll down and click **Show Env Variables**.

![Show prod env variables settings](/assets/part2/show-prod-env-variables-settings.png)

And type in `STRIPE_SECRET_KEY` as the **Key**. We saved this in a `.env.local` file in our project root back from the [Handling Secrets in SST]({% link _chapters/handling-secrets-in-sst.md %}) chapter. Hit **Add** to save your secret key.

![Add secret prod environment variable](/assets/part2/add-secret-prod-environment-variable.png)

Next, we'll trigger our first deployment on Seed.
