---
layout: post
title: Configure the AWS CLI
---

To make it easier to upload our assets to S3 we are going to use the AWS CLI. To use the [AWS CLI](https://aws.amazon.com/cli/) we need to create a new Access Key.

### Create a New AWS Access Key

1. In the upper right corner of your [AWS Console](https://console.aws.amazon.com/console/home), click on your account name and select **Security Credentials**.

2. On the **AWS Security Credentials** page, expand the **Access Keys** (**Access Key ID and Secret Access Key**) section.

3. Choose **Create New Access Key**. You can have a maximum of two access keys (active or inactive) at a time.

4. Choose **Download Key File** to save the access key ID and secret access key to a .csv file on your computer. After you close the dialog box, you can't retrieve this secret access key again. So make sure it keep track of your keys.

Your Acceess keys should be something like this:

- Access key ID **AKIAIOSFODNN7EXAMPLE**
- Secret access key **wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY**

Now let's install the AWS CLI.

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

We now need to tell the AWS CLI to use your Access Keys from a step above. Simply run the following and enter your Secret Key ID and your Access Key. You can leave the **Default region name** and **Default output format** the way they are.

{% highlight bash %}
aws configure
{% endhighlight %}

### List Your S3 Buckets

Just to test and ensure that your AWS CLI is properly configured, run the following command to see the list of all your S3 buckets. 

{% highlight bash %}
aws s3 ls
{% endhighlight %}

If everything has gone smoothly then you should see the bucket you created previously in the list.

And we are now ready to upload our assets to our previously created S3 bucket.
