---
layout: post
title: Initialize a GitHub Repo
date: 2021-08-17 18:00:00
lang: en
description: For this guide we are going to add our SST app to a Git repo. We do this so that we can automate our deployments later by just pushing to GitHub.
ref: initialize-a-github-repo
redirect_from:
  - /chapters/initialize-the-backend-repo.html
  - /chapters/initialize-the-frontend-repo.html
comments_id: initialize-a-github-repo/2466
---

Before we start working on our app, let's create a GitHub repository for this project. It's a good way to store our code and we'll use this repository later to automate deploying our app.

### Create a New Github Repo

Let's head over to [GitHub](https://github.com). Make sure you are signed in and hit **New repository**.

![Create new GitHub repository screenshot](/assets/part2/create-new-github-repository.png)

Give your repository a name, in our case we are calling it `demo-notes-app`. Next hit **Create repository**.

![Name new GitHub repository screenshot](/assets/part2/name-new-github-repository.png)

Once your repository is created, copy the repository URL. We'll need this soon.

![Copy new GitHub repo url screenshot](/assets/part2/copy-new-github-repo-url.png)

In our case the URL is:

``` txt
https://github.com/serverless-stack/demo-notes-app.git
```

### Initialize Your New Repo

{%change%} Now head back to your project and use the following command to initialize your new repo.

``` bash
$ git init
```

{%change%} Add the existing files.

``` bash
$ git add .
```

{%change%} Create your first commit.

``` bash
$ git commit -m "First commit"
```

{%change%} Link it to the repo you created on GitHub.

``` bash
$ git branch -M main
$ git remote add origin REPO_URL
```

Here `REPO_URL` is the URL we copied from GitHub in the steps above. You can verify that it has been set correctly by doing the following.

``` bash
$ git remote -v
```

{%change%} Finally, let's push our first commit to GitHub using:

``` bash
$ git push -u origin main
```

Now we are ready to build our backend!
