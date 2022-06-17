---
layout: post
title: Deploying Through Seed
lang: en
date: 2018-03-14 00:00:00
description: We are going to trigger a deployment in Seed by pushing a commit to our full-stack serverless project in Git. In the Seed console you can view the build logs and look at the stack outputs.
ref: deploying-through-seed
comments_id: deploying-through-seed/177
---

Now, we are almost ready to make our first deployment. Our app also contains a React app in the `frontend/` directory. We need to make sure to run an `npm install` in that directory. Create React App also fails the build on any warnings in a CI, so we'll disable that flag.

Let's quickly add a build script to do this.

{%change%} Create a new file in your project root called `seed.yml` with.

``` yml
before_build:
  - echo 'export CI=false' >> $BASH_ENV
  - cd frontend && npm install
```

{%change%} And let's commit and push this change.

``` bash
$ git add .
$ git commit -m "Adding a seed build spec"
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

![Notes app in production](/assets/part2/notes-app-in-production.png)

To give it a quick test, sign up for a new account and create a note.

![Create notes in production](/assets/part2/create-notes-in-production.png)

You can also test updating and removing a note. And also test out the billing page.

So we are almost ready to wrap things up. But before we do, we want to cover one final really important topic; how to monitor and debug errors when your app is live.
