---
layout: post
title: Frontend Workflow in Netlify
date: 2018-03-29 00:00:00
lang: en
description: There are three steps that are a part of workflow for a Create React App configured with Netlify. To work on new features create a new branch and enable branch deployments. And merge to master to deploy to production. Finally, publish an old deployment through the Netlify console to rollback in production.
redirect_from:
  - /chapters/update-the-app.html
  - /chapters/frontend-workflow.html
ref: frontend-workflow-in-netlify
comments_id: frontend-workflow/192
---

Now that we have our [Netlify build script configured]({% link _chapters/create-a-netlify-build-script.md %}), let's go over what our development workflow with Netlify will look like.

### Working in a Dev Branch

A good practise is to create a branch when we are working on something new.

{%change%} Run the following in the root of your project.

```bash
$ git checkout -b "new-feature"
```

This creates a new branch for us called `new-feature`.

Let's make a couple of quick changes to test the process of deploying updates to our app.

We are going to add a Login and Signup button to our lander to give users a clear call to action.

{%change%} To do this update our `renderLander` function in `src/containers/Home.js`.

```jsx
function renderLander() {
  return (
    <div className="lander">
      <h1>Scratch</h1>
      <p className="text-muted">A simple note taking app</p>
      <div className="pt-3">
        <Link to="/login" className="btn btn-info btn-lg mr-3">
          Login
        </Link>
        <Link to="/signup" className="btn btn-success btn-lg">
          Signup
        </Link>
      </div>
    </div>
  );
}
```

{%change%} And import the `Link` component from React-Router in the header.

```js
import { Link } from "react-router-dom";
```

And our lander should look something like this.

![App updated lander screenshot](/assets/app-updated-lander.png)

{%change%} Let's commit these changes to Git.

```bash
$ git add .
$ git commit -m "Updating the lander"
```

### Create a Branch Deployment

To be able to preview this change in its own environment we need to turn on branch deployments in Netlify. From the **Site settings** sidebar select **Build & deploy**.

![Select Build & deploy screenshot](/assets/part2/select-build-and-deploy.png)

And hit **Edit settings**.

![Edit build settings screenshot](/assets/part2/edit-build-settings.png)

Set **Branch deploys** to **All** and hit **Save**.

![Set branch deploys to all screenshot](/assets/part2/set-branch-deploys-to-all.png)

{%change%} Now comes the fun part, we can deploy this to dev so we can test it right away. All we need to do is push it to Git.

```bash
$ git push -u origin new-feature
```

Now if you hop over to your Netlify project page; you'll see a new branch deploy in action. Wait for it to complete and click on it.

![Click on new branch deploy screenshot](/assets/part2/click-on-new-branch-deploy.png)

Hit **Preview deploy**.

![Preview new branch deploy screenshot](/assets/part2/preview-new-branch-deploy.png)

And you can see a new version of your app in action!

![Preview deploy in action screenshot](/assets/part2/preview-deploy-in-action.png)

You can test around this version of our frontend app. It is connected to the dev version of our backend API. The idea is that we can test and play around with the changes here without affecting our production users.

### Push to Production

{%change%} Now if we feel happy with the changes we can push this to production just by merging to master.

```bash
$ git checkout master
$ git merge new-feature
$ git push
```

You should see this deployment in action in Netlify.

![Production deploy after merge screenshot](/assets/part2/production-deploy-after-merge.png)

And once it is done, your changes should be live!

![Production deploy is live screenshot](/assets/part2/production-deploy-is-live.png)

### Rolling Back in Production

Now for some reason if we aren't happy with the build in production, we can rollback.

Click on the older production deployment.

![Click on old production deployment screenshot](/assets/part2/click-on-old-production-deployment.png)

And hit **Publish deploy**. This will publish our previous version again.

![Publish old production deployment screenshot](/assets/part2/publish-old-production-deployment.png)

And that's it! Now you have a CI/CD pipeline for building and deploying your Create React App with serverless.
