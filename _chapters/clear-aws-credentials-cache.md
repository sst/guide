---
layout: post
title: Clear AWS Credentials Cache
date: 2017-01-25 00:00:00
description: Once a user logs out of our React.js app we need to ensure that we clear the AWS SDK temporary credentials. To do this we are going to call the AWS.config.credentials.clearCachedId method in our App component.
context: frontend
code: frontend
comments_id: 50
---

To be able to upload our files to S3 we needed to get the AWS credentials first. And the AWS JS SDK saves those credentials in our browser's Local Storage.

But we need to make sure that we clear out those credentials when we logout. If we don't, the next user that logs in on the same browser, might end up with the incorrect credentials.

<img class="code-marker" src="/assets/s.png" />To do that let's replace the `signOutUser` method in our `src/libs/awsLib.js` with this:

``` javascript
export function signOutUser() {
  const currentUser = getCurrentUser();

  if (currentUser !== null) {
    currentUser.signOut();
  }

  if (AWS.config.credentials) {
    AWS.config.credentials.clearCachedId();
    AWS.config.credentials = new AWS.CognitoIdentityCredentials({});
  }
}
```

Here we are clearing the AWS JS SDK cache and resetting the credentials that it saves in the browser's Local Storage.

Next up we are going to allow users to see a list of the notes they've created.
