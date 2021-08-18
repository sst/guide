---
layout: post
title: Deploying Through Seed
lang: en
date: 2018-03-14 00:00:00
description: We are going to trigger a deployment in Seed by pushing a commit to our Serverless project in Git. In the Seed console you can view the build logs and look at the CloudFormation output.
ref: deploying-through-seed
comments_id: deploying-through-seed/177
---

Now, we are ready to make our first deployment. You can either Git push a new change to master to trigger it. Or we can just go into the **dev** stage and hit the **Trigger Deploy** button.

Let's do it through Git.

{%change%} Go back to our project root and run the following.

``` bash
$ npm version patch
```

This is simply updating the NPM version for your project. It is a good way to keep track of the changes you are making to your project. And it also creates a quick Git commit for us.

{%change%} Push the change using.

``` bash
$ git push
```

Now if you head into the **dev** stage in Seed, you should see a build in progress. Now to see the build logs, you can click the **v1** link.

![Seed dev build in progress](/assets/part2/seed-dev-build-in-progress.png)

Here you'll see the build taking place live. Click on the **notes** service that is being deployed.

TODO: UPDATE SS AND FILENAME
![Dev build page phase 1 in progress](/assets/part2/dev-build-page-phase-1-in-progress.png)

You'll see the build logs for the in progress build here.

![Dev build logs in progress](/assets/part2/dev-build-logs-in-progress.png)

Notice the tests are being run as a part of the build.

![Dev build run tests](/assets/part2/dev-build-run-tests.png)

Once the build is complete, you'll notice the outputs with the API and frontend URLs.

TODO: UPDATE SS AND FILENAME
![Dev build infrastructure output](/assets/part2/dev-build-infrastructure-output.png)

Now head over to the app home page. You'll notice that we are ready to promote to production.

We have a manual promotion step so that you get a chance to review the changes and ensure that you are ready to push to production.

Hit the **Promote** button.

![Dev build ready to promote](/assets/part2/dev-build-ready-to-promote.png)

This brings up a dialog that will generate a Change Set. It compares the resources that are being updated with respect to what you have in production. It's a great way to compare the infrastructure changes that are being promoted.

![Review promote change set](/assets/part2/review-promote-change-set.png)

Scroll down and hit **Promote to Production**.

![Confirm promote dev build](/assets/part2/confirm-promote-dev-build.png)

You'll notice that the build is being promoted to the **prod** stage.

![prod build in progress](/assets/part2/prod-build-in-progress.png)

Once complete, our app should be deployed to prod. We now have an automated workflow for building and deploying our full-stack serverless app.

### Test our app in production

Let's checkout our app in production.

![Notes app in production](/assets/part2/notes-app-in-production.png)

To give it a quick test, sign up for a new account and create a note.

![Create a notes in production](/assets/part2/create-a-note-in-production.png)

You can also test updating and removing a note. And also test out the billing page.

So we are almost ready to wrap things up. But before we do, we want to cover one final really important topic; how to monitor and debug errors when your app is live.
