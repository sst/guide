---
layout: post
title: Wrapping Up
lang: en
description: Wrapping up the tutorial and going over the next steps.
date: 2018-03-30 00:00:00
ref: wrapping-up
code: sst_full
comments_id: comments-for-wrapping-up/100
---

Congratulations on completing the guide!

### App in Prod

We've covered how to build and deploy our backend serverless API and our frontend serverless app. And not only does it work well on the desktop.

![App update live screenshot](/assets/app-update-live.png)

It's mobile optimized as well!

<img alt="Mobile app homescreen screenshot" src="/assets/mobile-app-homescreen.png" width="432" />

### Manage in Prod

One final thing! You can also manage your app in production with the [SST Console]({{ site.docs_url }}/console ).

Run the following in your project root.

```bash
$ npx sst console --stage prod
```

This'll allow you to connect your SST Console to your prod stage.

```txt
SST Console: https://console.serverless-stack.com/notes/prod/stacks
```

It'll show you all the resources in production.

![SST Console prod stacks tab](/assets/part2/sst-console-prod-stacks-tab.png)

All your users.

![SST Console prod Cognito tab](/assets/part2/sst-console-prod-cognito-tab.png)

The notes your users have created.

![SST Console prod DynamoDB tab](/assets/part2/sst-console-prod-dynamodb-tab.png)

You can even see the request logs in production.

![SST Console prod functions tab](/assets/part2/sst-console-prod-functions-tab.png)

---

We hope what you've learned here can be adapted to fit the use case you have in mind. We are going to be covering a few other topics in the future while we keep this guide up to date.

We'd love to hear from you about your experience following this guide. Please [**fill out our survey**]({{ site.survey_url }}) or send us any comments or feedback you might have, via [email](mailto:{{ site.email }}). And [please star our repo on GitHub]({{ site.sst_github_repo }}), it really helps spread the word.

<a class="button contact" href="{{ site.sst_github_repo }}" target="_blank">Star our GitHub repo</a>

Also, we'd love to feature what you've built with Serverless Stack, please [send us a URL and brief description](mailto:{{ site.email }}).

Thank you and we hope you found this guide helpful!
