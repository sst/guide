---
layout: post
title: Create a S3 Bucket for file upload
---

Amazon S3 (Simple Storage Service) provides storage service through web services interfaces like REST. You can store any object on S3, including images, videos, files, etc. Objects are organized into buckets, and identified within each bucket by a unique, user-assigned key.

In this tutorial, we are going to create an S3 bucket which will be used to store user uploaded files from our notes app.

### Create Bucket

First, log in to your [AWS Console](https://console.aws.amazon.com) and select S3 from the list of services.

![Select S3 Service screenshot]({{ site.url }}/assets/s3/select-s3-service.png)

Select **Create Bucket**

![Select Create Bucket screenshot]({{ site.url }}/assets/s3/select-create-bucket.png)

Pick a name of the bucket and select the **US Standard** Region. Then select **Create**.

**Bucket names** are globally unique, which means you cannot pick the same name as the tutorial.

**Region** is the physical geological region where the files are stored. You can choose any AWS Region that is geographically close to you to optimize latency. We will use **US Standard** in this tutorial.

![Create S3 Bucket screenshot]({{ site.url }}/assets/s3/create-s3-bucket.png)

The S3 bucket is created.

![Create S3 Bucket Successful screenshot]({{ site.url }}/assets/s3/create-s3-bucket-successful.png)
