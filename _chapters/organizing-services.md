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

Let's look at this in detail with an example. Your notes app has two API services, each has their own well defined business logic:

- **notes-api** service: Handles managing the notes.
- **billing-api** service: Handles making a purchase.

And your app also has a job service:

- **notify-job** service: Sends you a text message after a user successfully making a purchase.

And also:

- **auth** service: Defines a Cognito User and Identity pool used to store user data.
- **database** service: Defines a DynamoDB table called `notes` used to store notes data.
- **uploads** service: Defines an S3 bucket used to store note images.

In a Multi-repo setup, you are likely to have 6 repositories, one for each service. And in the Monorepo setup, you have one repository with all 6 services. It's not the goal of this section to evaluate which setup is better.

### A practical approach

Instead, I want to layout what we think is a good setup and one that has worked out for most teams we work with. We are taking a middle ground approach and creating two repositories:

1. **notes-resources**
2. **notes-api**

In **notes-resources**, you have:

```
/
  services/
    auth/
    database/
    uploads/
```

And in **notes-api**, you have:

```
/
  libs/
  services/
    notes-api/
    billing-api/
    notify-job/
```

Why? Most of the code changes are going to happen in the **notes-api** repo. When your team is making rapid changes, you are likely to have many feature branches, bug fixes, and pull requests. A bonus with serverless is that you can spin up new environments at zero cost (you only pay for usage, not for provisioning resources). For example, a team can have dozens of stages such as: prod, staging, dev, feature-x, feature-y, feature-z, bugfix-x, bugfix-y, pr-128, pr-132, etc. This ensures each change is tested on real infrastructure before being promoted to production.

On the other hand, changes are going to happen less frequently in the **notes-resources** repo. And most likely you don't need a complete set of standalone DynamoDB tables for each feature branch. In fact, a team can have three stages such as: prod, staging, and dev. And the feature/bugfix/pr stages of the **notes-api** can all connect to the dev stage of the **notes-resources.**

TODO: UPDATE SCREENSHOT
![](/assets/best-practices/organizing-services-1.png)

This is what we have seen most teams do. And this setup scales well as your project and team grows.

Now that we have decided to place all of our API services inside the same repo **notes-api**, let's take a look at how to organize the code inside it.
