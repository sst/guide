---
layout: post
title: Deploying Through the SST Console
lang: en
date: 2024-07-24 00:00:00
redirect_from: /chapters/deploying-through-seed.html
description: We are going to git push to deploy our app to production with the SST Console.
ref: deploying-through-the-sst-console
comments_id: deploying-through-the-sst-console/2958
---

Now, we are ready to _git push_ to deploy our app to production with the SST Console. If you recall from the [previous chapter]({% link _chapters/setting-up-the-sst-console.md %}), we configured it to auto-deploy the `production` branch. 

Let's do that by first creating a production branch.

{%change%} Run the following in the **project root**.

```bash
$ git checkout -b production
```

{%change%} Now let's push this to GitHub.

```bash
$ git push --set-upstream origin production
$ git push
```

Now if you head into the **Autodeploy** tab for your app in the SST Console, you'll notice a new deployment in progress.

![SST Console production deploy in progress](/assets/part2/sst-console-production-deploy-in-progress.png)

Once the deploy is complete, you'll notice the outputs at the bottom.

![Prod build stack outputs](/assets/part2/prod-build-stack-outputs.png)

### Test Our App in Production

Let's check out our app in production.

![App update live screenshot](/assets/part2/app-update-live.png)

To give it a quick test, sign up for a new account and create a note. You can also test updating and removing a note. And also test out the billing page.

**Congrats! Your app is now live!**

Let's wrap things up next.
