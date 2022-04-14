---
layout: blog
title: Buildforce is creating the first ever career platform for the construction trade with SST
description: We are talking to Michael Orcutt, the founder of Buildforce about their experience building with SST and Seed.
author: jay
image: assets/social-cards/case-study-buildforce.png
---

We are talking to Michael Orcutt, a co-founder of [Buildforce](https://buildforce.com) about their experience building with [SST](/) and [Seed](https://seed.run).

### About Buildforce

[Buildforce](https://buildforce.com) is building the first ever career platform for people in the construction trades, starting with those in the electrical trade. Its end-to-end platform enables people in the construction trades to maintain consistent work at fair pay and with employee benefits with our construction partners, an arrangement that is out of reach for many in the construction industry today.

Since their launch in 2020, Buildforce has become the go-to partner helping dozens of the largest contractors across its focus geographies connect with this workforce.

Buildforce currently operates in the state of Texas, has raised $5.5M to date, and is growing 10% week over week in 2021. Michael Orcutt is one of the founders of the company and is leading the  engineering efforts. He is also highly involved in product and design as they build their web apps, mobile apps, and marketing site.

### The Challenge

The Buildforce team knew they wanted to build their applications using serverless due to the inherent benefits. They originally started out with Serverless Framework. But over time Serverless Framework became a headache. Everything from the deployment process to testing was cumbersome. _"We felt we were slow, velocity was down as the speed of development wasn't great"_, says Michael. _"We also found creating infrastructure in YAML challenging"_. They realized this just wouldn't work as they scaled the team.

### Enter SST

Around 2 months ago the team came together and decided they needed to make a change. They had heard about [SST](/) and the [Serverless Stack Guide]({% link guide.md %}). They decided they needed to take a deeper look.

As they tried out SST, _"We were blown away by the local development environment"_, says Michael. The entire team decided to move to SST.

> "We were blown away by the local development environment."

They decided to start a new SST app from scratch. They spent some time testing SST and within a month they had moved over completely. The new setup Michael says is _"Such a great experience. We are at least 1.5 to 2 times faster than before"_.

> "We are at least 1.5 to 2 times faster than before."

They also use [Seed](https://seed.run) for their deployment workflow. They typically branch from main, work locally, push to a feature branch. The feature branches get deployed through [Seed](https://seed.run) and connects to dev resources. Finally they rebase with master and that deploys to production. The dev and prod environments are on separate AWS accounts.

### Looking Ahead

Michael says they really need to grow the team. As more and more electricians are onboarded, they need to make sure every construction worker has a great experience and our operations team has the right tools to manage our workforce.

From an architecture perspective, their single web application will most likely be split into multiple SST apps; one for their electricians, one for the contractors, and one for the ops team. They will also be introducing ElasticSearch for better search functionality.

Thanks to SST their entire development setup works seamlessly, allowing them to focus on the needs of a fast growing business.

### Learn More

[Learn more about the job opportunities at Buildforce](https://joinbuildforce.recruitee.com).

---

[Read more about Serverless Stack](/) and [get started]({{ site.docs_url }}{{ site.docs_get_started }}) today.
