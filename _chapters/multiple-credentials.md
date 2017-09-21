---
layout: post
---

### Why using multiple credentials?

[ TODO: why keep prod & dev separate ]
Often times, people want to keep their production and development environment as standalone as possible. Each environment having its own API endpoint, database tables, and most importantly the IAM policies securing the environment. The simplest yet effective way to achieve this is to keep the environments in separate AWS accounts. AWS Organizations was in fact introduced to help teams to create and manage these accounts and consolidate the usage charges into a single bill.


### How to specify multiple credentials?

Follow [chapters create-an-iam-user.html] to create an IAM user in another AWS account and take a note of the **Access key ID** and **Secret access key**.

Run

```
$ aws configure --profile devAccount
```

You can leave the **Default region name** and **Default output format** the way they are.

Add the profiles to Serverless.yml

```
service: service-name

custom:
  myStage: ${opt:stage, self:provider.stage}
  myProfile:
    prod: default
    dev: devAccount

provider:
  name: aws
  stage: dev
  profile: ${self:custom.myProfile.${self.custom.myStage}}
```

There are a couple of things happening here. We first defined `custom.myStage`. What this says is to use the `stage` CLI option if it exists, if not, use the default stage specified at `provider.stage`. We also defined `custom.myProfile`, which contains the AWS profiles we want to use to deploy for each stage. At last, we asks the `provdier.profile` to pick the corresponding value depending on the current stage defined in `custom.myStage`.


Now, when you deploy to production, Serverless Framework is going to use the `default` profile. And the resources will be provisioned inside `default` profile user's AWS account.

```
$ serverless deploy --stage prod
```

And when you deploy to development, the exact same set of AWS resources will be provisioned inside `devAccount` profile user's AWS account.

```
$ serverless deploy --stage dev
```
