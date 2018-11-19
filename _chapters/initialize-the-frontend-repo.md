---
layout: post
title: Initialize the Frontend Repo
date: 2018-03-18 00:00:00
description: By automating deployments for our React app, we can simply git push to deploy our app to production. To do so, start by adding your React app repo to Git.
comments_id: initialize-the-frontend-repo/181
---

Just as we did in the backend portion, we'll start by creating our project and adding it to GitHub. We will use what we had in Part I as a starting point.

### Clone the Original Repo

<img class="code-marker" src="/assets/s.png" />In your working directory, start by cloning the [original repo]({{ site.frontend_github_repo }}). Make sure this is not inside the directory for our backend.

``` bash
$ git clone --branch part-1 --depth 1 https://github.com/AnomalyInnovations/serverless-stack-demo-client.git serverless-stack-2-client/
$ cd serverless-stack-2-client/
```

<img class="code-marker" src="/assets/s.png" />And remove the `.git/` dir.

``` bash
$ rm -rf .git/
```

<img class="code-marker" src="/assets/s.png" />Let's install our Node modules.

``` bash
$ npm install
```

### Create a New GitHub Repo

Let's head over to [GitHub](https://github.com). Make sure you are signed in and hit **New repository**.

![Create new GitHub repository screenshot](/assets/part2/create-new-github-repository.png)

Give your repository a name, in our case we are calling it `serverless-stack-2-client`. And hit **Create repository**.

![Name new client GitHub repository screenshot](/assets/part2/name-new-client-github-repository.png)

Once your repository is created, copy the repository URL. We'll need this soon.

![Copy new client GitHub repo url screenshot](/assets/part2/copy-new-client-github-repo-url.png)

In our case the URL is:

```
https://github.com/jayair/https://github.com/jayair/serverless-stack-2-client.git
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

Next let's look into configuring our frontend client with the environments that we have in our backend.
