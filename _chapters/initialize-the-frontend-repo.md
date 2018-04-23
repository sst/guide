---
layout: post
title: Initialize the frontend repo
date: 2018-03-18 00:00:00
description:
comments_id:
---

Just as we did in the backend portion, we'll start by creating our project and adding it to GitHub. We will use what we had in part 1 as a starting point.

### Clone the original repo

In your working directory, start by cloning the [original repo]((% site.frontend_github_repo %}). Make sure this is not inside the directory for our backend.

``` bash
$ git clone --depth 1 https://github.com/AnomalyInnovations/serverless-stack-demo-client.git serverless-stack-2-client/
$ cd serverles-stack-2-client/
```

And remove the `.git/` dir.

``` bash
$ rm -rf .git/
```

Let's install our Node modules.

``` bash
$ npm install
```

### Create a new GitHub repo

Let's head over to [GitHub](https://github.com). Make sure you are signed in and hit **New repository**. Give your repository a name, in our case we are calling it `serverless-stack-ext-api`.

Next hit **Create repository**.

![Create new GitHub repository screenshot](/assets/part2/create-new-github-repository.png)

Give your repository a name, in our case we are calling it `serverless-stack-2-client`. Next hit **New repository**.

![Name new client GitHub repository screenshot](/assets/part2/name-new-client-github-repository.png)

Once your repository is created, copy the repository URL. We'll need this soon.

![Copy new client GitHub repo url screenshot](/assets/part2/copy-new-client-github-repo-url.png)

In our case the URL is `https://github.com/jayair/https://github.com/jayair/serverless-stack-2-client.git`.

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
$ git remote add origin REPO_URL
```

Here `REPO_URL` is the URL we copied from GitHub in the steps above. You can verify that it has been set correctly by doing the following.

``` bash
$ git remote -v
```

Finally, let's push our first commit to GitHub using:

``` bash
$ git push -u origin master
```

Next let's look into configuring our frontend client with the environments that we have in our backend.
