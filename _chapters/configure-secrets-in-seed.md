---
layout: post
title: Configure secrets in Seed
date: 2017-05-30 00:00:00
description:
comments_id:
---

Before we can do our first deployment, we need to make sure to configure our secret environment variables. If you'll recall, we have explicitly not stored these in our code. This means that if soembody else on our team needs to deploy, we'll need to pass the `env.yml` file around. That is not a good practice. Instead we'll configure [Seed](https://seed.run) to deploy with our secrets for us.

To do that, hit the **Settings** button in our **dev** stage.

- Screenshot

Here click **Show Env Variables**.

- Screenshot

And type in `stripeSecretKey` as the **Key** and the value should be the `STRIPE_TEST_SECRET_KEY` back from the [Load secrets from env.yml]({% link _chapters/load-secrets-from-env-yml.md %}) chapter. Hit **Add** to save your secret key.

- Screenshot

Next we need to configure our secrets for the `prod` stage. Click the project name from the breadcrumb.

- Screenshot

And hit **prod** from the list of stages.

- Screenshot

Hit the **Settings** button.

- Screenshot

Click **Show Env Variables**.

- Screenshot

And type in `stripeSecretKey` as the **Key** and the value should be the `STRIPE_PROD_SECRET_KEY` back from the [Load secrets from env.yml]({% link _chapters/load-secrets-from-env-yml.md %}) chapter. Hit **Add** to save your secret key.

- Screenshot

Next, we'll trigger our first dpeloyment on Seed.
