---
layout: post
title: What is AWS AppSync
date: 2021-07-01 00:00:00
lang: en
description: AWS AppSync is a fully managed GraphQL service that can be used to build serverless backends. It can connect to data sources like DynamoDB, Lambda, RDS, etc. It also provides full support for subscriptions.
ref: what-is-aws-appsync
comments_id: 
---

[AWS AppSync](https://aws.amazon.com/appsync/) is a managed API service that you can use in your serverless backends. If you’re already familiar with API Gateway, you may be wondering why you would need to learn yet another service. It all comes down to the protocol that you want to use: REST or GraphQL. 

### GraphQL Introduction

GraphQL was [created by Facebook in 2012](https://engineering.fb.com/2015/09/14/core-data/graphql-a-data-query-language/) to reduce the amount of network traffic required by their mobile app's news feed. Facebook released GraphQL as an open-source project a few years later, and it has been slowly catching on. In 2016, GitHub converted their [public API to GraphQL](https://github.blog/2016-09-14-the-github-graphql-api/).

#### What Is GraphQL?

GraphQL, or graph query language, is an API protocol built on top of Representational State Transfer (REST). It enables you to specify what data will be in the response by filtering records or specifying which properties you need.

According to [Smartbear's State of the API report in 2020](https://nordicapis.com/breaking-down-smartbears-2020-state-of-api-report/) only about 19% of responding organizations use GraphQL. The majority (at least 82%) of organizations use some form of REST.

#### When Is It a Good Choice?

GraphQL shines anytime you want to limit the number of requests sent to the server and the size of the responses coming back. It allows you to stitch together data from multiple sources on the backend. It can also handle nested data, so you don't have to send a request to get a list of IDs then send another request to get data associated with each ID. Finally, GraphQL allows you to specify the properties that you want in your response. This helps you avoid overfetching, which is wasting bandwidth downloading something that you don't actually want or need.

### GraphQL on AWS Lambda

If you decide to use GraphQL in a serverless application, how do you run the server? In AWS the serverless compute service is AWS Lambda. While they do have some limitations, it's not that difficult to run a GraphQL server on a Lambda.

#### Options for running GraphQL on Lambda

There are two main GraphQL server libraries that can run in an AWS Lambda. Apollo Server provides a support package to get it running in a lambda. The other option is an Express middleware—Express GraphQL—that enables you to run GraphQL along with REST endpoints.

#### What are each of the options good for?

Apollo Server is [the more popular of the two options](https://www.npmtrends.com/express-graphql-vs-apollo-server) and should be your go-to option most of the time. If you already have a REST API running on a Lambda, however, and want to convert it to GraphQL then the simplicity of adding a middleware plugin to your server is a huge win. Just add `express-graphql` to your project and you can slowly replace your REST paths with GraphQL queries and mutators.

Speaking of middleware plugins, that's another reason to stick with Express: it has a *lot* of plugins. If Apollo Server doesn't already support the authentication that you want to use, chances are that someone has written an express middleware for it.

### AppSync Introduction

Lambdas are great for a lot of things, but running a GraphQL server on one can get tricky. Especially when you want to start using features like subscriptions. AppSync is AWS's solution to that problem.

#### When Is It a Good Choice?

AWS AppSync is a managed GraphQL API service that, in true serverless form, allows you to create an API without worrying about how to host it. It provides full support for subscriptions and a couple of features to simplify getting data from other AWS services.

#### How Does It Work?

AppSync APIs have [three components that you need to define](https://docs.aws.amazon.com/appsync/latest/devguide/designing-a-graphql-api.html): a schema, resolvers, and data sources. Combining these three items allows your API to interact with resources and translate responses into the desired format.

![Imgur](https://i.imgur.com/4zs2Oyq.png)

When a request first comes in, AppSync verifies it using the schema. The authorization of the request is verified against some optional type decorators and the requested properties are checked to make sure they're valid.

Once AppSync has determined what object type is being requested, and that the user is allowed to request it, it finds the resolver associated with that type. The resolver defines request and response templates that use simple logic to translate the data between GraphQL and a data source.

After the GraphQL query has been translated by a resolver, it's sent to a data source. The data source defines a database connection, lambda ARN, or some other destination that the request is sent to. Once the resource runs whatever action was requested, it returns the result to a response template which translates it back into a format compliant with your schema.

There are [currently six types of data sources](https://docs.amazonaws.cn/en_us/AWSCloudFormation/latest/UserGuide/aws-resource-appsync-datasource.html#cfn-appsync-datasource-type) supported by AppSync: 

* DynamoDB 
* ElasticSearch
* Lambda
* None 
* Http 
* RDS 

If you need to use data from an AWS service that isn't in the list, you can use a Http data source.

### Drawbacks and Limitations

The biggest drawback to AppSync is the development experience. Resolver template development is notoriously difficult due to its use of Apache VTL.

### AppSync’s Pricing

There are a few different things that you get charged for when using AppSync: 
* queries/mutations
* subscription updates
* minutes that a client is listening to a subscription
* data transferred out
* optionally caching

The following table details the current prices charged for running an AppSync API. For the most up to date pricing, see the [AWS AppSync pricing page](https://aws.amazon.com/appsync/pricing/).

| Description                                           | Price |
| ------------------------------------------- | ----: |
| 1 Million Queries/Mutations                 | $4.00 |
| 1 Million 5 kb Updates                       | $2.00 |
| 1 Million Minutes Connected to Subscription | $0.08 |
| 1 Gb Transferred to the Internet            | $0.09 |

#### Cache Pricing

You can optionally enable caching for your AppSync API. You select an instance type from a handful of options. Each instance type has an hourly rate associated with it that currently ranges from $0.044 to $6.775. See the [AWS AppSync pricing page](https://aws.amazon.com/appsync/pricing/) for the most up to date prices.
