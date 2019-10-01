---
layout: post
title: Organizing Services
description: 
date: 2019-09-29 00:00:00
comments_id: 
---

Monorepo (monolithic repository) means you have a single repository to store the code for many projects. Creating a new project is very easy. You just create a new directory in the repo and add the code in there. It has been famously adopted by Google and Facebook. On the other hand, multi-repo means you create a repository for each project.

What does this mean in the Serverless/Microservice world?

### An example

Let's look at this in detail with an example. Imagine you are making a shopping cart and your app has two API services, each has their own well defined business logic:

- **carts-api** service: Handles adding to and removing from the shopping cart.
- **checkout-api** service: Handles making a purchase.

And your app also has two job services:

- **confirmation-job** service: Sends user confirmation emails after successfully making a purchase.
- **reset-cart-job** service: Handles resetting a shopping cart after a purchase has been made.

And also:

- **dynamodb** service: Defines a DynamoDB table called `carts` used to store shopping cart data.
- **s3** service: Defines an S3 bucket used to store transaction receipts.

In a Multi-repo setup, you are likely to have 6 repositories, one for each service. And in the Monorepo setup, you have one repository with all 6 services. It's not the goal of this section to evaluate which setup is better.

### A practical approach

Instead, I want to layout what we think is a good setup and one that has worked out for most teams we work with. We are taking a middle ground approach and creating two repositories:

1. **my-cart-resources**
2. **my-cart-app**

In **my-cart-resources**, you have:

```
/
  services/
    dynamodb/
    s3/
```

And in **my-cart-app**, you have:

```
/
  libs/
  services/
    carts-api/
    checkout-api/
    confirmation-job/
    reset-cart-job/
```

Why? Most of the code changes are going to happen in the **my-cart-app** repo. When your team is making rapid changes, you are likely to have many feature branches, bug fixes, and pull requests. A bonus with serverless is that you can spin up new environments at zero cost (you only pay for usage, not for provisioning resources). For example, a team can have dozens of stages such as: prod, staging, dev, feature-x, feature-y, feature-z, bugfix-x, bugfix-y, pr-128, pr-132, etc. This ensures each change is tested on real infrastructure before being promoted to production.

On the other hand, changes are going to happen less frequently in the **my-cart-resources** repo. And most likely you don't need a complete set of standalone DynamoDB tables for each feature branch. In fact, a team can have three stages such as: prod, staging, and dev. And the feature/bugfix/pr stages of the **my-cart-app** can all connect to the dev stage of the **my-cart-resources.**

TODO: UPDATE SCREENSHOT
![](/assets/best-practices/organizing-services-1.png)

This is what we have seen most teams do. And this setup scales well as your project and team grows.

Now that we have decided to place all of our API services inside the same repo **my-cart-app**, let's take a look at how to organize the code inside it.
