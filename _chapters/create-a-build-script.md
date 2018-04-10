---
layout: post
title: Create a build script
date: 2017-05-30 00:00:00
description:
comments_id:
---

Before we can add our project to [Netlify](https://www.netlify.com) we just need to set up a build script. If you recall, we had configured our app to use the `REACT_APP_STAGE` build environment variable. We are going to create a build script to tell Netlify to set this variable up for the different deployment cases.

### Add the Netlify build script

Start by adding the following to `netlify.toml` to your project root.

``` toml
# Global settings applied to the whole site.
# “base” is directory to change to before starting build, and
# “publish” is the directory to publish (relative to root of your repo).
# “command” is your build command.

[build]
  base    = ""
  publish = "build"
  command = "REACT_APP_STAGE=staging npm run build:netlify"

# Production context: All deploys to the main
# repository branch will inherit these settings.
[context.production]
  command = "REACT_APP_STAGE=production npm run build:netlify"

# Deploy Preview context: All Deploy Previews
# will inherit these settings.
[context.deploy-preview]
  command = "REACT_APP_STAGE=staging npm run build:netlify"

# Branch Deploy context: All deploys that are not in
# an active Deploy Preview will inherit these settings.
[context.branch-deploy]
  command = "REACT_APP_STAGE=staging npm run build:netlify"
```

The build script is configured based on contexts. There is a default one right up top. There are three parts to this:

1. The `base` is the directory where Netlify will run our build commands. In our case it is in the project root. So this is left empty.

2. The `publish` option points to where our build is generated. In the case of Create React App it is the `build` directory in our project root.

3. The `command` option is the build command that Netlify will use. If you recall the [Manage environments in Create React App]({% link _chapters/manage-environments-in-create-react-app.md %}) chapter, this will seem familiar. In the default context the command is `REACT_APP_STAGE=staging npm run build:netlify`. The `npm run build:netlify` is something we still need to set up. But the `REACT_APP_STAGE` is default to `staging` here.

The production context labelled, `context.production` is the only one where we set the `REACT_APP_STAGE` variable to `production`. This is when we push to `master`. The `branch-deploy` is what we will be using when we push to any other non-production branch. The `deploy-preview` is for pull requests.

### Handle HTTP Status Codes

Just as the first part of the tutorial, we'll need to handle requests to any non-root path of our app. Our frontend is a single-page app and the routing is handled on the client side. We need to tell Netlify to always redirect any request to our `index.html` and return the 200 status code for it.

To do this, create a `_redirects` in your project root and add the following.

```
/*    /index.html   200
```

### Modify the build command

Now as a part of our build process we need to move this `_redirects` file to the build directory, so that Netlify can pick it up. This needs us to modiy the build commands in our `package.json`.

Replace the `srcipts` block in your `package.json` with this.

``` json
"scripts": {
  "start": "react-scripts start",
  "build": "react-scripts build",
  "test": "react-scripts test --env=jsdom",
  "build:netlify": "npm run build && cp _redirects build/_redirects",
  "eject": "react-scripts eject"
}
```

You'll notice we are getting rid of our old build and deploy scripts. We are not going to be deploying to S3. And our `build` command is simply running the standard Create React App build command followed by copying the `_redirects` file to the `build/` directory.

### Commit our changes

Let's quickly commit these to git.

``` bash
$ git add.
$ git commit -m "Adding a Netlify build script"
```

### Push our changes

We are pretty much done making changes to our project, so let's go ahead and push them to GitHub.

``` bash
$ git push
```

 Now we are ready to add our project to Netlify. 
