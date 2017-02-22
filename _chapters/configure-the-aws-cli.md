---
layout: post
title: Configure the AWS CLI
date: 2016-12-26 00:00:00
---

To make it easier to work with a lot of the AWS services, we are going to use the [AWS CLI](https://aws.amazon.com/cli/).

### Install the AWS CLI

AWS CLI needs Python 2 version 2.6.5+ or Python 3 version 3.3+ and [Pip](https://pypi.python.org/pypi/pip). Use the following if you need help installing Python or Pip.

- [Installing Python](https://www.python.org/downloads/)
- [Installing Pip](https://pip.pypa.io/en/stable/installing/)

Now using Pip you can install the AWS CLI (on Linux, macOS, or Unix) by running:

{% highlight bash %}
sudo pip install awscli
{% endhighlight %}

If you are having some problems installing the AWS CLI or need Windows install instructions, refer to the [complete install instructions](http://docs.aws.amazon.com/cli/latest/userguide/installing.html).

### Add Your Access Key to AWS CLI

We now need to tell the AWS CLI to use your Access Keys from a step above.

It should look something like this:

- Access key ID **AKIAIOSFODNN7EXAMPLE**
- Secret access key **wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY**

Simply run the following and enter your Secret Key ID and your Access Key. You can leave the **Default region name** and **Default output format** the way they are.

{% highlight bash %}
aws configure
{% endhighlight %}

Next let's get started with setting up our backend.
