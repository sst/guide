---
layout: post
title: Upload a File to S3
date: 2017-01-24 00:00:00
lang: en
ref: upload-a-file-to-s3
description: We want users to be able to upload a file in our React.js app and add it as an attachment to their note. To upload files to S3 directly from our React.js app we are going to use AWS Amplify's Storage.put() method.
comments_id: comments-for-upload-a-file-to-s3/123
---

Let's now add an attachment to our note. The flow we are using here is very simple.

1. The user selects a file to upload.
2. The file is uploaded to S3 under the user's folder and we get a key back.
3. Create a note with the file key as the attachment.

We are going to use the Storage module that AWS Amplify has. If you recall, that back in the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter we allow a logged in user access to a folder inside our S3 Bucket. AWS Amplify stores directly to this folder if we want to _privately_ store a file.

Also, just looking ahead a bit; we will be uploading files when a note is created and when a note is edited. So let's create a simple convenience method to help with that.

### Upload to S3

{%change%} Create `src/lib/awsLib.js` and add the following:

```js
import { Storage } from "aws-amplify";

export async function s3Upload(file) {
  const filename = `${Date.now()}-${file.name}`;

  const stored = await Storage.vault.put(filename, file, {
    contentType: file.type,
  });

  return stored.key;
}
```

The above method does a couple of things.

1. It takes a file object as a parameter.

2. Generates a unique file name using the current timestamp (`Date.now()`). Of course, if your app is being used heavily this might not be the best way to create a unique filename. But this should be fine for now.

3. Upload the file to the user's folder in S3 using the `Storage.vault.put()` object. Alternatively, if we were uploading publicly you can use the `Storage.put()` method.

4. And return the stored object's key.

### Upload Before Creating a Note

Now that we have our upload methods ready, let's call them from the create note method.

{%change%} Replace the `handleSubmit` method in `src/containers/NewNote.js` with the following.

```js
async function handleSubmit(event) {
  event.preventDefault();

  if (file.current && file.current.size > config.MAX_ATTACHMENT_SIZE) {
    alert(
      `Please pick a file smaller than ${
        config.MAX_ATTACHMENT_SIZE / 1000000
      } MB.`
    );
    return;
  }

  setIsLoading(true);

  try {
    const attachment = file.current ? await s3Upload(file.current) : null;

    await createNote({ content, attachment });
    nav("/");
  } catch (e) {
    onError(e);
    setIsLoading(false);
  }
}
```

{%change%} And make sure to include `s3Upload` by adding the following to the header of `src/containers/NewNote.js`.

```js
import { s3Upload } from "../lib/awsLib";
```

The change we've made in the `handleSubmit` is that:

1. We upload the file using the `s3Upload` method.

2. Use the returned key and add that to the note object when we create the note.

Now when we switch over to our browser and submit the form with an uploaded file we should see the note being created successfully. And the app being redirected to the homepage.

Next up we are going to allow users to see a list of the notes they've created.
