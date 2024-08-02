---
layout: post
title: Setting up the SST Console
date: 2024-07-24 00:00:00
lang: en
redirect_from: /chapters/setting-up-your-project-on-seed.html
description: In this chapter we'll set up the SST Console so we can manage, monitor, and autodeploy our apps.
ref: setting-up-the-sst-console
comments_id: setting-up-the-sst-console/2957
---

We are going to set up the [SST Console]({{ site.ion_url }}/docs/console/){:target="_blank"} to auto-deploy our app and manage our environments.

Start by [**signing up for a free account here**]({{ site.console_url }}){:target="_blank"}.

![Create new SST Console account](/assets/part2/create-new-sst-console-account.png)

Let's **create your workspace**.

![Create SST Console workspace](/assets/part2/create-sst-console-workspace.png)

Next, **connect your AWS account**.

![Connect AWS account in SST Console](/assets/part2/connect-aws-account-in-sst-console.png)

This will send you to the AWS Console and ask you to create a CloudFormation stack.

![AWS create CloudFormation stack](/assets/part2/aws-create-cloudformation-stack.png)

This stack needs to be in **us-east-1**. So make sure you use the dropdown at the top right to check that you are in the right region.

![AWS Console check region](/assets/part2/aws-console-check-region.png)

Scroll down, **confirm** the checkbox at the bottom and click **Create stack**.

![AWS click create CloudFormation stack](/assets/part2/aws-click-create-cloudformation-stack.png)

It will take a couple of minutes to create the stack.

![AWS CloudFormation stack create complete](/assets/part2/aws-cloudformation-stack-create-complete.png)

Once complete, head back to the SST Console. It'll take a minute to scan your AWS account for your SST apps.

While it's doing that, let's link our GitHub. Click on **Manage workspace**, scroll down to the **Integrations**, and enable **GitHub**.

![Enable GitHub integration in SST Console](/assets/part2/enable-github-integration-in-sst-console.png)

You'll be asked to select where you want to install the SST Console integration. You can either pick your personal account or any organizations you are a part of. This is where your notes app repo has been created.

Once you select where you want to install it, scroll down and click **Install**.

![Install SST Console in GitHub](/assets/part2/install-sst-console-in-github.png)

Now your GitHub integration should be enabled. And hopefully the Console should be done scanning your AWS account. You should see your notes app with your personal stage.

![Notes app in SST Console](/assets/part2/notes-app-in-sst-console.png)

Here you can see the resources in your stage, the logs from your functions, and any issues that have been detected. For now, let's head over to the **Settings** > **Autodeploy** > pick your repo > and click **Select**.

![Select GitHub repo SST Console](/assets/part2/select-github-repo-sst-console.png)

Let's create a couple of environments. This tells the SST Console when to auto-deploy your app.

![GitHub repo selected SST Console](/assets/part2/github-repo-selected-sst-console.png)

We are going to create two environments. Starting with a **Branch environment**. Use **production** as the name, select your AWS account, and click **Add Environment**.

![Create branch environment SST Console](/assets/part2/create-branch-environment-sst-console.png)

Do the same for a **PR environment**.

![Create PR environment SST Console](/assets/part2/create-pr-environment-sst-console.png)

The two above environments tell the Console that any stage with the name `production` or starting with `pr-` should be auto-deployed to the given AWS account. By default, the stage names are derived from the name of the branch.

So if you _git push_ to a branch called `production`, the SST Console will auto-deploy that to a stage called `production`.

Let's do that next.
