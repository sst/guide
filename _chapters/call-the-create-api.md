---
layout: post
title: Call the Create API
date: 2017-01-23 00:00:00
description: Tutorial on how to call an AWS API Gateway endpoint from your React.js app.
code: frontend
comments_id: 48
---

Now that we have our basic create note form working, let's connect it to our API. We'll do the upload to S3 a little bit later.

### Calling API Gateway

Since we are going to be calling API Gateway a few times in our app, let's first create a little helper function for it.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Let's create a helper function in `src/libs/awsLib.js` and add the following. Make sure to create the `src/libs/` directory first.

``` coffee
import config from '../config.js';

export async function invokeApig(
  { path,
    method = 'GET',
    body }, userToken) {

  const url = `${config.apiGateway.URL}${path}`;
  const headers = {
    Authorization: userToken,
  };

  body = (body) ? JSON.stringify(body) : body;

  const results = await fetch(url, {
    method,
    body,
    headers
  });

  return results.json();
}
```

We just made it so that we can call `invokeApig` from now on and only pass in the parameters that are necessary. Also, it adds our user token to the header of the request.

Now to call our API we need the API Gateway URL that was generated back in the [Deploy the APIs]({% link _chapters/deploy-the-apis.md %}) chapter.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Let's add that to our `src/config.js` above the `cognito: {` line. Make sure to replace `https://YOUR_API_GATEWAY_URL` with your URL.

```
apiGateway: {
  URL: 'https://YOUR_API_GATEWAY_URL',
},
```

### Make the Call

Now we are ready to make our create call in our form.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Let's include our `awsLib` by adding the following to the header of `src/containers/NewNote.js`.

``` javascript
import { invokeApig } from '../libs/awsLib';
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And replace our `handleSubmit` function with the following.

``` javascript
handleSubmit = async (event) => {
  event.preventDefault();

  if (this.file && this.file.size > config.MAX_ATTACHMENT_SIZE) {
    alert('Please pick a file smaller than 5MB');
    return;
  }

  this.setState({ isLoading: true });

  try {
    await this.createNote({
      content: this.state.content,
    });
    this.props.history.push('/');
  }
  catch(e) {
    alert(e);
    this.setState({ isLoading: false });
  }

}

createNote(note) {
  return invokeApig({
    path: '/notes',
    method: 'POST',
    body: note,
  }, this.props.userToken);
}
```

This does a couple of simple things.

1. We make our create call in `createNote` by making a POST request to `/notes` and passing in our note object.

2. For now the note object is simply the content of the note. We are creating these notes without an attachment for now.

3. Finally, after the note is created we redirect to our homepage.

And that's it; if you switch over to your browser and try submitting your form, it should successfully navigate over to our homepage.

![New note created screenshot]({{ site.url }}/assets/new-note-created.png)

Next let's upload our file to S3 and add an attachment to our note.
