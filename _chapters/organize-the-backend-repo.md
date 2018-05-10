---
layout: post
title: Organize the Backend Repo
date: 2018-02-25 00:00:00
comments_id: organize-the-backend-repo/160
---

Let's make a couple of quick changes to our project before we get started.

### Remove Unused Files

<img class="code-marker" src="/assets/s.png" />We have a couple of files as a part of the starter project that we can now remove.

``` bash
$ rm handler.js
$ rm tests/handler.test.js
```

### Update the serverless.yml

We are going to use a different service name.

<img class="code-marker" src="/assets/s.png" />Open the `serverless.yml` and find the following line:

``` yml
service: notes-app-api
```

<img class="code-marker" src="/assets/s.png" />And replace it with this:

``` yml
service: notes-app-2-api
```

The reason we are doing this is because Serverless Framework uses the `service` name to identify projects. Since we are creating a new project we want to ensure that we use a different name from the original. Now we could have simply overwritten the existing project but the resources were previously created by hand and will conflict when we try to create them through code.

<img class="code-marker" src="/assets/s.png" />Also, find this line in the `serverless.yml`:

``` yml
stage: prod
``` 

<img class="code-marker" src="/assets/s.png" />And replace it with:

``` yml
stage: dev
```

We are defaulting the stage to `dev` instead of `prod`. This will become clear later when we create multiple environments.

<img class="code-marker" src="/assets/s.png" />Let's quickly commit these changes.

``` bash
$ git add .
$ git commit -m "Organizing project"
```

Next let's look into configuring our entire notes app backend via our `serverless.yml`. This is commonly known as **Infrastructure as code**.
