---
layout: post
title: Frontend workflow
date: 2017-05-30 00:00:00
description:
comments_id:
---

Now that we have our frontend deployed and configured, let's go over what our development workflow will look like.

### Working in a dev branch

A good practise is to create a branch when we are working on something new.

Run the following in the root of your project.

``` bash
$ git checkout -b "new-feature"
```

This creates a new branch for us called `new-feature`.

Let's make a faulty commit just so we can go over the process of rolling back as well.

Replace the `renderLander` method in `src/containers/Home.js` with the following.

``` js
renderLander() {
  return (
    <div className="lander">
      <h1>Scratch</h1>
      <p>A very expensive note taking app</p>
      <div>
        <Link to="/login" className="btn btn-info btn-lg">
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

And to commit this change to git.

``` bash
$ git add.
$ git commit -m "Commiting a typo"
```

### Create a branch deployment

Now comes the fun part, we can deploy this to staging so we can test it right away. All we need to do is push it to git.

``` bash
$ git push -u origin new-feature
```

Now if you hop over to your Netlify project page; you'll see a new branch deploy in action.

- Screenshot

Once it is complete, you'll see that it gives you a new URL.

- Screenshot

You can test around this version of our frontend app. It is connected to the staging version of our backend API. The idea is that we can test and play around with the changes here without affecting our production users.

### Push to production

Now if we feel happy with the changes we can push this to production just by merging to master.

``` bash
$ git checkout master
$ git merge new-feature
$ git push
```

You should see this deployment in action in Netlify.

- Screenshot

And once it is done, your changes should be live!

- Screenshot

### Rolling back in production

Now for some reason we aren't happy with the build in production, we can rollback.

Head over to the **Production deploys**.

- Screenshot

Click on the older depoyment.

- Screenshot

And hit **Publish deploy**.

- Screenshot

This will publish our previous version again.

- Screenshot

And that's it! Now you have a automated workflow for building and deploying your Create React App with serverless.

### Cleanup

Let's quickly cleanup our changes.

Replace the `renderLander` method in `src/containers/Home.js` with the original.

``` js
renderLander() {
  return (
    <div className="lander">
      <h1>Scratch</h1>
      <p>A simply note taking app</p>
      <div>
        <Link to="/login" className="btn btn-info btn-lg">
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

Commit these changes and push them by running the following.

``` bash
$ git add.
$ git commit -m "Fixing a typo"
$ git push
```

This will create a new deployment and we are done. Let's wrap up the guide next.
