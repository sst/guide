---
layout: blog
title: Leadent Digital is transforming field service operations with SST
description: In this post we are talking to Ross Coundon, CTO of Leadent Digital about how they are using SST to transform field service operations.
author: jay
image: assets/social-cards/case-study-leadent.png
---

In this post we are talking to Ross Coundon, CTO of [Leadent Digital](https://leadent.digital) about how they are using [SST](/) and [Seed](https://seed.run) to transform field service operations.

### About Leadent Digital

[Leadent Digital](https://leadent.digital) provides the full spectrum of services from consulting advice to software development for field service operations. Their flagship product, the On My Way app provides real-time updates to customers on appointment visits, including expected time of arrival, appointment details and much more. Leadent's customers include Foxtel and Bosch Thermotechnology, and many others through a partnership with IFS.

Ross Coundon, is the CTO at Leadent Digital and leads their software development
efforts. Ross has been building software for over 20 years, and after years of building
on-premise software was looking for a way to focus on solving business problems and not have to manage any servers.

## The Challenge

In their quest for reducing the operational overhead of building large applications, Ross
and his team experimented with AWS Elastic Beanstalk and Docker briefly before realizing that Lambda allowed them to build their MVPs far more easily and in a more cost effective
way.

Some of the very early serverless applications at Leadent were built using Claudia.js
and it was fine for a handful of Lambda functions. But it was hard to test in a real-world context.

This led them to Serverless Framework and serverless-offline. But there was _"no
confidence in going from an emulated offline environment to production"_, says Ross. It
wasn't testing the permissions or any of the connections within the app. _"You had to punt it over to AWS to find what was broken"_.

He also didn't think YAML was the right way to define infrastructure. He was looking for
type support and looked at using `serverless.ts` with Serverless Framework. But felt the
documentation was lacking, and for anything that was not directly supported by Serverless
Framework, he needed to rely on a combination of guesswork and the AWS docs to piece the two together.

This painful process of developing and testing led them to look at SST.

## Enter SST


The constructs in SST made a lot of sense to Ross and his team. It allowed them to define all the infrastructure in one place and not have to use any YAML configuration. Better still, with full type support and IDE intellisense.

They were also impressed with the Live Lambda Development environment. _"Knowing
that when I run an SST application I'm using real AWS infrastructure and my computer
is a part of the pipe was incredible"_, says Ross.

SST allowed them to set breakpoints in their code and debug in real-time, which meant that _"you can iterate faster and build so much faster"_, says Ross.

> "You can iterate faster and build so much faster."

The entire SST local development process was a revelation for the team. _"I hadn't found anything like SST and haven't seen anything like it since"_, says Ross.

> "I hadn't found anything like SST and haven't seen anything like it since."

They also use [Seed](https://seed.run) to deploy their SST apps. All their major customers have separate deployments of their application. These are also deployed to separate AWS accounts. They use a PR based workflow in Seed and once their changes are merged to master, it gets deployed to all their customer accounts.

They just recently completed migrating their flagship product completely to SST. And
next week one of their larger customers will be using the new version of their
application.

## The Future

The next 6 to 12 months is an exciting time for Ross and Leadent. They are looking to grow the team. They are also looking to expand the capabilities of their flagship product by adding live chat, so customers will be able to interact with the field service reps in real-time and they’ll be relying on SST for building this out.

## Learn More

Learn more about [Leadent Digital and their work here](https://leadent.digital).

---

[Read more about Serverless Stack](/) and [get started]({{ site.docs_url }}{{ site.docs_get_started }}) today.
