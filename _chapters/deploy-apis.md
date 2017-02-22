---
layout: post
title: Deploy APIs
date: 2017-01-05 00:00:00
---

### Deploy

Run this command when you have made code changes
{% highlight bash %}
$ serverless deploy
{% endhighlight %}


In the previous chapters, we've defined our Lambda functions to be deployed to the production stage. To deploy to another stage, run
{% highlight bash %}
$ serverless deploy --stage dev
{% endhighlight %}
