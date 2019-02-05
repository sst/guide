---
layout: post
title: Create a DynamoDB Table
date: 2016-12-27 00:00:00
lang: en
ref: create-a-dynamodb-table
description: Amazon DynamoDB is a fully managed NoSQL database that we are going to use to power our serverless API backend. DynamoDB stores data in tables and each table has a primary key that cannot be changed once set. We are also going to provision the throughput capacity by setting reads and writes for our DynamoDB table.
context: true
comments_id: create-a-dynamodb-table/139
---

To build the backend for our notes app, it makes sense that we first start by thinking about how the data is going to be stored. We are going to use [DynamoDB](https://aws.amazon.com/dynamodb/) to do this.

### About DynamoDB

Amazon DynamoDB is a fully managed NoSQL database that provides fast and predictable performance with seamless scalability. Similar to other databases, DynamoDB stores data in tables. Each table contains multiple items, and each item is composed of one or more attributes. We are going to cover some basics in the following chapters. But to get a better feel for it, here is a [great guide on DynamoDB](https://www.dynamodbguide.com).

### Create Table

First, log in to your [AWS Console](https://console.aws.amazon.com) and select **DynamoDB** from the list of services.

![Select DynamoDB Service screenshot](/assets/dynamodb/select-dynamodb-service.png)

Select **Create table**.

![Create DynamoDB Table screenshot](/assets/dynamodb/create-dynamodb-table.png)

Enter the **Table name** and **Primary key** info as shown below. Just make sure that `userId` and `noteId` are in camel case.

![Set Table Primary Key screenshot](/assets/dynamodb/set-table-primary-key.png)

Each DynamoDB table has a primary key, which cannot be changed once set. The primary key uniquely identifies each item in the table, so that no two items can have the same key. DynamoDB supports two different kinds of primary keys:

* Partition key
* Partition key and sort key (composite)

We are going to use the composite primary key which gives us additional flexibility when querying the data. For example, if you provide only the value for `userId`, DynamoDB would retrieve all of the notes by that user. Or you could provide a value for `userId` and a value for `noteId`, to retrieve a particular note.

To further your understanding of how indexes work in DynamoDB, you can read more here: [DynamoDB Core Components][dynamodb-components]

If you see the following message, deselect **Use default settings**.

![Auto Scaling IAM Role Warning screenshot](/assets/dynamodb/auto-scaling-iam-role-warning.png)

Scroll to the bottom, ensure that **DynamoDB AutoScaling Service Linked Role** is selected, and select **Create**.

![Set Table Provisioned Capacity screenshot](/assets/dynamodb/set-table-provisioned-capacity.png)

Otherwise, simply ensure that **Use default settings** is checked, then select **Create**.

Note that the default setting provisions 5 reads and 5 writes. When you create a table, you specify how much provisioned throughput capacity you want to reserve for reads and writes. DynamoDB will reserve the necessary resources to meet your throughput needs while ensuring consistent, low-latency performance. One read capacity unit can read up to 8 KB per second and one write capacity unit can write up to 1 KB per second. You can change your provisioned throughput settings, increasing or decreasing capacity as needed.

The `notes` table has now been created. If you find yourself stuck with the **Table is being created** message; refresh the page manually.

![Select DynamoDB Service screenshot](/assets/dynamodb/dynamodb-table-created.png)

It is also a good idea to set up backups for your DynamoDB table, especially if you are planning to use it in production. We cover this in an extra-credit chapter, [Backups in DynamoDB]({% link _chapters/backups-in-dynamodb.md %}).

Next we'll set up an S3 bucket to handle file uploads.

[dynamodb-components]: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
