---
layout: post
title: Configure Multiple AWS Profiles
description: To use multiple IAM credentials to deploy your Serverless application you need to create a new AWS CLI profile. On local set the default AWS profile using the AWS_PROFILE bash variable. To deploy using your new profile use the "--aws-profile" option for the "serverless deploy" command. Alternatively, you can use the "profile:" setting in your serverless.yml.
date: 2018-04-07 00:00:00
comments_id: configure-multiple-aws-profiles/21
---

When we configured our AWS CLI in the [Configure the AWS CLI]({% link _chapters/configure-the-aws-cli.md %}) chapter, we used the `aws configure` command to set the IAM credentials of the AWS account we wanted to use to deploy our serverless application to.

These credentials are stored in `~/.aws/credentials` and are used by the Serverless Framework when we run `serverless deploy`. Behind the scenes Serverless uses these credentials and the AWS SDK to create the necessary resources on your behalf to the AWS account specified in the credentials.

There are cases where you might have multiple credentials configured in your AWS CLI. This usually happens if you are working on multiple projects or if you want to separate the different stages of the same project.

In this chapter let's take a look at how you can work with multiple AWS credentials.

### Create a New AWS Profile

Let's say you want to create a new AWS profile to work with. Follow the steps outlined in the [Create an IAM User]({% link _chapters/create-an-iam-user.md %}) chapter to create an IAM user in another AWS account and take a note of the **Access key ID** and **Secret access key**.

To configure the new profile in your AWS CLI use:

``` bash
$ aws configure --profile newAccount
```

Where `newAccount` is the name of the new profile you are creating. You can leave the **Default region name** and **Default output format** the way they are.


### Set a Profile on Local

We mentioned how the Serverless Framework uses your AWS profile to deploy your resources on your behalf. But while developing on your local using the `serverless invoke local` command things are a little different.

In this case your Lambda function is run locally and has not been deployed yet. So any calls made in your Lambda function to any other AWS resources on your account will use the default AWS profile that you have. You can check your default AWS profile in `~/.aws/credentials` under the `[default]` tag.

To switch the default AWS profile to a new profile for the `serverless invoke local` command, you can run the following:

``` bash
$ AWS_PROFILE=newAccount serverless invoke local --function hello
```

Here `newAccount` is the name of the profile you want to switch to and `hello` is the name of the function that is being invoked locally. By adding `AWS_PROFILE=newAccount` at the beginning of our `serverless invoke local` command we are setting the variable that the AWS SDK will use to figure out what your default AWS profile is.

If you want to set this so that you don't add it to each of your commands, you can use the following command:

``` bash
$ export AWS_PROFILE=newAccount
```

Where `newAccount` is the profile you want to switch to. Now for the rest of your shell session, `newAccount` will be your default profile.

You can read more about this in the AWS Docs [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html).


### Set a Profile While Deploying

Now if we want to deploy using this newly created profile we can use the `--aws-profile` option for the `serverless deploy` command.

``` bash
$ serverless deploy --aws-profile newAccount
```

Again, `newAccount` is the AWS profile Serverless Framework will be using to deploy.

If you don't want to set the profile every time you run `serverless deploy`, you can add it to your `serverless.yml`.

``` yml
service: service-name

provider:
  name: aws
  stage: dev
  profile: newAccount
```

Note the `profile: newAccount` line here. This is telling Serverless to use the `newAccount` profile while running `serverless deploy`.


### Set Profiles per Stage

There are cases where you would like to specify a different AWS profile per stage. A common scenario for this is when you have a completely separate staging environment than your production one. Each environment has its own API endpoint, database tables, and more importantly, the IAM policies to secure the environment. A simple yet effective way to achieve this is to keep the environments in separate AWS accounts. [AWS Organizations](https://aws.amazon.com/organizations/) was in fact introduced to help teams to create and manage these accounts and consolidate the usage charges into a single bill.

Let's look at a quick example of how to work with multiple profiles per stage. So following the examples from before, if you wanted to deploy to your production environment, you would:

``` bash
$ serverless deploy --stage prod --aws-profile prodAccount
```

And to deploy to the staging environment you would:

``` bash
$ serverless deploy --stage dev --aws-profile devAccount
```

Here, `prodAccount` and `devAccount` are the AWS profiles for the production and staging environment respectively.

To simplify this process you can add the profiles to your `serverless.yml`. So you don't have to specify them in your `serverless deploy` commands.

``` yml
service: service-name

custom:
  myStage: ${opt:stage, self:provider.stage}
  myProfile:
    prod: prodAccount
    dev: devAccount

provider:
  name: aws
  stage: dev
  profile: ${self:custom.myProfile.${self:custom.myStage}}
```

There are a couple of things happening here.

- We first defined `custom.myStage` as `${opt:stage, self:provider.stage}`. This is telling Serverless Framework to use the value from the `--stage` CLI option if it exists. If not, use the default stage specified in `provider.stage`.
- We also defined `custom.myProfile`, which contains the AWS profiles we want to use to deploy for each stage. Just as before we want to use the `prodAccount` profile if we are deploying to stage `prod` and the `devAccount` profile if we are deploying to stage `dev`.
- Finally, we set the `provider.profile` to `${self:custom.myProfile.${self:custom.myStage}}`. This picks the value of our profile depending on the current stage defined in `custom.myStage`.

We used the concept of variables in Serverless Framework in this example. You can read more about this in the chapter on [Serverless Environment Variables]({% link _chapters/serverless-environment-variables.md %}).

Now, when you deploy to production, Serverless Framework is going to use the `prodAccount` profile. And the resources will be provisioned inside `prodAccount` profile user's AWS account.

``` bash
$ serverless deploy --stage prod
```

And when you deploy to staging, the exact same set of AWS resources will be provisioned inside `devAccount` profile user's AWS account.

``` bash
$ serverless deploy --stage dev
```

Notice that we did not have to set the `--aws-profile` option. And that's it, this should give you a good understanding of how to work with multiple AWS profiles and credentials.
