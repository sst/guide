---
layout: post
title: Organizing Serverless Projects
description: The Microservices + Mono-Repo pattern is the most common way to organize your Serverless Framework application. In this chapter we'll also examine the Multi-Repo and Monolith approach.
date: 2018-04-02 12:00:00
context: true
comments_id: organizing-serverless-projects/350
---

Once your serverless projects start to grow, you are faced with some choices on how to organize your growing projects. In this chapter we'll examine some of the most common ways to structure your projects at a services and application (multiple services) level.

First let's start by quickly looking at the common terms used when talking about Serverless Framework projects.

- **Service**

  A service is what you might call a Serverless project. It has a single `serverless.yml` file driving it.

- **Application**

  An application or app is a collection of multiple services.

Now let's look at the most common pattern for organizing serverless projects.

### Microservices + Mono-Repo

Mono-repo, as the term suggests is the idea of a single repository. This means that your entire application and all its services are in a single repository.

The microservice pattern on the other hand is a concept of keeping each of your services modular and lightweight. So for example; if your app allows users to create profiles and submit posts; you could have a service that deals with user profiles and one that deals with posts.

The directory structure of your entire application under the microservice + mono-repo pattern would look something like this.

```
|- services/
|--- posts/
|----- get.js
|----- list.js
|----- create.js
|----- update.js
|----- delete.js
|----- serverless.yml
|--- users/
|----- get.js
|----- list.js
|----- create.js
|----- update.js
|----- delete.js
|----- serverless.yml
|- lib/
|- package.json
```

A couple of things to notice here:

1. We are going over a Node.js project here but this pattern applies to other languages as well.
2. The `services/` dir at the root is made up of a collection of services. Where a service contains a single `serverless.yml` file.
3. Each service deals with a relatively small and self-contained function. So for example, the `posts` service deals with everything from creating to deleting posts. Of course, the degree to which you want to separate your application is entirely up to you.
4. The `package.json` (and the `node_modules/` dir) are at the root of the repo. However, it is fairly common to have a separate `package.json` inside each service directory. We go [in-depth into that pattern in this post here](https://seed.run/blog/how-to-structure-a-real-world-monorepo-serverless-app).
5. The `lib/` dir is just to illustrate that any common code that might be used across all services can be placed in here.
6. To deploy this application you are going to need to run `serverless deploy` separately in each of the services.
7. [Environments (or stages)]({% link _chapters/stages-in-serverless-framework.md %}) need to be co-ordinated across all the different services. So if your team is using a `dev`, `staging`, and `prod` environment, then you are going to need to define the specifics of this in each of the services.

#### Advantages of Mono-Repo

The microservice + mono-repo pattern has grown in popularity for a couple of reasons:

1. Lambda functions are a natural fit for a microservice based architecture. This is due to a few of reasons. Firstly, the performance of Lambda functions is related to the size of the function. Secondly, debugging a Lambda function that deals with a specific event is much easier. Finally, it is just easier to conceptually relate a Lambda function with a single event.

2. The easiest way to share code between services is by having them all together in a single repository. Even though your services end up dealing with separate portions of your app, they still might need to share some code between them. Say for example; you have some code that formats your requests and responses in your Lambda functions. This would ideally be used across the board and it would not make sense to replicate this code in all the services.

#### Disadvantages of Mono-Repo

Before we go through alternative patterns, let's quickly look at the drawbacks of the microservice + mono-repo pattern.

1. Microservices can grow out of control and each added service increases the complexity of your application.
2. This also means that you can end up with hundreds of Lambda functions.
3. Managing deployments for all these services and functions can get complicated.

Most of the issues described above start to appear when your application begins to grow. However, there are services that help you deal with some these issues. Services like [IOpipe](https://www.iopipe.com), [Epsagon](https://epsagon.com), and [Dashbird](https://dashbird.io) help you with observability of your Lambda functions. And our own [Seed](https://seed.run) helps you with managing deployments and environments of mono-repo Serverless Framework applications.

Now let's look at some alternative approaches.

### Multi-Repo

The obvious counterpart to the mono-repo pattern is the multi-repo approach. In this pattern each of your repositories has a single Serverless Framework project.

A couple of things to watch out for with the multi-repo pattern.

1. Code sharing across repos can be tricky since your application is spread across multiple repos. There are a couple of ways to deal with this. In the case of Node you can use private NPM modules. Or you can find ways to link the common shared library of code to each of the repos. In both of these cases your deployment process needs to accommodate for the shared code.

2. Due to the friction involved in code sharing, we typically see each service (or repo) grow in the number of Lambda functions. This can cause you to hit the CloudFormation resource limit and get a deployment error that looks like:

   ```
   Error --------------------------------------------------

   The CloudFormation template is invalid: Template format error: Number of resources, 201, is greater than maximum allowed, 200
   ```

Even with the disadvantages the multi-repo pattern does have its place. We have come across cases where some infrastructure related pieces (setting up DynamoDB, Cognito, etc) is done in a service that is placed in a separate repo. And since this typically doesn't need a lot of code or even share anything with the rest of your application, it can live on it's own. So in effect you can run a multi-repo setup where the standalone repos are for your _infrastructure_ and your _API endpoints_ live in a microservice + mono-repo setup.

Finally, it's worth looking at the less common monolith pattern.

### Monolith

The monolith pattern involves taking advantage of API Gateway's `{proxy+}` and `ANY` method to route all the requests to a single Lambda function. In this Lambda function you can potentially run an application server like [Express](https://expressjs.com). So as an example, all the API requests below would be handled by the same Lambda function.

```
GET https://api.example.com/posts
POST https://api.example.com/posts
PUT https://api.example.com/posts
DELETE https://api.example.com/posts

GET https://api.example.com/users
POST https://api.example.com/users
PUT https://api.example.com/users
DELETE https://api.example.com/users
```

And the specific section in your `serverless.yml` might look like the following:

``` yml
handler: app.main
events:
  - http: 
      method: any
      path: /{proxy+}
```

Where the `main` function in your `app.js` is responsible for parsing the routes and figuring out the HTTP methods to do the specific action necessary.

The biggest drawback here is that the size of your functions keeps growing. And this can affect the performance of your functions. It also makes it harder to debug your Lambda functions.

And that should roughly cover the main ways to organize your Serverless Framework applications. Hopefully, this chapter has given you a good overview of the various approaches involved along with their benefits and drawbacks.

In the next series of chapters we'll be looking at how to work with multiple services in your Serverless Framework application.
