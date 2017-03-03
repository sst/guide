---
layout: post
title: Clear AWS Credentials Cache
date: 2017-01-25 00:00:00
code: frontend
---

To be able to upload our files to S3 we needed to get the AWS credentials first. And the AWS JS SDK saves those credentials in our browser's Local Storage.

But we need to make sure that we clear out those credentials when we logout. If we don't, the next user that logs in on the same browser, might end up with the incorrect credentials.

{% include code-marker.html %} To do that let's add the following lines to the `handleLogout` method in our `src/App.js` above the `this.updateUserToken(null);` line.

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

  if (this.props.location.pathname !== '/login') {
    this.props.router.push('/login');
  }
}
```

{% include code-marker.html %} And include the **AWS SDK** in the header.

``` javascript
import AWS from 'aws-sdk';
```

Next up we are going to allow users to see a list of the notes they've created.
