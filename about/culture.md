---
layout: page
title: How We Work
editable: true
description: This document is meant to be used as a user manual for SST team. In it we go over our cultural values and how we operate as a team.
---

In this document we'll go over the cultural values that drive our team at SST. But before we get to these values, we want to go over a few things. We want to look at what we are building, why we are building it, and how we operate as a team. This'll give us a good sense of where our cultural values come from and why they matter to us.

Here's what we'll be covering in this document.

- [Background](#background)
- [Our vision](#our-vision)
- [How we build products](#how-we-build-products)
- [How we operate as a team](#how-we-operate-as-a-team)
- [Cultural values](#cultural-values)

Let's get started!

## About this document

This document is meant to be used as a user manual for SST team. We think sharing it publicly serves two purposes:

1. It helps the community get a better sense of how we operate.
2. And, it helps keep us accountable to the standards we set.

This document is a work in progress. If you have feedback on what's covered here, or have suggestions on what we should add, please let us know.

## Background

### What is serverless

Serverless is a new way of building applications. Developers use infrastructure-as-code to define and provision fully-managed services. Resources are provisioned programmatically and the pricing is completely usage based.

> Serverless is a perfect fit for startups.

Since the infrastructure is fully-managed and completely programmable, a single developer should be able to build an application that scales to millions of users with no operational overhead.

It's a perfect fit for a startup.

### Problems with serverless

However, there are few different problems with adopting serverless. Let’s just focus on the two biggest issues for now:

1. It's extremely complicated to configure. This follows from the fact that a serverless application is a combination of at least a handful of fully-managed services. Each service has a large number of configurable options.
2. The development feedback loop is broken. Since these applications are completely based in the cloud. Testing them requires you to either mock these services locally or redeploy them to test.

## Our vision

We think every startup should be built using serverless and we want to create a platform that makes this possible. They should be able to get started by using our platform. And continue to use it as their application and company grows. In a sense, they should be able to use our platform to go from _idea to IPO_.

> Build a platform that a startup can use to go from idea to IPO.

This means that our platform needs to be both:

1. Easy to get started, by abstracting out the complexity of the underlying services.
2. And completely configurable, allowing you to use the full power of the underlying cloud services.

## How we build products

Building a platform that's both easy to get started and completely configurable is a challenge. There are a broad number of use cases and each use case needs to be configurable. In a sense, the problem space is both wide and deep.

Problems like these are a good fit for open source. Users of open source projects tend to naturally extend the use cases of the project. This is observed in the long-tail of use cases that an open source project addresses. Especially in comparison to its closed source counterparts.

Users of open source software are also far more willing to provide feedback, when compared to closed source software. Whether it is sharing key information about their problems or even collaborating to solve it. We noticed that the sense of altruism amongst open source users leads to a much higher bandwidth of feedback.

> The sense of altruism amongst open source users leads to a much higher bandwidth of feedback.

The two above ideas together create a virtuous cycle that effectively describes how we build our products.

1. Open source users extend our products to other use cases.
2. They run into some problems with them.
3. They provide us with detailed feedback, as only open source users can.
4. This feedback allows us to do a good job while addressing their issue.
5. This leads to our users being excited to try it for additional use cases.
6. And the cycle continues.

This virtuous cycle lets us traverse the problem space while prioritizing our user's needs. It also presents us with natural growth opportunities for the business.

Let’s look at what this means practically. Starting with how we implement feature requests.

### How we implement features

Here’s a rough step-by-step process that we try to follow.

Let’s assume we get a message on Discord or somebody opens an issue on GitHub.

1. Start by understanding what the user is trying to do.
    - If it’s a bug, understand what's causing it. We don't need to have a solution, but we need to get all the information required to debug the issue. It's harder to get the user to send you debug information after they’ve moved on.
    - If it is a feature request, understand what the user is trying to achieve. Listen to their problems, not their solutions.
2. Then we create a GitHub issue with:
    - Everything that was talked about
    - List of all the places that it’s been brought up in
    - List of all the people that’ve brought it up
    - If the issue has been brought up before, add the new person to the list
3. After we understand the problem, figure out if it’s straightforward to implement or if we need to design a solution.
    - A straightforward solution usually includes bug fixes or features that don’t change the overall design of the product.
    - On the other hand, if the solution isn’t obvious or is a bigger change, we need to make some design decisions (more on this below). For design decisions, get the team involved.
        - Before the group discussion, come up with a proposed solution.
        - If the issue is urgent, don't hesitate to get somebody’s time. The leadership team needs to be on-call for urgent issues.
        - If the issue is not urgent, you can book a time on somebody's calendar. Or bring it up in the 1 on 1.
4. We then propose the solution to the user. Preferably with code snippets, and ask the user if it solves their issue.
5. Update the GitHub issue with the proposed solution. For something that's really simple to implement, we can skip this step.
6. We figure out the priority for this issue and when we are going to work on it. More on this below.
7. If you are working on it right now, tell the people that reported the issue. They are likely to help if you need some additional feedback.
8. Implement the solution in a PR. You can read more about PRs and cutting releases in our [CONTRIBUTING.md]({{ site.sst_github_repo }}/blob/master/CONTRIBUTING.md).
9. If the new feature has a new name or it's a new option, review the naming with the team.
10. Write a doc for it and add it to the PR. It doesn’t have to be perfect but it needs to be functional. The copy will be reviewed later but the content needs to be figured out upfront.
11. Cut a release. In the release notes mention how to use the feature.
12. Tell everybody that requested it about the release. Mention the version number, so they can upgrade to it.
13. Announce the release in Discord, with a snippet on how to use the feature.
14. Make a list of all the copy and docs changes that need to be reviewed, create an issue and send it to the team.

The key here is that it’s easier to gather the requirements and understand the problem when it’s first reported. Even if we don’t end up implementing the fix right away, users are far more engaged when the issue is first reported. We want to figure out a solution and get it validated by our users as early as possible. And document everything in a GitHub issue.

> We want to figure out a solution and get it validated by our users as early as possible.

We also want to notify users when we release a fix. It shows them that we personally care. And it makes it more likely that they'll give us feedback in the future.

### How we prioritize what to work on

We have a rough flowchart that we use to prioritize features. This will evolve as the priorities of the team changes.

Is there a user blocked by the issue or feature request?

- Yes ⇒ Fix it now
- No ⇒ Is the issue related to a new user's experience?
    - Yes ⇒ Fix it now
    - No ⇒ Is it a quick change (will take less than 30mins to implement)?
        - Yes ⇒ Mark it as High priority
        - No ⇒ Has it been brought up before?
            - Yes ⇒ Mark it as High priority (bumped up from Low)
            - No ⇒ Mark it as Low priority

So the priorities look like: "Fix it now", "High", or "Low". The "Fix it now" ones are the urgent issues that we work on right away. While the "High" priority ones are the issues that we are currently working on (when there's nothing urgent). The "Low" priority ones don't get worked on until we've run out of the "High" priority issues. Or they get bumped in priority.

For the "Fix it now" and "High" priority issues, we tell the user the timeline for the fix (today or tomorrow vs this week or next week). On the other hand, for low priority issues we tell them we won’t get to it right away. But ask them to let us know if it becomes a blocker and we’ll bump it up in priority.

While the above flow can seem a bit rigid, there are a couple of caveats. For example, we might prioritize a feature differently:

- If it's being requested by a valued member of our community
- If a person that's trying to contribute to the project needs it
- If you think we can solve it in a novel way and it can have a big impact

Feel free to pull the leadership team in, if you need any help. We hope that over time you are able to build a better sense of how to prioritize features.

### Our design process

As mentioned above, there are some issues that are not straightforward to implement. They require a certain amount of design. These are typically issues that have multiple solutions and it's not immediately clear which approach makes sense. It's important that we have cohesively designed products that work well together. We also care about making our products intuitive to use. This means that for some issues we need to put a lot more thought while designing a solution. We employ a "design" meeting to work through this. It usually involves:

1. Understanding the root cause of the problem we are trying to solve.
2. Looking at the prior art in the field and understanding their pros and cons.
3. Weighing the different approaches we can take to solve the problem.
    - This involves putting together pseudo code or demos for the team to evaluate.
    - It's much easier to evaluate possible options based on something real.
4. Making sure that the proposed solution works with the design choices made across our other products.

It's important that we work through this process on our own, before a design meeting. The rest of the leadership team is there to help you make a decision. And it allows you to get better at making these decisions.

> It's important to work through the design process on your own, before meeting with the team.

It should also be mentioned that it's the responsibility of the leadership team to not make these meetings a blocker. If a feature needs to be implemented urgently, they are on-call for these meetings. 

### Naming things

We also like to take care while naming features, config options, props, etc. For anything new:

1. Suggest what you'd like to name it and why.
2. Offer two other suggestions and what you like about them.
3. Post this in the team channel. The rest of the team will quickly vote on them or add their own suggestions.

Coming up with a good name can sometimes be hard. But it's worth thinking it through, especially for things that can be hard to rename later.

## How we operate as a team

The above should give you some sense of how we operate internally as a team. But let's look at it in a little more detail. We’ll look at it from the perspective of an engineer that’s building our products.

The process of talking to users and building products is the core engine that drives our team. This implies a couple of things:

- We want the entire product process to be run independently by our engineers.
- This includes talking to users, gathering requirements, proposing solutions, implementing them, releasing them, and notifying our users.
- We want to reduce the number of people an engineer needs to talk to internally to get something done.
- For the cases where we need the leadership team’s input on design, we want to ensure that the leadership team is always available to provide feedback.
- We also want each engineer to have ownership of specific parts of the product and manage the roadmap for it.
- Keep track of the key input and output metrics of the product to drive its growth.

The role of the leadership team is to give an engineer as much autonomy as possible and to make sure the product process is running smoothly.

## Cultural values

All of this leads us to our core tenets, our cultural values.

### Having a services mindset

We need to remind ourselves that our users are using our products to get their jobs done. While they need help with our products, it’s because there is a bigger purpose to what they are doing. So our mindset while interacting with our users should be helping them get to where they want to go.

There's an unhealthy power dynamic in large communities between the "in" crowd and the new folks. We need to avoid this by having a high degree of empathy. No issue is too small or too trivial or too dumb. It’s our job to make sure the user is able to do what they want to do through our products.

### Thinking as a user and paying attention to the details

While we are trying to help our users build their products we are not merely providing “support” or “services”. We are trying to figure out how our products can do a better job for them. We need to pay attention to the details of their experience. This doesn’t always mean making big changes to our products. It could be something as simple as clarifying some small details in our docs. We need to think as a user and use their feedback to improve the product.

As a team, we rely heavily on our users to guide our product roadmap. So it’s important that as engineers we spend time thinking about all the little details of their experience. This information helps us make better product decisions. And ultimately lets us make something that people want.

### Having good taste

A lot of the key products and features that we work on, require us to make design decisions on behalf of our users. In an industry where most solutions are overly complicated, we need to be able to design intuitive products that are easy to use. It also matters that we use similar design principles across our products, so as to minimize the number of concepts a user has to learn.

We need to have a high personal bar when it comes to design. Design in our case is about all the small decisions we make while creating our products. We need to weigh our options carefully and try to make the right tradeoffs. This also makes our users feel that there was a certain degree of care that was taken while building it.

### Moving with urgency

As noted in the product process above, it’s important that we respond in a timely manner and gather feedback quickly. It’s important to capture feedback before the user moves on. Similarly, it’s important to push out features right when they need them.

Moving with a sense of urgency that’s driven by user feedback allows us to delight users, build community engagement, and foster a culture internally that’s exciting to be a part of.

### Taking ownership

We want our engineers to run the entire product process. We want them to take on a part of the product and drive the roadmap completely. We want them to select the KPIs, set the goals, and take part in our weekly and monthly reviews as a representative of that product.

We think it's naturally motivating to be responsible for building something that solves a problem for somebody else. So we want to create an environment where it's possible to take ownership of that entire process.
