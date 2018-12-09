---
layout: post
title: DynamoDB Backups
date: 2016-12-30 00:00:00
description: 
context: true
code: backend
comments_id: add-a-create-note-api/125
---

An important (yet overlooked) aspect of having a database powering your web application is, backups! In this chapter we are going to take a look at how to configure backups for your DynamoDB tables.

For our notes app, we are using a DynamoDB table to store all our user's notes. DynamoDB achieves a high degree of data availability and durability by replicating your data across three different facilities within the given region. However, DynamoDB does not provide an SLA for the data durability. This means that you should backup your database tables.

Let's start by getting a quick background on how backups work in DynamoDB.

### Backups in DynamoDB

There are two types of backups in DynamoDB:

1. On-demand backups
   This creates a full backup on-demand of your DynamoDB tables. It's useful for long-term data retention and archival. The backup is retained even if the table is deleted. You can use the backup to restore to a different table name. And this can make it useful for replicating tables.

2. Point-in-time recovery
   This type of backup on the otherhand allows you to perform point-in-time restore. It's really helpful in protecting against accidental writes or delete operations. So for example, if you ran a script to tranform the data within a table and it accidentally removed or corrupted your data; you could simply restore your table to any point in the last 35 days. DynamoDB does this by maintaining a incremental backups of your table. It even does this automatically, so you don't have to worry about creating, maintaining, or scheduling on-demand backups.

Let's look at how to use the two backup types.

### On-Demand Backup and Restore

Head over to your table and click on the **Bakcups** tab.

https://imgur.com/TPDdT7l

And just hit **Create backup**

---- And to restore a backup do...

You can also read more about [on-demand backups here](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/BackupRestore.html).

### Point-in-Time Recovery

To enable Point-in-Time Recovery once again head over to the **Backups** tab.

And hit **Enable** in the Point-in-time Recovery section. 

-- And just as before you can recover it by...

Create an on-demand backup:
https://imgur.com/mwIZouf

View all backups:
https://imgur.com/4BBJaCB

You can read more about the details of [Point-in-time Recovery here](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.html).

### Conclusion

Given, the two above types; a good strategy is to enable Point-in-time recovery and maintain a schedule of longer term On-demand backups.

Also worth noting, DynamoDB's backup and restore actions have no impact of the table performance or availability. No worrying about long backup processes that slow down performance for your active users.

So make sure to configure backups for the DynamoDB tables in your applications.
