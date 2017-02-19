---
layout: post
title: Upload File to S3
---

Let's now add an attachment to our note. The flow we are using here is very simple.

1. The user uploads the file.

2. The file is uploaded to S3 under the user's space and we get a URL back. 

3. Create a note with the file URL as the attachment.

We are going to use the AWS SDK to upload our files to S3. But to be able to upload we first need to generate our AWS temporary credentials using our user token.

### Get AWS Credentials

To do that let's add the following to our `src/lib/awsLib.js`.

{% highlight javascript %}
export function getAwsCredentials(userToken) {
  AWS.config.update({ region: config.aws.REGION });

  AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: config.aws.IDENTITY_POOL_ID,
    Logins: {
      [config.cognito.AUTHENTICATOR]: userToken
    }
  });

  return new Promise((resolve, reject) => (
    AWS.config.credentials.get((err) => {
      if (err) {
        reject(err);
        return;
      }

      resolve();
    })
  ));
}
{% endhighlight %}

And include it in our header using the following.

{% highlight javascript %}
import AWS from 'aws-sdk';
{% endhighlight %}

To get our AWS credentials we need to use the following in our `src/config.js`.

{% highlight javascript %}
aws: {
  REGION: 'us-east-1',
  IDENTITY_POOL_ID: 'us-east-1:bdff90fd-8265-4356-9698-0d997fb05d38',
},
{% endhighlight %}

And also add this in the `cognito` block.

{% highlight javascript %}
AUTHENTICATOR: 'cognito-idp.us-east-1.amazonaws.com/us-east-1_WdHEGAi8O',
{% endhighlight %}

The `AUTHENTICATOR` is a part of our AWS Cognito setup that is required to validate our user token. 

### Upload to S3

Now we are ready to upload a file to S3. Add the following in `src/awsLib.js`.

{% highlight javascript %}
export async function s3Upload(file, userToken) {
  await getAwsCredentials(userToken);

  const s3 = new AWS.S3({
    params: {
      Bucket: config.S3.BUCKET,
    }
  });
  const filename = `${AWS.config.credentials.identityId}-${Date.now()}-${file.name}`;

  return new Promise((resolve, reject) => (
    s3.putObject({
      Key: filename,
      Body: file,
      ACL: 'public-read',
    },
    (error, result) => {
      if (error) {
        reject(error);
        return;
      }

      resolve(`${config.S3.DOMAIN}/${config.S3.BUCKET}/${filename}`);
    })
  ));
}
{% endhighlight %}

And add the following to our `src/config.js`.

{% highlight javascript %}
S3: {
  BUCKET: 'anomaly-notes-app',
  DOMAIN: 'https://s3.amazonaws.com'
},
{% endhighlight %}

The above method does a couple of things.

1. It takes a file object and the user token as parameters.

2. Generates a unique file name prefixed with our `identityId` that's a part of the credentials we generated.

3. Upload the file to S3 and set it's permissions to `public-read` to ensure that we can download it later.

4. And return the public URL.

### Upload before Creating a Note

Now that we have our upload methods ready, let's call them from create note method.

Replace the `handleSubmit` method in `src/containers/NewNote.js` with the following.

{% highlight javascript %}
handleSubmit = async (event) => {
  event.preventDefault();

  if (this.file && this.file.size > config.MAX_ATTACHMENT_SIZE) {
    alert('Please pick a file smaller than 5MB');
    return;
  }

  this.setState({ isLoading: true });

  try {
    const uploadedFilename = (this.file)
      ? await s3Upload(this.file, this.props.userToken)
      : null;

    await this.createNote({
      content: this.state.content,
      file: uploadedFilename,
    });
    this.props.router.push('/');
  }
  catch(e) {
    alert(e);
    this.setState({ isLoading: false });
  }

}
{% endhighlight %}

And make sure to include `s3Upload` in the header by doing this.

{% highlight javascript %}
import { invokeApig, s3Upload } from '../lib/awsLib.js';
{% endhighlight %}

The change we've made in the `handleSubmit` is that

1. We upload the file using `s3Upload`.

2. Use the returned URL and add that to the note object when we create the note.

Now when we swtich over to our browser and submit the form with an uploaded file we should see the note being created successfully. Unfortunately, we are not displaying the file upload information yet but you can see analyze the requests to see that the upload request is made successfully.

![New note file uploaded screenshot]({{ site.url }}/assets/new-note-file-uploaded.png)

Next up we are going to make sure we clear out AWS credentials that are cached by the AWS JS SDK before we move on.
