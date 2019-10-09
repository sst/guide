---
layout: post
title: Share Route 53 Domains Across AWS Accounts
description: In this chapter we look at how to delegate Route 53 domains across AWS accounts. This allows us to use the same custom domain for our Serverless app across multiple environments.
date: 2019-10-02 00:00:00
comments_id: share-route-53-domains-across-aws-accounts/1334
---

Our notes app has an API Gateway endpoint. In this chapter, we are going to look at how to set up custom domains for each of our environments. Recall that our environments are split across multiple AWS accounts.

We are going to setup the following custom domain scheme:

- `prod` ⇒ ext-api.serverless-stack.com
- `dev` ⇒ dev.ext-api.serverless-stack.com

Assuming that our domain is hosted in our `Production` AWS account. We want to set it up so that our `Development` AWS account can use the above subdomain. This takes an extra setup.

### Delegate domains across AWS accounts

We are going to have to delegate the subdomain `dev.ext-api.serverless-stack.com` to be hosted in the `Development` AWS account. Just a quick note, as you follow these steps, pay attention to the account name shown at the top right corner of the screenshot. It'll tell you which account we are working with.

First, go into your Route 53 console in your `Development` account.

![Select Route 53 service](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-route-53-service.png)

Click **Hosted zones** in the left menu. Then select **Create Hosted Zone**.

![Select Create Hosted Zone](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-create-hosted-zone.png)

Select **Create Hosted Zone** at the top. Enter:

- **Domain Name**: dev.ext-api.serverless-stack.com

Then click **Create**.

![Created Hosted Zone in Route 53](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/created-hosted-zone-in-route-53.png)

Select the zone you just created.

![Select Hosted Zone in Route 53](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-hosted-zone-in-route-53.png)

Click on the row with **NS** type. And copy the 4 lines in the **Value** field. We need this in the steps after.

![Show NS Record Set in Route 53](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/show-ns-record-set-in-route-53.png)

Now, switch to the `Production` account where the domain is hosted. And go into Route 53 console.

Select the domain.

![Select Route 53 in Production account](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-route-53-in-production-account.png)

Click **Create Record Set**.

![Select Create Record Set](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-create-record-set.png)

Fill in:

- **Name**: dev.ext-api
- **Type**: NS - Name server

And paste the 4 lines from above in the **Value** field.

Click **Create**.

![Created Record Set in Route 53](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/created-record-set-in-route-53.png)

You should see a new `dev.ext-api.serverless-stack.com` row in the table.

![Show subdomain delegated to Development account](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/show-subdomain-delegated-to-development-account.png)

Now we've delegated the `dev.ext-api` subdomain of `serverless-stack.com` to our `Development` AWS account. You can now head over to your app or to Seed and [add this as a custom domain](https://seed.run/docs/configuring-custom-domains) for the `dev` stage.

Go to the API app, and head into app settings.

![Select app settings in Seed](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-app-settings-in-seed.png)

Select **Edit Custom Domains**.

![Select Edit Custom Domains](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-edit-custom-domains.png)

Both **dev** and **prod** endpoints are listed. Select **Add** on the **prod** endpoint.

![Select Add domain for prod stage](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-add-domain-for-prod-stage.png)

Select the domain **serverless-stack.com** and enter the subdomain **ext-api**. Then select **Add Custom Domain**.

![Select base domain and subdomain](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-base-domain-and-subdomain.png)

The creation process will go through a couple of phases of
- validating the domain is hosted on Route 53;
- creating the SSL certificate; and
- creating the API Gateway custom domain.
Some of the steps are short-lived so you might not see all of them.

![Show creating domain for prod stage](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/show-creating-domain-for-prod-stage.png)

The last step is update the CloudFront distribution, which can take up to 40 minutes. You will be waiting on this step.

![Show domain pending CloudFront update](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/show-domain-pending-cloudfront-update.png)

While we wait, let's setup the domain for our **dev** api. Select **Add**.

![Select Add domain for dev stage](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-add-domain-for-dev-stage.png)

Select the domain **dev.ext-api.serverless-stack.com** and leave the subdomain empty. Then select **Add Custom Domain**.

![Select base domain for dev stage](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/select-base-domain-for-dev-stage.png)

Similarly, you will wait for up to 40 minutes.

![Show domain pending for dev stage](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/show-domain-pending-for-dev-stage.png)

After 40 minutes, the domains will be ready.

![Show custom domain created](/assets/best-practices/sharing-route-53-domain-across-aws-accounts/show-custom-domain-created.png)

Now we've delegated the `dev.api` subdomain of `notes-app.com` to our `Development` AWS account. We'll be configuring our app to use [these domains in a later chapter]({% link _chapters/share-route-53-domains-across-aws-accounts.md %}).

Next, let's quickly look at how you'll be managing the cost and usage for your two AWS accounts.
