---
layout: post
title: Upload a File to S3
date: 2017-01-24 00:00:00
description: Tutorial on how to upload a file directly to S3 from a React.js app using the AWS JS SDK and Cognito Identity Pool Credentials.
code: frontend
---

Let's now add an attachment to our note. The flow we are using here is very simple.

1. The user selects a file to upload.

2. The file is uploaded to S3 under the user's space and we get a URL back. 

3. Create a note with the file URL as the attachment.

We are going to use the AWS SDK to upload our files to S3. The S3 Bucket that we created previously, is secured using our Cognito Identity Pool. So to be able to upload, we first need to generate our Cognito Identity temporary credentials with our user token.

### Get Cognito Identity Pool Credentials

We are going to use the NPM module `aws-sdk` to help us get the Identity Pool credentials.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Install it by running the following in your project root.

``` bash
$ npm install aws-sdk --save
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Next, let's append the following to our `src/libs/awsLib.js`.

``` coffee
export function getAwsCredentials(userToken) {
  const authenticator = `cognito-idp.${config.cognito.REGION}.amazonaws.com/${config.cognito.USER_POOL_ID}`;

  AWS.config.update({ region: config.cognito.REGION });

  AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: config.cognito.IDENTITY_POOL_ID,
    Logins: {
      [authenticator]: userToken
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
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And include the **AWS SDK** in our header.

``` javascript
import AWS from 'aws-sdk';
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />To get our AWS credentials we need to add the following to our `src/config.js` in the `cognito` block. Make sure to replace `YOUR_IDENTITY_POOL_ID` with your **Identity pool ID** from the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter.

```
REGION: 'us-east-1',
IDENTITY_POOL_ID: 'YOUR_IDENTITY_POOL_ID',
```

Now we are ready to upload a file to S3.

### Upload to S3

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Append the following in `src/awsLib.js`.

``` coffee
export async function s3Upload(file, userToken) {
  await getAwsCredentials(userToken);

  const s3 = new AWS.S3({
    params: {
      Bucket: config.s3.BUCKET,
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

      resolve(`${config.s3.DOMAIN}/${config.s3.BUCKET}/${filename}`);
    })
  ));
}
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And add this to our `src/config.js` above the `apiGateway` block. Make sure to replace `YOUR_S3_UPLOADS_BUCKET_NAME` with the your S3 Bucket name from the [Create an S3 bucket for file uploads]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) chapter.

```
s3: {
  BUCKET: 'YOUR_S3_UPLOADS_BUCKET_NAME',
  DOMAIN: 'https://s3.amazonaws.com'
},
```

Be sure to replace the `BUCKET` with your own bucket name from the S3 File Upload chapter.

The above method does a couple of things.

1. It takes a file object and the user token as parameters.

2. Generates a unique file name prefixed with the `identityId`. This is necessary to secure the files on a per-user basis.

3. Upload the file to S3 and set it's permissions to `public-read` to ensure that we can download it later.

4. And return the public URL.

### Upload Before Creating a Note

Now that we have our upload methods ready, let's call them from the create note method.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace the `handleSubmit` method in `src/containers/NewNote.js` with the following.

``` javascript
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
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And make sure to include `s3Upload` in the header by doing this:

``` javascript
import { invokeApig, s3Upload } from '../libs/awsLib.js';
```

The change we've made in the `handleSubmit` is that:

1. We upload the file using `s3Upload`.

2. Use the returned URL and add that to the note object when we create the note.

Now when we switch over to our browser and submit the form with an uploaded file we should see the note being created successfully. And the app being redirected to the home page.

Next up we are going to make sure we clear out AWS credentials that are cached by the AWS JS SDK before we move on.
