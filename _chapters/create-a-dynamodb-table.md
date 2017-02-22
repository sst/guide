---
layout: post
title: Create a DynamoDB Table
date: 2016-12-27 00:00:00
---

To build the backend for our notes app, it makes sense that we first start by thinking about how the data is going to be stored. We are going to use [DynamoDB](https://aws.amazon.com/dynamodb/) to do this.

### About DynamoDB

Amazon DynamoDB is a fully managed NoSQL database that provides fast and predictable performance with seamless scalability. Similar to other database, DynamoDB stores data in tables. Each table contains multiple items, and each item is composed of one or more attributes.

### Create Table

First, log in to your [AWS Console](https://console.aws.amazon.com) and select **DynamoDB** from the list of services.

![Select DynamoDB Service screenshot]({{ site.url }}/assets/dynamodb/select-dynamodb-service.png)

Select **Create table**.

![Create DynamoDB Table screenshot]({{ site.url }}/assets/dynamodb/create-dynamodb-table.png)

Enter the **Table name** and **Primary key** info as shown below.

![Set Table Primary Key screenshot]({{ site.url }}/assets/dynamodb/set-table-primary-key.png)

Each DynamoDB table has a primary key, which cannot be changed once set. The primary key uniquely identifies each item in the table, so that no two items can have the same key. DynamoDB supports two different kinds of primary keys:

* Partition key
* Partition key and sort key (composite)

We are going to use the composite primary key which gives us additional flexibility when querying the data. For example, if you provide only the value for `userid`, DynamoDB would retrieve all of the notes by that user. Or you could provide a value for `userid` and a value for `noteid`, to retrieve a particular note.

To get a further understanding on how indexes work in DynamoDB, you can read more here [DynamoDB Core Components][dynamodb-components].

Ensure **Use default settings** is checked, then select **Create**.

![Set Table Provisioned Capacity screenshot]({{ site.url }}/assets/dynamodb/set-table-provisioned-capacity.png)

Note that the default setting provisions 5 reads and 5 writes. When you create a table, you specify how much provisioned throughput capacity you want to reserve for reads and writes. DynamoDB will reserve the necessary resources to meet your throughput needs while ensuring consistent, low-latency performance. One read capacity unit can read up to 8 KB per second and one write capacity unit can write up to 1 KB per second. You can change your provisioned throughput settings, increasing or decreasing capacity as needed.

The `notes` table has now been created. If you find yourself stuck with the **Table is being created** messsage; refresh the page manually.

![Select DynamoDB Service screenshot]({{ site.url }}/assets/dynamodb/dynamodb-table-created.png)

Next we'll setup an S3 bucket to handle file uploads.

[dynamodb-components]: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
