---
layout: post
title: Setting up Your Project on Netlify
date: 2018-03-27 00:00:00
lang: en
description: To automate deployments for our Create React App on Netlify start by signing up for a free account and adding your Git repository.
ref: setting-up-your-project-on-netlify
comments_id: setting-up-your-project-on-netlify/190
---

Now we are going to set our React app on [Netlify](https://www.netlify.com). Start by [creating a free account](https://app.netlify.com/signup).

![Signup for Netlify screenshot](/assets/part2/signup-for-netlify.png)

Next, create a new site by hitting the **New site from Git** button.

![Hit new site from git button screenshot](/assets/part2/hit-new-site-from-git-button.png)

Pick **GitHub** as your provider.

![Select GitHub as provider screenshot](/assets/part2/select-github-as-provider.png)

Then pick your project from the list.

![Select GitHub repo from list screenshot](/assets/part2/select-github-repo-from-list.png)

It'll default the branch to `master`. We can now deploy our app! Hit **Deploy site**.

![Hit Deploy site screenshot](/assets/part2/hit-deploy-site.png)

This should be deploying our app. Once it is done, click on the deployment.

![View deployed site screenshot](/assets/part2/view-deployed-site.png)

And you should see your app in action!

![Netlify deployed notes app screenshot](/assets/part2/netlify-deployed-notes-app.png)

Of course, it is hosted on a Netlify URL. We'll change that by configuring custom domains next.
