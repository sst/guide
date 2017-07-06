---
layout: post
title: Clear AWS Credentials Cache
date: 2017-01-25 00:00:00
description: Once a user logs out of our React.js app we need to ensure that we clear the AWS SDK temporary credentials. To do this we are going to call the AWS.config.credentials.clearCachedId method in our App component.
code: frontend
comments_id: 50
---

To be able to upload our files to S3 we needed to get the AWS credentials first. And the AWS JS SDK saves those credentials in our browser's Local Storage.

But we need to make sure that we clear out those credentials when we logout. If we don't, the next user that logs in on the same browser, might end up with the incorrect credentials.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />To do that let's add the following lines to the `handleLogout` method in our `src/App.js` above the `this.updateUserToken(null);` line.

``` javascript
if (AWS.config.credentials) {
  AWS.config.credentials.clearCachedId();
}
```

So our `handleLogout` as a result should now look like so:

``` javascript
handleLogout = (event) => {
  const currentUser = this.getCurrentUser();

  if (currentUser !== null) {
    currentUser.signOut();
  }

  if (AWS.config.credentials) {
    AWS.config.credentials.clearCachedId();
  }

  this.updateUserToken(null);

  this.props.history.push('/login');
}
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And include the **AWS SDK** in the header.

``` javascript
import AWS from 'aws-sdk';
```

Next up we are going to allow users to see a list of the notes they've created.
