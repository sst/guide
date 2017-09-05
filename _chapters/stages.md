---
layout: post
---

### What is staging environment?

A staging environment is an independent clone of your live production environment that can be easily created to test new code before release it to production. After you confirm the staging environment is good to go, you can deploy the code further to the live environment.

In the context of our serverless backend, staging environment could be a completely standalone replica of Api Gateway, Lambda, DynamoDB tables, S3 buckets, and even Cognito user pool. In this chapter, we are going to focus on creating the staging environemnt for Api Gateway and Lambda through Serverless Framework.


### How is staging implemented?


- having the capability of staging environment being in another AWS account


most companies don't want their production applications installed in the same account as their development applications as it makes restricting access to production (i.e. who can edit/delete production) much harder than it needs to be.



### Why not use API Gateway's default stages?


### Setup stage variables in Serverless.yml


