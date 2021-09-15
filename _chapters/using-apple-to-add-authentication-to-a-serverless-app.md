---
layout: post
title: Using Apple to add authentication to a serverless app
date: 2021-08-05 00:00:00
lang: en
description: 
ref: using-apple-to-add-authentication-to-a-serverless-app
comments_id: 
---

{% capture repo_url %}{{ site.sst_github_repo }}{{ site.sst_github_examples_prefix }}react-app-auth-apple{% endcapture %}

To get started, create a new [Serverless Stack (SST)](https://docs.serverless-stack.com) project by running the following command:

```bash
yarn create serverless-stack apple-sign-in-demo --language typescript
```

This will make sure the `serverless-stack` package is globally installed, then execute it. You will end up with a new folder called `apple-sign-in-demo` with your project in it. Now `cd` into that folder and open it in your favorite editor.

```
bash
cd apple-sign-in-demo
```

Looking at your project, you should see the following structure:

![Project Structure](https://i.imgur.com/V0hPCqK.png)

If you open the `lib/index.ts` file, you’ll see a `main` function that gets called whenever you deploy the stack. If you’ve used AWS's Cloud Development Kit, or `CDK`, this will look somewhat familiar, except that the `app` is passed into the main function instead of you needing to create it yourself. Currently the main function should look like this:

```
tsx
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

You’ll see the application creates one stack, `MyStack`. Let’s open that file and take a look. You should see two resources being created within the constructor of `MyStack`, an API and a stack output referencing the API. Go ahead and delete both.

Your first resource will be an Identity Pool. Use SST’s `Auth` construct to create it.

```
tsx
// Create the Identity Pool
const auth = new sst.Auth(this, `Auth`, {
    cognito: false,
    apple: {
        servicesId: process.env.APPLE_SERVICES_ID!,
    },
    identityPool: {
        allowUnauthenticatedIdentities: false,
        allowClassicFlow: true,
    },
});
```

You may be wondering why you set `cognito: false`. This is to keep the `Auth` construct from creating a User Pool, since you won’t need it. SST takes care of building a lot of resources behind the scenes that you would otherwise have to create yourself. The current stack is creating an Identity Pool, Authenticated Role, Unauthenticated Role, and a role attachment to associate those roles with the Identity Pool.

## Apple Sign In Setup

Now that you have an Identity Pool created, you need to let it know what Apple Sign In project to accept tokens from. Let’s leave your editor and open a browser to sign into [Apple Developer](https://developer.apple.com/account/).

### Create an App ID

Click on **Certificates, Identifiers & Profiles**. On the new page, select **Identifiers**. You need to create an App ID that you can reference later. Click on the **+** next to **Identifiers**.

![Identifiers List](https://i.imgur.com/yuCzjqC.png)

On the page that opens, select **App IDs**, then click **Continue**. Make sure **App** is selected on the next page and click **Continue** again.

Now you’ll need to enter a description and bundle ID. Make sure you select **Explicit** next to the bundle ID and enter a reverse-domain identifier. I’ll be using `com.thebenforce.demoapp` for mine.

![Register an App ID](https://i.imgur.com/uxDiWQK.png)

Next, you need to tell Apple that you’d like to use Sign in with Apple. Scroll down the list of capabilities and you should see an item appropriately called **Sign in with Apple**. Make sure it’s checked, then click **Continue** and **Register**. You should be taken back to the list of registered identifiers, which now contains your new App ID.

![New App Identifier](https://i.imgur.com/UrclybY.png)

### Create a Services ID

Now that you have an App ID with Apple Sign in enabled, let’s create the actual Services ID that you’ll be referencing. Click the **+** next to **Identifiers** again. This time make sure **Services IDs** is selected, then click **Continue**.

![Register a Services ID](https://i.imgur.com/47Encln.png)

Enter a description and identifier. I’ll be using `com.thebenforce.weblogin` in this tutorial. Click **Continue**, then **Register**.

## Using Environment Variables

Now that you have a Services ID, it needs to be given to the Identity Pool. Go back to your editor and create a file named `.env` in the root of your project. Add your Apple Services ID to it like this:

```
tsx
APPLE_SERVICES_ID=com.thebenforce.weblogin
```

When SST starts, it will load the environment variables defined in this `.env` file. Since you referenced `APPLE_SERVICES_ID` in your stack, it will be passed to the Identity Pool when you deploy.

*Note: for security reasons you should add `.env` to your `.gitignore` file.*

## Create an Upload Bucket

Now that you can authenticate users for your photo upload app, you need to create a bucket they can store pictures in.

Open up `MyStack.ts` again and add the following code.

```
tsx
const bucket = new sst.Bucket(this, `PhotoBucket`, {});
```

This will create the actual bucket. Now you need to create some permissions to allow authenticated users to use the bucket. Add the following code to do that.

```
tsx
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

Let’s take a look at each of the policy statements added.

The first policy gives authenticated users the ability to get, update/create, and delete objects. If you look at the resources section, though, you’ll see a special Amazon Resource Name (ARN) being built. It starts with the ARN of the bucket that you just created, but it adds a path restriction after that. It tells IAM that authenticated users are only allowed to act on objects in the private folder under the subfolder `${cognito-identity.amazonaws.com:sub}`, which is replaced with the `sub` field of the user’s JWT token when the policy is evaluated.

The second policy restricts access to the same folder as the first, but this time it allows the user to list objects that belong to that folder and any subfolders. The policy uses a condition to limit access. Since S3 is a key/value store, there aren’t actually any folders. So you provide access to the bucket resource, then require the list request to have a prefix filter that matches the user’s private folder.

You’ll need to modify the bucket’s access control list (ACL) to allow your role to access it.

```
tsx
bucket.s3Bucket.grantReadWrite(auth.iamAuthRole);
```

## Adding Outputs

Now that you’ve created all the resources that the frontend will be using, you need to get references to them. To do that, you’ll add some outputs to the stack. The values will be displayed in the terminal at the end of a deploy command.

Add the following code to get the Identity Pool ID and the bucket’s name.

```
tsx
this.addOutputs({
    identityPoolId: auth.cognitoCfnIdentityPool.ref,
    storageBucket: bucket.bucketName
});
```

Now deploy the stack by running `yarn deploy` from the project root. It’ll take about a minute, but at the end of the deployment you should see the stack’s outputs.

```
bash
✅  dev-apple-sign-in-demo-apple-sign-in-test

Stack dev-apple-sign-in-demo-apple-sign-in-test
  Status: deployed
  Outputs:
    storageBucket: dev-apple-sign-in-demo-apple-photobucketbccc5a2d-s3sq987x9jqm
    identityPoolId: us-east-1:07396289-865e-4495-b84e-f8d4f06f92f4

Done in 70.85s.
```

Copy the value of the outputs. You’ll need them later.

## Build a Web App

Now you get to create the actual web app that will upload and display the user’s images. Open a terminal in the root of your project and run the following commands.

```
bash
yarn create react-app website --template typescript
cd website
```

### Add the Amplify Framework

You’re going to be using [AWS Amplify Libraries](https://docs.amplify.aws/lib/q/platform/js). They’ll simplify your interactions with AWS by handling token refreshes and a few other things behind the scenes. From the `website` directory, install the `aws-amplify` library.

```
bash
yarn add aws-amplify
```

Before you can use the libraries, you need to provide them with details about the resources they’ll be using. Open the `src/index.ts` file and add the following code just below the existing imports.

```
tsx
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

Next, create a `.env` in the website directory and add the following variables based on your stack outputs.

```
bash
REACT_APP_AWS_IDENTITY_POOL_ID=us-east-1:07396289-865e-4495-b84e-f8d4f06f92f4
REACT_APP_STORAGE_BUCKET=dev-apple-sign-in-demo-apple-photobucketbccc5a2d-s3sq987x9jqm
```

While you have the `.env` file open, add your Apple Services ID.

```
bash
REACT_APP_APPLE_CLIENT_ID=com.thebenforce.weblogin
```

And finally, there is a version mismatch between Jest in the website project and the Serverless Stack. To get the website working, you’ll need to add this last variable to the file.

```
bash
SKIP_PREFLIGHT_CHECK=true
```

### Setup Authentication

Authenticating a user with an Identity Pool is a two-step process. First, your app will get a token from Apple. Then it will pass the token to the Identity Pool.

To get the token from Apple, you need to use their authentication library. Unfortunately it isn’t provided as a module on npm, so you’ll need to add the following script tag to the body of your `public/index.html` file.

```
html
<script type="text/javascript" src="https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js"></script>
```

This will add the latest version of Apple’s authentication library as of this writing. To get the most up-to-date version, check their [developer documentation](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/configuring_your_webpage_for_sign_in_with_apple).

To make things a little easier to work with, install the type definitions. From the website directory run:

```
bash
yarn add -D @types/apple-signin-api
```

Next you’re going to create a context that will provide access to Apple’s sign-in command and the currently authenticated user. Create the file `src/components/UserContext.tsx` and add the following code.

```
tsx
import React from "react";
import { Auth, Hub } from "aws-amplify";
import { CognitoUser } from "@aws-amplify/auth";
import { inspect } from "util";
import jwtDecode from "jwt-decode";

interface TokenValues {
  exp: number;
  sub: string;
  iss: string;
}

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

export const UserProvider: React.FC = ({ children }) => {
  const [user, setUser] = React.useState<CognitoUser | null>(null);
  const [isInitialized, setInitialized] = React.useState(false);

  React.useEffect(() => {
    getUser().then((user) => {
      setUser(user);

      AppleID.auth.init({
        clientId: process.env.REACT_APP_APPLE_CLIENT_ID!,
        scope: "name email",
        redirectURI: window.location.origin,
        state: "{}",
        usePopup: true,
      });

      setInitialized(true);
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
        const {
          authorization: { id_token },
        } = await AppleID.auth.signIn();

        const tokenData = jwtDecode<TokenValues>(id_token);

        await Auth.federatedSignIn(
          "appleid.apple.com",
          {
            token: id_token,
            expires_at: tokenData.exp,
          },
          {
            name: tokenData.sub,
          }
        );
      }
    }
  }

  return <UserContext.Provider value={value} children={children} />;
};

export const useCurrentUser = () => React.useContext(UserContext);
```

This context provider will initialize the Apple Auth library, passing in your client ID and providing a redirect back to the site’s root. The `signIn` method provided by the context will get a token from Apple, decode it, then pass it into the Amplify Auth library.

Now that we can keep track of when a user is signed in, we should display something to let the user know they’re signed in. Edit your `App.tsx` to look like this.

```
tsx
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

The SST library has a construct to help deploy our web app. It’s called `StaticSite`, and it builds your web app, uploads it to S3, and creates a CloudFront distribution for it. Add it to your `MyStack.ts` file.

```
tsx
const website = new sst.StaticSite(this, "ReactSite", {
    path: "website",
    buildOutput: "build",
    buildCommand: "yarn build",
    errorPage: sst.StaticSiteErrorOptions.REDIRECT_TO_INDEX_PAGE,
});
```

Don't forget to add the website’s URL to your outputs.

```
tsx
this.addOutputs({
    identityPoolId: auth.cognitoCfnIdentityPool.ref,
    storageBucket: bucket.bucketName,
    website: website.url,
});
```

Now you’re ready to deploy the stack. From the root directory just run `yarn deploy`. Once deployment has finished, copy the website URL from the stack outputs. You’ll need it in the next step.

### Configure Apple Services ID URLs

You need to tell Apple the URL of the website you just deployed. Go back to Apple’s developer console and edit the Services ID that you created. Click the **Configure** button to the right of **Sign in with Apple** on the Edit Service ID page.

![Edit Service Identifier](https://i.imgur.com/zMswnzS.png)

You’ll see a dialog open that allows you to edit the website URLs that are allowed to use this service. Click the **+** to the right of **Website URLs** to add a new one.

![Web Authentication Configuration](https://i.imgur.com/naEfd8B.png)

The dialog will change to show two textboxes. The first one is where you define the domains allowed to use this service. Add the URL that you copied from the stack output, but delete the `https` part. Next paste the website URL in the **Return URLs** box and click **Next**.

![Register Site URL](https://i.imgur.com/20lY61r.png)

Once you click **Next**, the dialog will change back to how it was originally. Click **Done** to close the dialog.

TODO: SHOW SCREENSHOTS WITH CONTINUE AND SAVE. DOESN'T WORK WITHOUT IT

Click **Continue** on the Edit Services ID page. You’ll see a summary of the Services ID displayed. Click **Save**.

![Services ID Summary](https://i.imgur.com/0X9tuz6.png)

## Testing the App

Now you should be ready to test your app. Paste the URL from your stack output into your browser and it will open an Apple login popup that takes you through the authentication process. Once that’s done, you should see a welcome message with your user ID.

## Using an IAM Token from Identity Pool

Now that your users can sign in through Apple login and you can get a token from your Identity Pool, you can use those credentials to interact with AWS resources. In our example, you’re going to allow users to upload and view files in S3.

To get started building the image upload elements, install the [Material-UI](https://material-ui.com/) libraries and a FilePicker library.

```
bash
yarn add @material-ui/core @material-ui/icons use-file-picker
```

Now create a file called `pages/ImageList.tsx` and create the authenticated layout.

```
tsx
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

You need to show this control when an authenticated user is signed in. Update your `App.tsx` file to do that.

```
tsx
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

One last thing: you need to add a cross-origin resource sharing (CORS) rule to the image bucket so that you can access it from your web app. Add the following code right after the website definition to create the rule.

```
tsx
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

Now deploy the stack again and you will see an upload file icon once you’ve signed in. Click it and select an image. Amplify will use your Identity Pool credential to upload the selected image to S3.

Refresh the page again and you’ll see the image you just uploaded.

![App Preview](https://i.imgur.com/10M5Zzp.png)
