---
layout: post
title: Upload a File to S3
date: 2017-01-24 00:00:00
---

Let's now add an attachment to our note. The flow we are using here is very simple.

1. The user selects a file to upload.

2. The file is uploaded to S3 under the user's space and we get a URL back. 

3. Create a note with the file URL as the attachment.

We are going to use the AWS SDK to upload our files to S3. The S3 Bucket that we created previously, is secured using our Cognito Identity Pool. So to be able to upload, we first need to generate our Cognito Identity temporary credentials with our user token.

### Get AWS Credentials

{% include code-marker.html %} To do that let's append the following to our `src/libs/awsLib.js`.

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

{% include code-marker.html %} And include the **AWS SDK** in our header.

{% highlight javascript %}
import AWS from 'aws-sdk';
{% endhighlight %}

{% include code-marker.html %} To get our AWS credentials we need to use the following in our `src/config.js` below the `MAX_ATTACHMENT_SIZE` line.

{% highlight javascript %}
aws: {
  REGION: 'us-east-1',
  IDENTITY_POOL_ID: 'us-east-1:bdff90fd-8265-4356-9698-0d997fb05d38',
},
{% endhighlight %}

Be sure to replace the `IDENTITY_POOL_ID` with your own from the Cognito Identity Pool chapter.

{% include code-marker.html %} And also add this line in the `cognito` block of `src/config.js`.

{% highlight javascript %}
AUTHENTICATOR: 'cognito-idp.us-east-1.amazonaws.com/us-east-1_WdHEGAi8O',
{% endhighlight %}

The `AUTHENTICATOR` is the url that the SDK will use to authenticate the user. Replace the `us-east-1_WdHEGAi8O` with your Cognito User Pool ID.

Now we are ready to upload a file to S3.

### Upload to S3

{% include code-marker.html %} Append the following in `src/awsLib.js`.

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
      ContentType: file.type,
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

{% include code-marker.html %} And add this to our `src/config.js` above the `apiGateway` block.

{% highlight javascript %}
S3: {
  BUCKET: 'anomaly-notes-app',
  DOMAIN: 'https://s3.amazonaws.com'
},
{% endhighlight %}

Be sure to replace the `BUCKET` with your own bucket name from the S3 File Upload chapter.

The above method does a couple of things.

1. It takes a file object and the user token as parameters.

2. Generates a unique file name prefixed with the `identityId`. This is necessary to secure the files on a per-user basis.

3. Upload the file to S3 and set it's permissions to `public-read` to ensure that we can download it later.

4. And return the public URL.

### Upload Before Creating a Note

Now that we have our upload methods ready, let's call them from the create note method.

{% include code-marker.html %} Replace the `handleSubmit` method in `src/containers/NewNote.js` with the following.

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
      attachment: uploadedFilename,
    });
    this.props.router.push('/');
  }
  catch(e) {
    alert(e);
    this.setState({ isLoading: false });
  }

}
{% endhighlight %}

{% include code-marker.html %} And make sure to include `s3Upload` in the header by doing this:

{% highlight javascript %}
import { invokeApig, s3Upload } from '../libs/awsLib.js';
{% endhighlight %}

The change we've made in the `handleSubmit` is that:

1. We upload the file using `s3Upload`.

2. Use the returned URL and add that to the note object when we create the note.

Now when we switch over to our browser and submit the form with an uploaded file we should see the note being created successfully. And the app being redirected to the home page.

Next up we are going to make sure we clear out AWS credentials that are cached by the AWS JS SDK before we move on.
