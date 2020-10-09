---
layout: post
title: Backups in DynamoDB
date: 2018-04-06 12:00:00
description: Amazon DynamoDB allows you to create On-demand backups and enable Point-in-time recovery with a single click. Backups are fully-managed, extremely fast, and do not impact performance. In this chapter we look at the two ways to backup and restore DynamoDB tables.
comments_id: backups-in-dynamodb/705
---

An important (yet overlooked) aspect of having a database powering your web application are, backups! In this chapter we are going to take a look at how to configure backups for your DynamoDB tables.

For [our demo notes app](https://demo.serverless-stack.com), we are using a DynamoDB table to store all our user's notes. DynamoDB achieves a high degree of data availability and durability by replicating your data across three different facilities within a given region. However, DynamoDB does not provide an SLA for the data durability. This means that you should backup your database tables.

Let's start by getting a quick background on how backups work in DynamoDB.

### Backups in DynamoDB

There are two types of backups in DynamoDB:

1. **On-demand backups**

   This creates a full backup on-demand of your DynamoDB tables. It's useful for long-term data retention and archival. The backup is retained even if the table is deleted. You can use the backup to restore to a different table name. And this can make it useful for replicating tables.

2. **Point-in-time recovery**

   This type of backup on the other hand allows you to perform point-in-time restore. It's really helpful in protecting against accidental writes or delete operations. So for example, if you ran a script to transform the data within a table and it accidentally removed or corrupted your data; you could simply restore your table to any point in the last 35 days. DynamoDB does this by maintaining an incremental backup of your table. It even does this automatically, so you don't have to worry about creating, maintaining, or scheduling on-demand backups.

Let's look at how to use the two backup types.

### On-Demand Backup

Head over to your table and click on the **Backups** tab.

![Click on Backups tab screenshot](/assets/dynamodb/click-on-backups-tab.png)

And just hit **Create backup**.

![Create DynamoDB table backup screenshot](/assets/dynamodb/create-dynamodb-table-backup.png)

Give your backup a name and hit **Create**.

![Name DynamoDB table backup screenshot](/assets/dynamodb/name-dynamodb-table-backup.png)

You should now be able to see your newly created backup.

![New DynamoDB table backup screenshot](/assets/dynamodb/new-dynamodb-table-backup.png)

### Restore Backup

Now to restore your backup, simply select the backup and hit **Restore backup**.

![Select Restore DynamoDB table backup screenshot](/assets/dynamodb/select-restore-dynamodb-table-backup.png)

Here you can type in the name of the new table you want to restore to and hit **Restore table**.

![Restore DynamoDB table backup screenshot](/assets/dynamodb/restore-dynamodb-table-backup.png)

Depending on the size of the table, this might take some time. But you should notice a new table being created from the backup.

![New DynamoDB table from backup screenshot](/assets/dynamodb/new-dynamodb-table-from-backup.png)

DynamoDB makes it easy to create and restore on-demand backups. You can also read more about [on-demand backups here](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/BackupRestore.html).

### Point-in-Time Recovery

To enable Point-in-time Recovery once again head over to the **Backups** tab.

![Head to Backups tab screenshot](/assets/dynamodb/head-to-backups-tab.png)

And hit **Enable** in the Point-in-time Recovery section. 

![Hit Enable DynamoDB Point-in-time Recovery screenshot](/assets/dynamodb/hit-enable-dynamodb-point-in-time-recovery.png)

This will notify you that additional charges will apply for this setting. Click **Enable** to confirm.

![Confirm Enable DynamoDB Point-in-time Recovery screenshot](/assets/dynamodb/confirm-enable-dynamodb-point-in-time-recovery.png)

### Restore to Point-in-Time

Once enabled, you can click **Restore to point-in-time** to restore to an older point.

![Restore DynamoDB to Point-in-time screenshot](/assets/dynamodb/restore-dynamodb-to-point-in-time.png)

Here you can type in the name of the new table to be restored to and select the time you want to recover to.

![Pick Restore DynamoDB to Point-in-time screenshot](/assets/dynamodb/pick-restore-dynamodb-to-point-in-time.png)

And hit **Restore table**.

![Select Restore DynamoDB table to Point-in-time screenshot](/assets/dynamodb/select-restore-dynamodb-table-to-point-in-time.png)

You should see your new table being restored.

![New restored DynamoDB table Point-in-time screenshot](/assets/dynamodb/new-restored-dynamodb-table-to-point-in-time.png)

You can read more about the details of [Point-in-time Recovery here](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.html).

### Conclusion

Given, the two above types; a good strategy is to enable Point-in-time recovery and maintain a schedule of longer term On-demand backups. There are quite a few plugins and scripts that can help you with scheduling On-demand backups, here is one created by one of our readers - https://github.com/UnlyEd/serverless-plugin-dynamodb-backups.

Also worth noting, DynamoDB's backup and restore actions have no impact on the table performance or availability. No worrying about long backup processes that slow down performance for your active users.

So make sure to configure backups for the DynamoDB tables in your applications.
