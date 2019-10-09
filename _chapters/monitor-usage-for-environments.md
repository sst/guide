---
layout: post
title: Monitor Usage for Environments
description: AWS Organization gives us a good way to manage cost and usage for our AWS accounts. It allows us to easily manage the environments of our Serverless app.
date: 2019-10-02 00:00:00
comments_id: monitor-usage-for-environments/1328
---

So far we've split the environments for our Serverless app across two AWS accounts. But before we go ahead and look at the development workflow, let's look at how to manage the cost and usage for them.

Our accounts are organized under AWS Organizations. So you don’t have to setup the billing details for each account. Billing is consolidated to the master account. You can also see a breakdown of usage and cost for each service in each account.

### Free Tier

An added bonus of splitting up environments by AWS accounts is that each account in your AWS Organization benefits from the free tier.

For example, Lambda's free tier includes 400 000 seconds per month for 1GB memory Lambda function. That is 400 000 seconds for each of your AWS accounts! If the usage in your `Development` account ends up being low, you'll likely not be paying for it.

### Cost/Usage Breakdown by Account

Go into your master account. Select the account picker at the top. Then click **My Billing Dashboard**. 

![Select My Billing Dashboard](/assets/best-practices/manage-cost-and-usage-for-aws-accounts/select-my-billing-dashboard.png)

The Billing Dashboard homepage shows you the cost to date for the current calendar month. A couple of very useful features on this page are:

1. **Cost Explorer**: See the cost break down by day/week/month; by account; by resource tag; by service; etc.
2. **Budgets**: Set alert based on usage limits and cost limits.

Click on **Bill Details**.

![Select Bill Details screenshot](/assets/best-practices/manage-cost-and-usage-for-aws-accounts/select-bill-details-screenshot.png)

And click **Bill details by account**. Here you can see the cost allocation for each account.

![Select Bill details by account screenshot](/assets/best-practices/manage-cost-and-usage-for-aws-accounts/select-bill-details-by-account-screenshot.png)

This should give you a really good idea of the usage and cost for each of your environments.

Now we are ready to look at the development workflow for our app!
