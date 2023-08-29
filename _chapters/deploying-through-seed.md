---
layout: post
title: Deploying Through Seed
lang: en
date: 2018-03-14 00:00:00
description: We are going to trigger a deployment in Seed by pushing a commit to our full-stack serverless project in Git. In the Seed console you can view the build logs and look at the stack outputs.
ref: deploying-through-seed
comments_id: deploying-through-seed/177
---

Now, we are ready to make our first deployment. You can either Git push a new change to master to trigger it.

Let’s do it through Git.

{%change%} Go to your project root and run the following.

```bash
$ npm version patch
```

This is simply updating the npm version for your project. It is a good way to keep track of the changes you are making to your project. And it also creates a quick Git commit for us.

{%change%} Push the change using.

```bash
$ git push
```

Now if you head into the **prod** stage in Seed, you should see a build in progress. To check out the build logs, you can click the **v1** link.

![Seed prod build in progress](/assets/part2/seed-prod-build-in-progress.png)

Here you'll see the build taking place live. Click on the **notes** service that is being deployed.

![Prod build details](/assets/part2/prod-build-details.png)

You'll see the build logs for the in progress build here.

![Prod build logs in progress](/assets/part2/prod-build-logs-in-progress.png)

Notice the tests are being run as a part of the build.

![Prod build run tests](/assets/part2/prod-build-run-tests.png)

Once the build is complete, you'll notice all the stack outputs at the bottom.

![Prod build stack outputs](/assets/part2/prod-build-stack-outputs.png)

### Test Our App in Production

Let's check out our app in production.

![App update live screenshot](/assets/part2/app-update-live.png)

To give it a quick test, sign up for a new account and create a note. You can also test updating and removing a note. And also test out the billing page.

**Congrats! Your app is now live!**

Let's wrap things up next.
