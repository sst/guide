---
layout: post
title: Create a Netlify Build Script
date: 2018-03-26 00:00:00
lang: en
description: To configure our Create React App with Netlify, we need to add a build script to our project root. To make sure that we return a HTTP status code of 200 for our React Router routes we will be adding a redirects rule.
ref: create-a-netlify-build-script
redirect_from: /chapters/create-a-build-script.html
comments_id: create-a-build-script/189
---

To automate our React.js deployments with [Netlify](https://www.netlify.com) we just need to set up a build script. If you recall from the [previous chapter]({% link _chapters/manage-environments-in-create-react-app.md %}), we had configured our app to use the `REACT_APP_STAGE` build environment variable. We are going to create a build script to tell Netlify to set this variable up for the different deployment cases.

### Add the Netlify Build Script

{%change%} Start by adding the following to a file called `netlify.toml` to your project root.

``` toml
# Global settings applied to the whole site.
# “base” is directory to change to before starting build, and
# “publish” is the directory to publish (relative to root of your repo).
# “command” is your build command.

[build]
  base    = ""
  publish = "build"
  command = "REACT_APP_STAGE=dev npm run build"

# Production context: All deploys to the main
# repository branch will inherit these settings.
[context.production]
  command = "REACT_APP_STAGE=prod npm run build"

# Deploy Preview context: All Deploy Previews
# will inherit these settings.
[context.deploy-preview]
  command = "REACT_APP_STAGE=dev npm run build"

# Branch Deploy context: All deploys that are not in
# an active Deploy Preview will inherit these settings.
[context.branch-deploy]
  command = "REACT_APP_STAGE=dev npm run build"
```

The build script is configured based on contexts. There is a default one right up top. There are three parts to this:

1. The `base` is the directory where Netlify will run our build commands. In our case it is in the project root. So this is left empty.

2. The `publish` option points to where our build is generated. In the case of Create React App it is the `build` directory in our project root.

3. The `command` option is the build command that Netlify will use. If you recall the [Manage environments in Create React App]({% link _chapters/manage-environments-in-create-react-app.md %}) chapter, this will seem familiar. In the default context the command is `REACT_APP_STAGE=dev npm run build`.

The production context labelled, `context.production` is the only one where we set the `REACT_APP_STAGE` variable to `prod`. This is when we push to `master`. The `branch-deploy` is what we will be using when we push to any other non-production branch. The `deploy-preview` is for pull requests.

If you commit and push your changes to Git, you'll see Netlify pick up your build script.
