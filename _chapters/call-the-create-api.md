---
layout: post
title: Call the Create API
date: 2017-01-23 00:00:00
---

Now that we have our basic create note form working, let's connect it to our API. We'll do the upload to S3 a little bit later.

To make it easy to talk to API Gateway, we'll use the [AWS API Gateway JS Client](https://github.com/kndt84/aws-api-gateway-client).

### Installing the API Gateway JS Client

{% include code-marker.html %} Run the following command in your working directory

{% highlight bash %}
$ npm install aws-api-gateway-client --save
{% endhighlight %}

### Invoking the Client

To call our API through API Gateway we need to first create a client and then pass in a whole lot of parameters. And since we are going to make a lot of calls to our API, let's simplify the process a bit.

{% include code-marker.html %} Let's create a helper function in `src/libs/awsLib.js` and add the following. Make sure to create the `src/libs/` directory first.

{% highlight javascript %}
import apigClientFactory from 'aws-api-gateway-client';
import config from '../config.js';

function getApigClient() {
  return apigClientFactory.newClient({
    invokeUrl: config.apiGateway.URL,
    region: config.apiGateway.REGION
  });
}

export function invokeApig(
  { params = {},
    path,
    method = 'GET',
    additionalParams= {},
    body = {}}, userToken) {

  const apigClient = getApigClient();

  if ( ! additionalParams.haders) {
    additionalParams.headers = {};
  }

  additionalParams.headers.Authorization = userToken;

  return apigClient.invokeApi(params, path, method, additionalParams, body);
}
{% endhighlight %}

We just made it so that we can call `invokeApig` from now on and only pass in the parameters that are necessary. Also, it adds our user token to the header of the request.

{% include code-marker.html %} Now to create a new API Gateway client we need our region and API Gateway URL. Let's add that to our `src/config.js` above the `cognito: {` line.

{% highlight javascript %}
apiGateway: {
  REGION: 'us-east-1',
  URL: 'https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod',
},
{% endhighlight %}

### Make the Call

Now we are ready to make our create call in our form.

{% include code-marker.html %} Let's include our `awsLib` by adding the following to the header of `src/containers/NewNote.js`.

{% highlight javascript %}
import { invokeApig } from '../libs/awsLib.js';
{% endhighlight %}

{% include code-marker.html %} And replace our `handleSubmit` function with the following.

{% highlight javascript %}
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
    this.props.router.push('/');
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
{% endhighlight %}

This does a couple of simple things.

1. We make our create call in `createNote` by making a POST request to `/notes` and passing in our note object.

2. For now the note object is simply the content of the note. We are creating these notes without an attachment for now.

3. Finally, after the note is created we redirect to our home page.

And that's it; if you switch over to your browser and try submitting your form, it should successfully navigate over to our home page.

![New note created screenshot]({{ site.url }}/assets/new-note-created.png)

Next let's upload our file to S3 and add an attachment to our note.
