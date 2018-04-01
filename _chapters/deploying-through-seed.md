---
layout: post
title: Deploying through Seed
date: 2017-05-30 00:00:00
description:
comments_id:
---

Now, we are ready to make our first depolyment. You can either git push a new change to master to trigger it. Or we can just go into the **dev** stage and hit the **Trigger Deploy** button.

Let's do it through git.

Go back to your project root and run the following.

``` bash
$ npm version patch
```

This is simply updating the NPM version for your project. It is a good way to keep track of the changes you are making to your project. And it also creates a quick git commit for us.

Push the change using.

``` bash
$ git push
```

Now if you head into the **dev** stage in Seed, you should see a build in progress.

- Screenshot

Now to see the build logs, you can hit **Build v1**.

- Screenshot

Here you'll see the build taking place live.

- Screenshot

Something cool to note here is that, the build process is split into a few parts. First the code is checked out through git and the tests are run. But we don't directly deploy. Instead, we create a package for the `dev` stage and the `prod` stage. And finally we deploy to to `dev` with that package. The reason this is split up is because we don't want avoid the build process while promoting to `prod`. This ensures that if we have a tested working build, it should just work when we promote to production.

Once the build is complete, take a look at the build log and make a note of your Cognito User Pool Id, Cognito App Client Id, Cognito Region, Cognito Idently Pool Id, API Gateway region, and S3 Bucket name. We'll be needed this later in our frontend and when we test our APIs.

- Screenshot

You'll also notice that we are ready to promote to production.

- Screenshot

Again, we have a manual promotion step so that you get a chance to review the changes and ensure that you are indeed ready to push to production.

Hit the **Promote** button.

- Screenshot

This brings up a dialog that will generate what is called a CloudFormation Changeset. It compares the resources that are being updated with respect to what you have in production. In this case, it is our first commit so we don't have anything to compare to.

Hit **Confirm**.

- Screenshot

And if you head over to the **prod** stage, you should see your prod deployment in action.

- Screenshot

It should take a second to deploy to production. And just like before, take a look at the build log and make a note of your Cognito User Pool Id, Cognito App Client Id, Cognito Region, Cognito Idently Pool Id, API Gateway region, and S3 Bucket name.

Next let's configure our serverless API with a custom domain.
