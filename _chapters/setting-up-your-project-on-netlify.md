---
layout: post
title: Setting up Your Project on Netlify
date: 2018-03-27 00:00:00
lang: en
description: To host our React app on Netlify start by signing up for a free account and adding your Git repository. We are also adding a catch all `_redirects` file in our project root.
ref: setting-up-your-project-on-netlify
comments_id: setting-up-your-project-on-netlify/190
---

Now we are going to host our React app on [Netlify](https://www.netlify.com). Before we can do that, we need to do one more thing. Recall that our React app is a single page app. Where the routes in the app are handled by our client side JavaScript code. We have a single `index.html` at the root of our app that handles all the routes. So we need to tell our hosting provider (in this case Netlify), to redirect any other requests back to this `index.html` file.

### Add a Redirects File

{%change%} Create a file called `_redirects` in the `public/` directory of your React app with the following.

```
/*    /index.html   200
```

This is basically saying that any requests should be sent to the `index.html` of our React app.

Note that this file doesn't have an extension. It is just called `_redirects`.

{%change%} Let's commit these changes and push to GitHub.

``` bash
$ git add .
$ git commit -m "Adding a redirects file"
$ git push
```

And we are now ready to host our app on Netlify!

### Create a Netlify Account

Start by [creating a free account](https://app.netlify.com/signup).

![Signup for Netlify screenshot](/assets/part2/signup-for-netlify.png)

Next, create a new site by hitting the **New site from Git** button.

![Hit new site from git button screenshot](/assets/part2/hit-new-site-from-git-button.png)

Pick **GitHub** as your provider.

![Select GitHub as provider screenshot](/assets/part2/select-github-as-provider.png)

Then pick your project from the list.

![Select GitHub repo from list screenshot](/assets/part2/select-github-repo-from-list.png)

The default settings are exactly what we want for our React app. Hit **Deploy site**.

![Hit Deploy site screenshot](/assets/part2/hit-deploy-site.png)

This should be deploying our app. Once it is done, click on the deployment.

![View deployed site screenshot](/assets/part2/view-deployed-site.png)

And you should see your app in action!

![Netlify deployed notes app screenshot](/assets/part2/netlify-deployed-notes-app.png)

Just like that, our app is live! You can share it with your friends and the rest of the world!

By default, a site hosted on Netlify uses their domains. But we want to host our notes app on our own domain. To do that, let's first purchase a domain name. We'll be using AWS to do so because we'll be using this same domain later for our Serverless API.
