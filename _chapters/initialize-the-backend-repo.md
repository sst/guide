---
layout: post
title: Initialize the Backend Repo
date: 2016-12-29 18:00:00
lang: en
description: For this guide we are going to add our Serverless Framework app to a Git repo. We do this so that we can automate our deployments later by just pushing to Git.
code: backend
ref: initialize-the-backend-repo
comments_id: initialize-the-backend-repo/159
---

Before we start working on our app, let's create a GitHub repository for this project. It's a good way to store our code and we'll use this repository later to automate deploying our app.

### Create a New Github Repo

Let's head over to [GitHub](https://github.com). Make sure you are signed in and hit **New repository**.

![Create new GitHub repository screenshot](/assets/part2/create-new-github-repository.png)

Give your repository a name, in our case we are calling it `serverless-stack-api`. Next hit **Create repository**.

![Name new GitHub repository screenshot](/assets/part2/name-new-github-repository.png)

Once your repository is created, copy the repository URL. We'll need this soon.

![Copy new GitHub repo url screenshot](/assets/part2/copy-new-github-repo-url.png)

In our case the URL is:

```
https://github.com/jayair/serverless-stack-api.git
```

### Initialize Your New Repo

<img class="code-marker" src="/assets/s.png" />Now head back to your project and use the following command to initialize your new repo.

``` bash
$ git init
```

<img class="code-marker" src="/assets/s.png" />Add the existing files.

``` bash
$ git add .
```

<img class="code-marker" src="/assets/s.png" />Create your first commit.

``` bash
$ git commit -m "First commit"
```

<img class="code-marker" src="/assets/s.png" />Link it to the repo you created on GitHub.

``` bash
$ git remote add origin REPO_URL
```

Here `REPO_URL` is the URL we copied from GitHub in the steps above. You can verify that it has been set correctly by doing the following.

``` bash
$ git remote -v
```

<img class="code-marker" src="/assets/s.png" />Finally, let's push our first commit to GitHub using:

``` bash
$ git push -u origin master
```

Now we are ready to build our backend!
