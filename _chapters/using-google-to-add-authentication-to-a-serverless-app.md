---
layout: post
title: Using Google to add authentication to a serverless app
date: 2021-08-05 00:00:00
lang: en
description: 
ref: using-google-to-add-authentication-to-a-serverless-app
comments_id: 
---

The final code for this project can be found at [https://github.com/theBenForce/google-sign-in-demo](https://github.com/theBenForce/google-sign-in-demo).

To get started, create a new [Serverless Stack (SST)](https://docs.serverless-stack.com) project by running the following command:

```bash
yarn create serverless-stack google-sign-in-demo --language typescript
```

This will make sure the `serverless-stack` package is globally installed. After the package is installed, execute it. You’ll find a new folder called `google-sign-in-demo` with your project in it. Next, `cd` into that folder and open it in your favorite editor:

```bash
cd google-sign-in-demo
code .
```

Looking at your project, you should see the following structure:

![Project structure](https://i.imgur.com/L6JEAyR.png)

If you open the `lib/index.ts` file, you'll see a `main` function that gets called whenever you deploy the stack. If you've used AWS's Cloud Development Kit, or `CDK`, this will look somewhat familiar. The only exception is that the `app` is passed into the main function; you don’t need to create it yourself. Currently, the main function should look like this:

```tsx
import MyStack from "./MyStack";
import * as sst from "@serverless-stack/resources";

export default function main(app: sst.App): void {
    // Set default runtime for all functions
    app.setDefaultFunctionProps({
        runtime: "nodejs12.x",
    });

    new MyStack(app, "my-stack");

    // Add more stacks
}
```

You'll see the application creates one stack, `MyStack`. Let's open that file and take a look. You should see two resources being created within the constructor of `MyStack`: an API and a stack output referencing the API. Go ahead and delete both.

Your first resource will be an identity pool. Use SST's `Auth` construct to create it.

```tsx
// Create the Identity Pool
const auth = new sst.Auth(this, `Auth`, {
    cognito: false,
    google: {
        clientId: process.env.GOOGLE_CLIENT_ID!,
    },
    identityPool: {
        allowUnauthenticatedIdentities: false,
        allowClassicFlow: true,
    },
});
```

You may be wondering why you set `cognito: false`. This is to keep the `Auth` construct from creating a user pool, since you won't need it. SST takes care of building a lot of behind-the-scenes resources that you’d otherwise have to create yourself. The current stack is creating an identity pool, authenticated role, unauthenticated role, and a role attachment to associate those roles with the identity pool.

## Google Sign-in Setup

Now that you have an identity pool created, you need to let it know what Google Cloud project to accept tokens from. Let's leave your editor and open a browser to [https://console.developers.google.com/](https://console.developers.google.com).

To get started, create a new project. Click the drop-down to the right of Google Cloud Platform to open the project selection dialog.

![Google Cloud header](https://i.imgur.com/oNnAadN.png)

In the project selection dialog, click **New Project**. Fill in the details on the page that opens, then click **Create**.

![New Project settings](https://i.imgur.com/Mazin19.png)

It'll take a minute or so until project creation is complete. You should see a notification on the bell icon when it's done, or you can open the project selection dialog to check its status.

## Create Credentials

Once the project is created, select it and open the **Credentials** page under **APIs & Services**. Alternatively, go to this URL: [https://console.cloud.google.com/apis/credentials/consent](https://console.cloud.google.com/apis/credentials/consent). Once the page is open, select **External** to let Google know this will be a publicly available app. Click **Create**.

Fill in the app information section however you like. The app domain is a bit trickier, since we don't have a website deployed yet. Just fill in some fake URLs using example.com.

![App information](https://i.imgur.com/hrKUQsy.png)

Before you can progress, Google wants to know what domains are authorized to use this client ID. Again, since we don't have an app deployed, just enter example.com. We'll come back and change this later.

Finally, enter an email address in developer contact information. Click **Save and Continue**.

Now we need to tell Google what data we'll be requesting access to. Click the **Add or Remove Scopes** button and select the `.../auth/userinfo.profile` scope. Click **Update**, then click **Save and Continue**.

Since we won't be submitting our app to Google for validation, we'll only be able to authenticate a preselected list of users. On the Test Users page, enter the email address that you're going to be signing in with (if it's different from the one you used to sign in to the developer console), then click **Save and Continue**.

![Test users](https://i.imgur.com/vYtl1Xg.png)

Now that the consent screen is set up, we're ready to create some credentials. Select the **Credentials** page from the list on the left. On the page that opens, click **Create Credentials**, then click on **OAuth client ID** from the drop-down menu.

![Create OAuth credentials](https://i.imgur.com/ppqSl6q.png)

Select **web application** from the **Application type** drop-down menu. In the Authorized JavaScript origins section, enter [localhost](http://localhost) and [localhost:3000](http://localhost:3000) so you can test your code locally.

![JavaScript origins](https://i.imgur.com/JffX2oW.png)

Once the JavaScript origins are added, click **Create**. You'll be taken back to the **Credentials** page. Here, a dialog will open showing your client ID and secret. Copy the client ID and close the dialog.

![Client created](https://i.imgur.com/MFNaEMx.png)

## Using Environment Variables

Now that you have a client ID, it needs to be given to the identity pool. Go back to your editor and create a file named `.env` in the root of your project. Add your Google client ID to it, like this:

```bash
GOOGLE_CLIENT_ID=something.apps.googleusercontent.com
```

When SST starts, it will load the environment variables defined in this `.env` file. Since you referenced `GOOGLE_CLIENT_ID` in your stack, it will be passed to the identity pool when you deploy.

Note: for security reasons, you should add `.env` to your `.gitignore` file.

## Create an Upload Bucket

Now that you can authenticate users for your photo upload app, you need to create a bucket they can store pictures in.

Open up `MyStack.ts` again and add the following code:

```tsx
const bucket = new sst.Bucket(this, `PhotoBucket`, {});
```

This will create the bucket. Now, you need to create some permissions to allow authenticated users to use the bucket. Add the following code to do that:

```tsx
auth.attachPermissionsForAuthUsers([
    new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        resources: [
            `${bucket.bucketArn}/private/\${cognito-identity.amazonaws.com:sub}/*`,
        ],
    }),
    new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: ["s3:ListBucket"],
        resources: [bucket.bucketArn],
        conditions: {
            StringLike: {
                s3prefix: [
                    "private/${cognito-identity.amazonaws.com:sub}/",
                    "private/${cognito-identity.amazonaws.com:sub}/*",
                ],
            },
        },
    }),
]);
```

Let's take a look at each of the policy statements added.

The first policy allows authenticated users to get, create, update, and delete objects. If you look at the resources section, you'll see a special ARN being built. It starts with the ARN of the bucket that you just created, but it adds a path restriction after that. This tells IAM that authenticated users are only allowed to act on objects in the private folder under the subfolder `${cognito-identity.amazonaws.com:sub}`, which is replaced with the `sub` field of the user's JWT token when the policy is evaluated.

The second policy restricts access to the same folder as the first, but also allows the user to list objects that belong to that folder and any subfolders. This time, the policy uses a condition to limit access. Since S3 is a key-value store, there aren't actually any folders. So you provide access to the bucket resource, then require the list request to have a prefix filter that matches the user's private folder.

You'll need to modify the bucket's access control list (ACL) to allow your role to access it:

```tsx
bucket.s3Bucket.grantReadWrite(auth.iamAuthRole);
```

## Adding Outputs

Now that you've created all the resources for the frontend, you need to get references to them. To do that, you'll add some outputs to the stack, Then, the values will be displayed in the terminal at the end of a deploy command.

Add the following code to get the identity pool ID and the bucket's name:

```tsx
this.addOutputs({
    identityPoolId: auth.cognitoCfnIdentityPool.ref,
    storageBucket: bucket.bucketName
});
```

Now, deploy the stack by running `yarn deploy` from the project root. It'll take about a minute, but you should see the stack's outputs:

```bash
✅  dev-google-sign-in-demo-google-sign-in-test

Stack dev-google-sign-in-demo-google-sign-in-test
  Status: deployed
  Outputs:
    storageBucket: dev-google-sign-in-demo-googl-photobucketbccc5a2d-1h2goxlpvit9p
    identityPoolId: us-east-1:9831b3a5-118f-484f-abde-fde63f0c1ab4

Done in 68.67s.
```

Copy the value of the outputs, you'll need them later.

## Build a Web App

Now you get to create the actual web app that will upload and display the user's images. Open a terminal in the root of your project, and run the following commands:

```bash
yarn create react-app website --template typescript
cd website
```

### Add the Amplify Framework

You're going to be using [AWS's Amplify Libraries](https://docs.amplify.aws/lib/q/platform/js). This will simplify your interactions with AWS by handling token refreshes and other things behind the scenes. From the `website` directory, install the `aws-amplify` library:

```bash
yarn add aws-amplify
```

Before you can use the libraries, you need to provide them with details about the resources they'll be using. Open the `src/index.ts` file, and add the following code just below the existing imports:

```tsx
import Amplify from "aws-amplify";
Amplify.configure({
  Auth: {
    identityPoolId: process.env.REACT_APP_AWS_IDENTITY_POOL_ID,
    region: "us-east-1",
    mandatorySignIn: true,
  },
  Storage: {
    AWSS3: {
      bucket: process.env.REACT_APP_STORAGE_BUCKET,
      region: "us-east-1",
    },
  },
  federationTarget: "COGNITO_USER_POOLS",
});
```

Next, create a `.env` in the website directory, and add the following variables based on your stack outputs:

```bash
REACT_APP_AWS_IDENTITY_POOL_ID=us-east-1:07396289-865e-4495-b84e-f8d4f06f92f4
REACT_APP_STORAGE_BUCKET=dev-google-sign-in-demo-google-photobucketbccc5a2d-s3sq987x9jqm
```

While you have the `.env` file open, add your Google client ID:

```bash
REACT_APP_GOOGLE_CLIENT_ID=something.apps.googleusercontent.com
```

Finally, there's a version mismatch between jest in the website project and the serverless stack. To get the website working, you'll need to add this last variable to the file:

```bash
SKIP_PREFLIGHT_CHECK=true
```

### Setup Authentication

Authenticating a user with an identity pool is a two-step process. First, your app will get a token from Google. Then, it will pass the token to the identity pool. To get the token from Google, we're going to use a helper library called `react-google-login`. Install the package in the website folder:

```bash
yarn add react-google-login
```

Next, you're going to create a context that will provide access to Google's sign in command and the currently authenticated user. Create the file `src/components/UserContext.tsx`, and add the following code:

```tsx
import { CognitoUser } from "@aws-amplify/auth";
import { Auth, Hub } from "aws-amplify";
import React from "react";
import { GoogleLoginResponse, GoogleLoginResponseOffline, useGoogleLogin } from 'react-google-login';

type UserContextValue = {
  user: { id: string; name: string; token: string; } | null;
  signIn: () => Promise<void>;
} | null;

const UserContext = React.createContext<UserContextValue>(null);

const getUser = async (): Promise<CognitoUser | null> => {
  try {
    const user = await Auth.currentAuthenticatedUser();

    return user;
  } catch (ex) {
    console.log(`Not signed in`, ex);
  }

  return null;
};

function isGoogleLoginResponse(value: any): value is GoogleLoginResponse {
  return value.getAuthResponse;
}

export const UserProvider: React.FC = ({ children }) => {
  const [user, setUser] = React.useState<CognitoUser | null>(null);
  const [isInitialized, setInitialized] = React.useState(false);

  const onSuccess = React.useCallback(async (response: GoogleLoginResponse | GoogleLoginResponseOffline) => {
    if (isGoogleLoginResponse(response)) {
      const { expires_at, id_token } = response.getAuthResponse();

      await Auth.federatedSignIn(
        "google",
        {
          token: id_token,
          expires_at,
        },
        response.profileObj
      );
    }
  }, []);

  const { signIn: googleSignIn, loaded: googleSignInLoaded } = useGoogleLogin({
    clientId: process.env.REACT_APP_GOOGLE_CLIENT_ID!,
    onSuccess,
  });

  React.useEffect(() => {
    setInitialized(googleSignInLoaded);
  }, [googleSignInLoaded]);

  React.useEffect(() => {
    getUser().then((user) => {
      setUser(user);
    });

    const authListener = ({ payload: { event, data } }: { payload: { event: string; data?: CognitoUser; } }) => {
      switch (event) {
        case "signIn":
        case "cognitoHostedUI":
          getUser().then(setUser);
          break;
        case "signOut":
          setUser(null)
          break;
        case "signIn_failure":
        case "cognitoHostedUI_failure":
          console.error(`Sign in failure`, data);
          break;
      }
    };

    Hub.listen("auth", authListener);

    return () => {
      Hub.remove("auth", authListener);
    };

  }, []);

  let value: UserContextValue = null;

  if (isInitialized) {
    value = {
      // @ts-ignore
      user: user,
      async signIn() {
        googleSignIn();
      }
    }
  }

  return <UserContext.Provider value={value} children={children} />;
};

export const useCurrentUser = () => React.useContext(UserContext);
```

This context provider will initialize the Google authentication library, passing in your client ID. The `signIn` method provided by the context will get a token from Google, then pass it into the Amplify authentication library.

Now we can keep track of when a user is signed in, we should display something to let the user know they're signed in. Edit your `App.tsx` to look like this:

```tsx
import React from 'react';
import { useCurrentUser } from './components/UserContext';

function App() {
  const user = useCurrentUser();
  const [userName, setUserName] = React.useState<string | null>(null);

  React.useEffect(() => {
    if (!user?.signIn) return;

    if (user.user) {
      setUserName(user.user.name);
      return;
    }

    user.signIn();
  }, [user]);

  return (
    <div className="App">
      {user?.user ? <div>Signed In as {userName}</div> : <div>Not Signed In!</div>}
    </div>
  );
}

export default App;
```

## Deploying the Web App

The SST library has a construct to help deploy our web app. It's called `StaticSite`, and it builds your web app, uploads it to S3, and creates a CloudFront distribution for it. Add it to your `MyStack.ts` file:

```tsx
const website = new sst.StaticSite(this, "ReactSite", {
    path: "website",
    buildOutput: "build",
    buildCommand: "yarn build",
    errorPage: sst.StaticSiteErrorOptions.REDIRECT_TO_INDEX_PAGE,
});
```

Don't forget to add the website's URL to your outputs:

```tsx
this.addOutputs({
    identityPoolId: auth.cognitoCfnIdentityPool.ref,
    storageBucket: bucket.bucketName,
    website: website.url,
});
```

Now you're ready to deploy the stack. From the root directory, run `yarn deploy`. Once deployment has finished, copy the website URL from the stack outputs. You'll need it in the next step.

### Configure Google's JavaScript Origins

You need to tell Google the URL of the website you just deployed. Go back to the Google developer console and edit the web client that you created. Add your website's URL to the list of authorized JavaScript origins, then click save.

![Add website JavaScript origin](https://i.imgur.com/KGjHNce.png)

## Testing the App

Now you should be ready to test your app. Paste the URL from your stack output into your browser. It will open a Google login pop-up that walks you through the authentication process. Once that's done, you should see a welcome message with your user ID.

## Using an IAM Token from Identity Pool

Now your users can sign in through Google login and you can get a token from your identity pool, you can use those credentials to interact with AWS resources. In this example, you're going to allow users to upload and view files in S3.

To get started building the image upload elements, install the [material-ui](https://material-ui.com/) libraries and a file picker library:

```bash
yarn add @material-ui/core @material-ui/icons use-file-picker
```

Next,  create a file called `pages/ImageList.tsx` and the authenticated layout:

```tsx
import React from "react";
import { Container, Grid, Card, CardMedia, CardHeader, Fab, makeStyles, createStyles, LinearProgress } from "@material-ui/core";
import { useFilePicker } from 'use-file-picker';
import UploadIcon from "@material-ui/icons/BackupRounded";

import { Storage } from "aws-amplify";

interface PathInfo {
  key: string;
  url?: string;
}

const useStyles = makeStyles(theme => createStyles({
  fab: {
    position: "absolute",
    bottom: theme.spacing(2),
    right: theme.spacing(2)
  },
  imagePreview: {
    aspectRatio: "1"
  }
}));

export const ImageList: React.FC = () => {
  const classes = useStyles();
  const [uploadProgress, setUploadProgress] = React.useState<number | null>(null);
  const [images, setImages] = React.useState<Array<PathInfo>>([]);

  const [showPicker, { plainFiles }] = useFilePicker({
    multiple: false,
    accept: ['.jpg', '.png'],
    readFilesContent: false
  });

  React.useEffect(() => {
    Storage.list(``, {
      level: "private",
    }).then((result: Array<{ key: string; }>) => {
      const keys = result.filter(x => Boolean(x.key));
      Promise.all(keys.map(async (key) => {
        const signedUrl = await Storage.get(key.key, {
          level: "private"
        });

        return {
          ...key,
          url: signedUrl,
        } as PathInfo;
      })).then(setImages);
    });
  }, []);

  React.useEffect(() => {
    const file = plainFiles?.[0];

    if (file) {
      Storage.put(file.name, file, {
        level: 'private',
        progressCallback(progress: { loaded: number; total: number }) {
          setUploadProgress(progress.loaded / progress.total);
        }
      }).then(() => setUploadProgress(null));
    }
  }, [plainFiles]);

  return <>
    <Container>
      {uploadProgress && <LinearProgress value={uploadProgress} />}
      <Grid container spacing={2}>
        {images.map((img) => <Grid item xs={12} sm={6} md={4}>
          <Card>
            <CardHeader title={img.key} />
            <CardMedia image={img.url} className={classes.imagePreview} />
          </Card>
        </Grid>)}
      </Grid>
    </Container>

    {uploadProgress === null && <Fab className={classes.fab} color="primary" onClick={showPicker}>
      <UploadIcon />
    </Fab>}
  </>;
}
```

You need to show this control when an authenticated user is signed in. Update your `App.tsx` file to do that:

```tsx
import React from 'react';
import { useCurrentUser } from './components/UserContext';
import { ImageList } from './pages/ImageList';

function App() {
  const user = useCurrentUser();

  React.useEffect(() => {
    if (!user?.signIn || user.user) return;

    user.signIn();
  }, [user]);

  if (user?.user) {
    return <ImageList />
  }

  return (
    <div className="App">
      <div>Not Signed In!</div>
    </div>
  );
}

export default App;
```

Finally, you need to add a CORS rule to the image bucket so you can access it from your web app. Add the following code directly after the website definition to create the rule:

```tsx
bucket.s3Bucket.addCorsRule({
    allowedOrigins: [website.url],
    allowedMethods: [
        s3.HttpMethods.GET,
        s3.HttpMethods.POST,
        s3.HttpMethods.HEAD,
        s3.HttpMethods.PUT,
        s3.HttpMethods.DELETE,
    ],
    allowedHeaders: ["*"],
    exposedHeaders: [
        "x-amz-server-side-encryption",
        "x-amz-request-id",
        "x-amz-id-2",
        "ETag",
    ],
    maxAge: 3000,
});
```

Now, deploy the stack again. You’ll see an upload file icon once you're signed in. Click it, select an image, then Amplify will use your identity pool credential to upload the selected image to S3.

Refresh the page again, and you'll see the image you just uploaded.

![App preview](https://i.imgur.com/tDcugXp.png)
