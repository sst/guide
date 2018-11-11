---
layout: post
title: DynamoDB Paging
date: 2016-12-30 00:00:00
description: To allow users to create notes in our note taking app, we are going to add a create note POST API. To do this we are going to add a new Lambda function to our Serverless Framework project. The Lambda function will save the note to our DynamoDB table and return the newly created note. We also need to ensure to set the Access-Control headers to enable CORS for our serverless backend API.
context: true
code: backend
comments_id: add-a-create-note-api/125
---

- Two types of backups: On-Demand backup and Continuous backup
- On-Demand backup is useful to create full backups of your tables for long-term retention and archival.
- Continuous backup allows you to perform point-in-time restore.
- Backup and restore actions execute with zero impact on table performance or availability.


### On-Demand Backup and Restore
- Backups are preserved regardless of table deletion.
- Can restore a backup to a different table name
- Good for replicating table

Create an on-demand backup:
https://imgur.com/mwIZouf

View all backups:
https://imgur.com/4BBJaCB

Documentation:
https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/BackupRestore.html

### Point-in-Time Recovery
- Helps protect your DynamoDB tables from accidental write or delete operations
- Don't have to worry about creating, maintaining, or scheduling on-demand backups.
- DynamoDB maintains incremental backups of your table.
- With point-in-time recovery, you can restore that table to any point in time during the last 35 days.

Create continuous backup:
https://imgur.com/TPDdT7l

Documentation:
https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.html
