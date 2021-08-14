---
layout: post
title: Configure Secrets in Seed
lang: en
date: 2018-03-13 00:00:00
description: To automate our Serverless deployments with Seed (https://seed.run), we will need to set our secrets in the Seed console. Move the environment variables from your .env to the stage we are deploying to.
ref: configure-secrets-in-seed
comments_id: configure-secrets-in-seed/176
---

Before we can do our first deployment, we need to make sure to configure our secret environment variables. If you'll recall, we have explicitly not stored these in our code (or in Git). TODO:LINK TO SECRETS CHAPTER This means that if somebody else on our team needs to deploy, we'll need to pass the `.env.local` file around. Instead we'll configure [Seed](https://seed.run) to deploy with our secrets for us.

To do that, hit **dev** in your app **Settings**.

![Select dev stage in Settings screenshot](/assets/part2/select-dev-stage-in-settings.png)

Here click **Show Env Variables**.

![Show dev env variables settings screenshot](/assets/part2/show-dev-env-variables-settings.png)

And type in `STRIPE_SECRET_KEY` as the **Key** and the value should be the `STRIPE_TEST_SECRET_KEY` back from the [Load secrets from env.yml]({% link _chapters/load-secrets-from-env.md %}) chapter. Hit **Add** to save your secret key.

![Add secret dev environment variable screenshot](/assets/part2/add-secret-dev-environment-variable.png)

Next we need to configure our secrets for the `prod` stage. Head over to the **prod** stage in your app **Settings**.

![Select prod stage in Settings screenshot](/assets/part2/select-prod-stage-in-settings.png)

Click **Show Env Variables**.

![Show prod env variables settings screenshot](/assets/part2/show-prod-env-variables-settings.png)

And type in `STRIPE_SECRET_KEY` as the **Key** and the value should be the `STRIPE_TEST_SECRET_KEY` back from the [Load secrets from env.yml]({% link _chapters/load-secrets-from-env.md %}) chapter. Hit **Add** to save your secret key.

![Add secret prod environment variable screenshot](/assets/part2/add-secret-prod-environment-variable.png)

Next, we'll trigger our first deployment on Seed.
