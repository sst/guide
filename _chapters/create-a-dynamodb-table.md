---
layout: post
title: Create a DynamoDB Table
---

TODO
===
* open aws console in new window

Introduction to DynamoDB
===

In this tutorial, you will learn how to create a simple table, add data, scan and query the data, delete data, and delete the table using the DynamoDB Console.

* What is DynamoDB?

    Amazon DynamoDB is a fully managed NoSQL database. Similar to other database, DynamoDB stores data in tables. Each row in a table is called an `Item`. Each column value in a row is called an `Attribute`. Read more here [What Is Amazon DynamoDB][dynamodb-intro].


* How do indexes work?

    Each DynamoDB table has a primary key, which cannot be changed once set. DynamoDB supports two different kinds of primary keys:

    * Partition key
    * Partition key and sort key

    If you want to read the data using non-key attributes, you can use a secondary index to do this. Read more here [DynamoDB Core Components][dynamodb-components].

* What is Provisioned Throughput

    Read more here [Provisioned Throughput][dynamodb-throughput].


---

### Create a DynamoDB Table

First, log in to your [AWS Console](https://console.aws.amazon.com) and select DynamoDB from the list of services.

![Select DynamoDB Service screenshot]({{ site.url }}/assets/dynamodb/select-dynamodb-service.png)

Select **Create table**

![My helpful screenshot]({{ site.url }}/assets/dynamodb/create-table-start.png)

In the `Table name` field, type `notes`.

1. In the `Partition key` field, type `userId`. The `Partition key` is used to spread data across partitions for scalability. It’s important to choose an attribute with a wide range of values and that is likely to have evenly distributed access patterns.
1. Since each user may have many notes, you can enable easy sorting with a Sort Key. Check the Add sort key box. Type `noteId` in the Sort Key field.
1. We will accept the default settings for this example.
1. Now click **Create**.

3.png

When the “Music” table is ready to use, it appears in in the table list with a checkbox.

4.png

[aws-console]: https://console.aws.amazon.com/console/home?region=us-east-1
[dynamodb-intro]: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html
[dynamodb-components]: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
[dynamodb-throughput]: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ProvisionedThroughput.html
