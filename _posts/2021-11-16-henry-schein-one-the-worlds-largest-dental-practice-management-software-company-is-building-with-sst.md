---
layout: blog
title: Henry Schein One, the world's largest dental practice management software company is building with SST
description: In this post we are talking to Jack Fraser, a Software Engineering Manager at Henry Schein One; the world's largest dental practice management software company. They are using SST to power the patient booking experience and the management software used by thousands of dental practices globally.
author: jay
image: assets/social-cards/case-study-henry-schein-one.png
---

In this post we are talking to Jack Fraser, a Software Engineering Manager at [Henry Schein One](https://henryscheinone.com). They are using [SST](/) and [Seed](https://seed.run) to power the patient booking experience and the management software used by thousands of dental practices globally.

## About Henry Schein One

[Henry Schein One](https://henryscheinone.com) is the world’s largest dental practice management software company. Founded in 2018, Henry Schein One launched a new era of integrated dental technology by merging the market-leading practice management, patient communication and marketing systems of Henry Schein and Internet Brands into one company.

Henry Schein, Inc. (Nasdaq: HSIC), Henry Schein One's parent company, is the largest wholesaler of dental and medical products to office-based practitioners. The company has been established for approximately 90 years, with a presence in 32 countries to offer hundreds of thousands of products to customers globally. The company is a Fortune World's Most Admired Company and is ranked number one in its industry for social responsibility by Fortune magazine.

Jack Fraser is a Software Engineering Manager at Henry Schein One. His team is building out applications that'll power the patient booking experience and the management software for thousands of dental practices globally.

## The Challenge

As more dental practices around the world start to rely on digital services to manage their practices and patient booking; the challenge is then to _"build applications that are snappy and easy to use for patients"_, says Jack Fraser. Each practice brings in roughly 3000 patients and so they need to be able to scale rapidly as these will be rolled out globally.

They felt AWS made sense and serverless would help them with their scaling needs. So a year ago, Jack's team built out a serverless application in Serverless Framework. It had around 14 separate services.

However the experience wasn't great. The local development workflow was painful and using YAML to define the infrastructure didn't make as much sense.

In addition, their frontend applications were deployed as static sites to AWS through the AWS CLI. As Serverless Framework didn't have great support for this.

## Switching to SST

This is around when they found SST and it made perfect sense for them. _"It was based on CDK, and while CDK is great it is really verbose"_, says Jack.

> "CDK is great but it is really verbose"

The other aspect that they found really appealing was the Live Lambda Development environment. _"We loved the Live Lambda debugging in SST"_.

> "We loved the Live Lambda debugging in SST"

Now they have 15 stacks in their SST app. With over 200 endpoints in their API. It also includes 4 Angular apps that use SST's [StaticSite construct]({{ site.docs_url }}/constructs/StaticSite).

They also decided to move to GraphQL to manage their APIs. _"We are already using SST's [ApolloApi construct]({{ site.docs_url }}/constructs/ApolloApi)"_, says Phil Astle, a Senior Software Engineer on the team.

It's also all deployed through [Seed](https://seed.run). _"We want to have a consistent release process"_, says Jack. Each developer on the team has 2 stages, a local one and a deployed one. There's also a sandbox environment and a production environment.

The PR workflow in Seed allows them to do code reviews and usability testing. It also allows them to spin up new environments to show changes to customers and get direct feedback.

Thanks to what SST and Seed offers, they decided to _"make a big bet on SST"_, says Jack. And they've gone all in on SST.

> "We have gone all-in on SST"

## Looking Ahead

Jack's team is going to be creating multiple prod environments, one for a section of the practices for early rollouts and the second for the rest of their customers. They also need to setup multi-region deployments as they'll be entering new markets soon.

They are looking to double the team over the next couple of months. So Jack thinks that they need a dev environment thats _"easy and intuitive"_. And a deployment workflow that just works. _"We are a talent dense team, so it's important to have great tooling to be as productive as possible"_, says Jack.

## Learn More

Learn about the [job opportunities at Henry Schein One](https://dentr.co.uk/jobs) and join the world's largest dental practice management software company.

---

[Read more about Serverless Stack](/) and [get started]({{ site.docs_url }}{{ site.docs_get_started }}) today.
