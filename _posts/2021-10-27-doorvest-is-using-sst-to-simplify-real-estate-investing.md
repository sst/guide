---
layout: blog
title: Doorvest is using SST to simplify real estate investing
description: In this post we are talking to Orlando Hui from Doorvest about how they are using SST and Seed to simplify real estate investing.
author: jay
image: assets/social-cards/case-study-doorvest.png
---

In this post we are talking to Orlando Hui from [Doorvest](https://doorvest.com) about how they are using [SST](/) and [Seed](https://seed.run) to simplify real estate investing.


### About Doorvest

[Doorvest](https://doorvest.com) creates a modern way for people to own high-yield rental homes completely online. Doorvest gets to know a customer and their investment goals before identifying and buying a home on their behalf. It handles renovations and places a resident in it, then sells the home to the customer.

Doorvest is a VC backed company with 30 plus employees. Orlando Hui is the lead engineer on the team and was responsible for implementing SST across their stack.

### The Challenge

While the original version of the Doorvest client was built using Serverless Framework, the dev workflow was really painful. _"Deployments took 7 minutes"_, says Orlando. For most cases they had to deploy to test their changes. So the commit, deploy, feedback loop was something that they couldn't continue to use.

The original application also connected to resources that were not created in YAML and were created through the AWS Console. This was partly because it seemed easier to create them through the console, as opposed to working with the CloudFormation YAML that Serverless Framework uses.

### Using SST

The Doorvest team had been following [SST](/) since it's Hacker News launch back in February, 2021. But they were unable to find an excuse to use it internally. Then a couple of months ago they needed to build an application for the general contractors on Doorvest. This allowed them to try out SST in production.

The team built everything from scratch, used the [constructs in SST]({{ site.docs_url }}/packages/resources) and CDK to define all their infrastructure as code. They also followed the best practices of separating their environments by AWS accounts. So each developer has their own AWS account, the staging and production environments are also in separate accounts. Their SST apps are deployed through [Seed](https://seed.run), and the combination of the two worked perfectly for them.

_"SST doesn't have anything that's missing for us. We have everything we need."_, says Orlando. _"We don't have to do YAML anymore. The Live Lambda Dev is incredible."_

> "The Live Lambda Dev is incredible."

Comparing their workflow from before, Orlando thinks, _"it's improved our productivity by at least 3 times"_.

> "It's improved our productivity by at least 3 times."
> 

He also found the [SST Slack community]({{ site.slack_invite_url }}) while working on it. _"The Slack group has been super incredible"_, says Orlando.

> "The Slack group has been super incredible."

Recently, he was looking for WebSocket authorizer support and _"it got built almost instantly after I brought it up"_.

### Looking Ahead

_"Now everybody on the team just wants to migrate away from Serverless Framework"_, says Orlando. As a part of their current sprint they are figuring out how to move over to SST completely.

The Doorvest engineering team is looking to grow 4x in 2022 and are actively seeking new engineers. They added 3 new folks recently and _"having everybody use SST has been great, especially the new engineers"_.

### Learn More

Learn more about the [job opportunities at Doorvest](https://www.builtinsf.com/company/doorvest) and help them in their cause to simplify real eastate investing.

---

[Read more about Serverless Stack](/) and [get started]({{ site.docs_url }}{{ site.docs_get_started }}) today.
