---
layout: post
title: Initialize the backend repo
date: 2017-05-30 00:00:00
description:
comments_id:
---

To start with we are going to create our new project and add it to GitHub. We are going to be working off the code we've created so far. Don't worry if you haven't worked through the initial tutorial.

### Clone the original repo

In your working directory, start by cloning the [original repo]((% site.backend_github_repo %}).

``` bash
$ git clone --depth 1 https://github.com/AnomalyInnovations/serverless-stack-demo-api.git serverless-stack-ext-api/
$ cd serverles-stack-ext-api/
```

And remove the `.git/` dir.

``` bash
$ rm -rf .git/
```

### Create a new GitHub repo

Let's head over to [GitHub](https://github.com). Make sure you are signed in and hit **New repository**. Give your repository a name, in our case we are calling it `serverless-stack-ext-api`.

Next hit **Create repository**.

Once your repository is created, copy the repository URL. We'll need this soon.

### Initialize your new repo

Now head back to your project and use the following command to initialize your new repo.

``` bash
$ git init
```

Add the existing files.

``` bash
$ git add .
```

Create your first commit.

``` bash
$ git commit -m "First commit"
```

Link it to the repo you created on GitHub.

``` bash
$ git remote add origin remote REPO_URL
```

Here `REPO_URL` is the URL we copied from GitHub in the steps above. You can verify that it has been set correctly by doing the following.

``` bash
$ git remote -v
```

Finally, let's push our first commit to GitHub using:

``` bash
$ git push -u origin master
```

Next let's look into configuring our entire notes app backend via our `serverless.yml`. This is commonly known as **Infratrcture as code**.
