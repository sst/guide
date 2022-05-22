---
layout: post
title: Call the Create API
date: 2017-01-23 00:00:00
lang: en
ref: call-the-create-api
description: To let our users create a note in our React.js app, we need to connect our form to our serverless API backend. We are going to use AWS Amplify's API module for this.
comments_id: call-the-create-api/124
---

Now that we have our basic create note form working, let's connect it to our API. We'll do the upload to S3 a little bit later. Our APIs are secured using AWS IAM and Cognito User Pool is our authentication provider. Thankfully, Amplify takes care of this for us by using the logged in user's session.

{%change%} Let's include the `API` module by adding the following to the header of `src/containers/NewNote.js`.

```js
import { API } from "aws-amplify";
```

{%change%} And replace our `handleSubmit` function with the following.

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
    await createNote({ content });
    nav("/");
  } catch (e) {
    onError(e);
    setIsLoading(false);
  }
}

function createNote(note) {
  return API.post("notes", "/notes", {
    body: note,
  });
}
```

This does a couple of simple things.

1. We make our create call in `createNote` by making a POST request to `/notes` and passing in our note object. Notice that the first two arguments to the `API.post()` method are `notes` and `/notes`. This is because back in the [Configure AWS Amplify]({% link _chapters/configure-aws-amplify.md %}) chapter we called these set of APIs by the name `notes`.

2. For now the note object is simply the content of the note. We are creating these notes without an attachment for now.

3. Finally, after the note is created we redirect to our homepage.

And that's it; if you switch over to your browser and try submitting your form, it should successfully navigate over to our homepage.

![New note created screenshot](/assets/new-note-created.png)

Next let's upload our file to S3 and add an attachment to our note.
