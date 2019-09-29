---
layout: post
title: Organizing Services
description: 
date: 2019-09-29 00:00:00
context: true
comments_id: 
---

Monorepo (monolithic repository) means you have a single repository to store the code for many projects. Creating a new project is very easy, you just add create a new directory in the repo and add the code in there. It is been famously adopted by Google and Facebook. On the other hand, multi-repo means you create a repository for each project.

What does this mean in the Serverless/Microservice world?

### An example

Let's look at this in detail with an example. Imagine you are making a shopping cart and your app has two API services, each has their own well defined business logic:

- **carts-api** service: Handles adding to and removing from the shopping cart
- **checkout-api** service: Handles making a purchase

And your app also two job services:

- **confirmation-job** service: Sends user confirmation emails after successfully making a purchase.
- **reset-cart-job** service: Handles resetting a shopping cart after a purchase is made.

And also:

- **dynamodb** service: Defines a DynamoDB table called `carts` used to store shopping cart data.
- **s3** service: Defines a S3 bucket used to store transaction receipts.

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

Why? Most of the code changes are going to happen in the **my-cart-app** repo. When your team is making rapid changes, you are likely going to have many feature branches, bug fixes, and pull requests. A bonus with serverless is that you can spin up new environments at zero cost (you only pay for usage, not for provisioning resources). For example, a team can have dozens of stages such as: prod, staging, dev, feature-x, feature-y, feature-z, bugfix-x, bugfix-y, pr-128, pr-132, etc. This ensures each change is tested on real infrastructure before being promoted to production.

On the other hand, changes are going to happen less frequently in the **my-cart-resources** app. And most likely you don't need a complete set of standalone DynamoDB tables for each feature branch. In fact, a team can have three stages such as: prod, staging, and dev. And the feature/bugfix/pr stages of the **my-cart-app** can all connect to the dev stage of the **my-cart-resources.**

[](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/79e74ef8-d3a1-4b42-9613-827e92ba5828/Untitled_drawing.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAT73L2G45G6M3HY7S%2F20190928%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20190928T183835Z&X-Amz-Expires=86400&X-Amz-Security-Token=AgoJb3JpZ2luX2VjELX%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLXdlc3QtMiJGMEQCIDL06Fze%2FjuIZRMtxzeitwAkxerpEh%2BWoxRpA882ChCyAiAamkWGMKDhKFTfXF5PHGalTPdUGG6rDEr7SYOpIV9MzSrjAwiO%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDI3NDU2NzE0OTM3MCIMNH0mAXlZvelFw9ahKrcDjn0J5Z4c1kd3eoXMHm3Zz7xblb%2FowfyAkG5pNm9FsEC7c3awBVwxd4zTcr6jKNWeTrmx1eIUIXBxjJd3xG9c3zSjZ6xkN%2Fq1mZMJqDSvd70YWHDc6vHntg1yD2i5%2FfGtRoSgsQLuZ7hpb265XEIzzQB0NhuO0IGiw1Y1HJVOgnM3zZDTez%2BwLDrdKrMOwL2bwth7o80YQWeWhjj2Cg0CQcDIpMSH0IClcS%2BPEsAisAJbgpcNQqVVunVS7EvwrrU85nljk6N20gsQrFfucll7Eqm%2B6YvHsJxlPWPdeGv9avvR1ZN%2B3ivvC9ot5pwp1AzbgwxbapgKoxwQMUIhqqM2UC0gGL4lhEptbPVBT02jgaPdrQG%2FkyH8c8cPgNvRj%2F79idZmcOxCmojtJ5dArqpqabxyMbCeOmzShU%2FwWLVt6sF54fgGqLvYs3qlkHdlyuChKafAbbEnZ%2FckS40cxa7Bgni4N7FMeQP9hqLWc5W5H7D%2FQDMfp7BZeOSqYaTf%2FTZ5eIhGE5%2BcpyBc0y43fdvRzA%2BZPzZjiBxeO8vPbl1ff108Mf24GVUCDf3Qn9KrddjmohAJiVI%2BIDCSp73sBTq1AZ5RA0gbgtr9kGPbBH3DDD6xBKX5ZuylAqJV5YNkB5JW%2F3DzlOSKAJ6RgIDO2WD%2BeJXK5p3EFMuiNUCn09xcSX4A953pJnb3nisFF5bANIlQLpPstK927luOnatKaMvVKt2RSZDREphJj5XbralP0fylk4SSN%2FyiiNIxDblbVX7QmvIMfb4iJZhpA%2BHsHNmAso5oKo8DAkwk523sI2bJcmxJys9k1%2BEf6voMJW7f7g6pbglYnP0%3D&X-Amz-Signature=7a12eaaa53bfc2f0b1939770ad7c1dcd95cb521da63a035b4db819aa2694a9f7&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled_drawing.png%22)

This is what we have most seen teams do. And this setup scales well as your project and team grows.

Now that we have decided to place all of our API services inside the same repo **my-cart-app**, let's take a look at how to organize the code inside it.
