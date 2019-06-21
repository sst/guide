---
layout: post
title: Initialize the Backend Repo
date: 2018-02-24 00:00:00
lang: en
description: By automating deployments for our Serverless Framework app, we can simply git push to deploy our app to production. To do so, start by adding your serverless app repo to Git.
ref: initialize-the-backend-repo
comments_id: initialize-the-backend-repo/159
---

To start with we are going to create our new project and add it to GitHub. We are going to be working off the code we've created so far.

### Clone the Code so Far

<img class="code-marker" src="/assets/s.png" />In your working directory, start by cloning the [original repo]({{ site.backend_github_repo }}).

``` bash
$ git clone --branch handle-api-gateway-cors-errors --depth 1 https://github.com/AnomalyInnovations/serverless-stack-demo-api.git serverless-stack-2-api/
$ cd serverless-stack-2-api/
```

<img class="code-marker" src="/assets/s.png" />And remove the `.git/` dir.

``` bash
$ rm -rf .git/
```

<img class="code-marker" src="/assets/s.png" />Let's install our Node modules as well.

``` bash
$ npm install
```

### Create a New Github Repo

Let's head over to [GitHub](https://github.com). Make sure you are signed in and hit **New repository**.

![Create new GitHub repository screenshot](/assets/part2/create-new-github-repository.png)

Give your repository a name, in our case we are calling it `serverless-stack-2-api`. Next hit **Create repository**.

![Name new GitHub repository screenshot](/assets/part2/name-new-github-repository.png)

Once your repository is created, copy the repository URL. We'll need this soon.

![Copy new GitHub repo url screenshot](/assets/part2/copy-new-github-repo-url.png)

In our case the URL is:

```
https://github.com/jayair/serverless-stack-2-api.git
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

Next, let's make a couple of quick changes to our project to get organized.
