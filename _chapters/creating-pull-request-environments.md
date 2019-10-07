---
layout: post
title: Creating pull request environments
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

After local development is completed in the `like` branch, we are going to create a pull request.

# Enable Pull Request workflow on Seed

Go to your app on Seed. Select **Settings**.

![](/assets/best-practices/creating-pr-1.png)

Scroll down to **Git Integration**. Then select **Enable Auto-Deploy PRs**.

![](/assets/best-practices/creating-pr-2.png)

Select **Enable**.

![](/assets/best-practices/creating-pr-3.png)

# Create Pull Request

Go to GitHub, select the `like` branch. Then select **New pull request**.

Select **Create pull request**.

![](/assets/best-practices/creating-pr-4.png)

Select **Create pull request**.

![](/assets/best-practices/creating-pr-5.png)

Now go back to Seed, a new stage **pr2** is created and is being deployed automatically.

![](/assets/best-practices/creating-pr-6.png)

After `pr2` stage successfully deploys, you can see the deployed API endpoint on the PR page. You can give the endpoint to your frontend team for testing.

![](/assets/best-practices/creating-pr-7.png)

You can also access the `pr2` stage and the upstream `like` stage on Seed via the **View deployment** button. And you can see the deployment status for each service under **checks**.

![](/assets/best-practices/creating-pr-8.png)
