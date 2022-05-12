---
layout: example
title: How to create a Flutter app with serverless
short_title: Flutter
date: 2021-10-25 00:00:00
lang: en
index: 2
type: mobileapp
description: In this example we will look at how to use Flutter with a serverless API to create a simple click counter app. We'll be using the Serverless Stack Framework (SST).
short_desc: Native app with Flutter and a serverless API.
repo: flutter-app
ref: how-to-create-a-flutter-app-with-serverless
comments_id: how-to-create-an-flutter-app-with-serverless/2516
---

In this example we will look at how to use [Flutter](https://flutter.dev) with a [serverless]({% link _chapters/what-is-serverless.md %}) API to create a simple click counter app. We'll be using the [Serverless Stack Framework (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- Flutter installed
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npm init sst -- typescript-starter flutter-app
$ cd flutter-app
```

By default our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "flutter-app",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of a couple of parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `backend/` — App Code

   The code that's run when your API is invoked is placed in the `backend/` directory of your project.

3. `frontend/` — Flutter App

   The code for our frontend Flutter app.

## Create our infrastructure

Our app is made up of a simple API and a Flutter app. The API will be talking to a database to store the number of clicks. We'll start by creating the database.

### Adding the table

We'll be using [Amazon DynamoDB](https://aws.amazon.com/dynamodb/); a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import {
  Api,
  ReactStaticSite,
  StackContext,
  Table,
} from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create the table
  const table = new Table(stack, "Counter", {
    fields: {
      counter: "string",
    },
    primaryIndex: { partitionKey: "counter" },
  });
}
```

This creates a serverless DynamoDB table using the SST [`Table`]({{ site.docs_url }}/constructs/Table) construct. It has a primary key called `counter`. Our table is going to look something like this:

| counter | tally |
| ------- | ----- |
| clicks  | 123   |

### Creating our API

Now let's add the API.

{%change%} Add this below the `Table` definition in `stacks/MyStack.ts`.

```ts
// Create the HTTP API
const api = new Api(stack, "Api", {
  defaults: {
    function: {
      // Allow the API to access the table
      permissions: [table],
      // Pass in the table name to our API
      environment: {
        tableName: table.tableName,
      },
    },
  },
  routes: {
    "POST /": "functions/lambda.handler",
  },
});

// Show the URLs in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

We are using the SST [`Api`]({{ site.docs_url }}/constructs/Api) construct to create our API. It simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `handler` in `backend/functions/lambda.ts` will get invoked.

We also pass in the name of our DynamoDB table to our API as an environment variable called `tableName`. And we allow our API to access (read and write) the table instance we just created.

### Reading from our table

Our API is powered by a Lambda function. In the function we'll read from our DynamoDB table.

{%change%} Replace `backend/functions/lambda.ts` with the following.

```ts
import { DynamoDB } from "aws-sdk";

const dynamoDb = new DynamoDB.DocumentClient();

export async function handler() {
  const getParams = {
    // Get the table name from the environment variable
    TableName: process.env.tableName,
    // Get the row where the counter is called "clicks"
    Key: {
      counter: "clicks",
    },
  };
  const results = await dynamoDb.get(getParams).promise();

  // If there is a row, then get the value of the
  // column called "tally"
  let count = results.Item ? results.Item.tally : 0;

  return {
    statusCode: 200,
    body: count,
  };
}
```

We make a `get` call to our DynamoDB table and get the value of a row where the `counter` column has the value `clicks`. Since we haven't written to this column yet, we are going to just return `0`.

{%change%} Let's install the `aws-sdk` package in the `backend/` folder.

```bash
$ npm install aws-sdk
```

And let's test what we have so far.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm start
```

The first time you run this command it'll take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-flutter-app-my-stack: deploying...

 ✅  dev-flutter-app-my-stack


Stack dev-flutter-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://sez1p3dsia.execute-api.ap-south-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created.

Let's test our endpoint with the [SST Console](https://console.serverless-stack.com). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Go to the **API** tab and click **Send** button to send a `POST` request.

Note, The [API explorer]({{ site.docs_url }}/console#api) lets you make HTTP requests to any of the routes in your `Api` construct. Set the headers, query params, request body, and view the function logs with the response.

![API explorer invocation response](/assets/examples/angular-app/api-explorer-invocation-response.png)

You should see a `0` in the response body.

## Setting up our Flutter app

We are now ready to use the API we just created. Let's use [Flutter CLI](https://flutter.dev/docs/get-started/install) to setup our Flutter app.

If you don't have the Flutter CLI installed on your machine, [head over here to install it](https://flutter.dev/docs/get-started/install).

{%change%} Run the following in the project root.

```bash
$ flutter create frontend
$ cd frontend
```

This sets up our Flutter app in the `frontend/` directory.

We also need to load the environment variables from our SST app. To do this, we'll be using the [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) package.

{%change%} Install the `flutter_dotenv` package by running the following in the `frontend/` directory.

```bash
$ flutter pub add flutter_dotenv
```

{%change%} Create a `.env` file inside `frontend/` and create two variables to hold the development and production API endpoints. Replace the `DEV_API_URL` with the one from the steps above.

```
DEV_API_URL=https://sez1p3dsia.execute-api.us-east-1.amazonaws.com
PROD_API_URL=OUTPUT_FROM_SST_DEPLOY
```

We'll add the `PROD_API_URL` later in this example.

{%change%} Add the `.env` file to your assets bundle in `pubspec.yaml` by uncommenting the `assets` section under `flutter`.

```yaml
flutter:
  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  assets:
    - .env
```

Ensure that the path corresponds to the location of the `.env` file!

We also need the `http` package to call the endpoint.

{%change%} In the `frontend/` directory run.

```bash
$ flutter pub add http
```

Let's start our Flutter development environment.

{%change%} In the `frontend/` directory run.

```bash
$ flutter run
```

This will open up an emulator and load the app.

### Add the click button

We are now ready to add the UI for our app and connect it to our serverless API.

{%change%} Replace `frontend/lib/main.dart` with.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  update() async {
    Uri uri = kReleaseMode ? Uri.parse(dotenv.env['PROD_API_URL']!) : Uri.parse(dotenv.env['DEV_API_URL']!);
    var result = await http.post(uri);
    setState(() {
      counter = int.parse(result.body);
    });
  }

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Counter App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Counter App"),
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("This button is pressed $counter times"),
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      update();
                    });
                  },
                  child: Text(
                    "Click Me",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blue.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

Here we are adding a simple button that when clicked, makes a request to our API. We are getting the API endpoint from the environment variable depending on the build mode.

The response from our API is then stored in our app's state. We use that to display the count of the number of times the button has been clicked.

Now if you head over to your emulator, your Flutter app should look something like this.

![Click counter UI in Flutter app](/assets/examples/flutter-app/click-counter-ui-in-flutter-app.png){: width="432" }

Of course if you click on the button multiple times, the count doesn't change. That's because we are not updating the count in our API. We'll do that next.

## Making changes

Let's update our table with the clicks.

{%change%} Add this above the `return` statement in `backend/functions/lambda.ts`.

```ts
const putParams = {
  TableName: process.env.tableName,
  Key: {
    counter: "clicks",
  },
  // Update the "tally" column
  UpdateExpression: "SET tally = :count",
  ExpressionAttributeValues: {
    // Increase the count
    ":count": ++count,
  },
};
await dynamoDb.update(putParams).promise();
```

Here we are updating the `clicks` row's `tally` column with the increased count.

And if you head over to your emulator and click the button again, you should see the count increase!

![Click counter updating in Flutter app](/assets/examples/flutter-app/click-counter-updating-in-flutter-app.png){: width="432" }

Also let's go to the **DynamoDB** tab in the SST Console and check that the value has been updated in the table.

Note, The [DynamoDB explorer]({{ site.docs_url }}/console#dynamodb) allows you to query the DynamoDB tables in the [`Table`]({{ site.docs_url }}/constructs/Table) constructs in your app. You can scan the table, query specific keys, create and edit items.

![DynamoDB table view of counter table](/assets/examples/angular-app/dynamo-table-view-of-counter-table.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npm deploy --stage prod
```

This allows us to separate our environments, so when we are working locally it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-flutter-app-my-stack


Stack prod-flutter-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://k40qchmtvf.execute-api.ap-south-1.amazonaws.com
```

{%change%} Add the above endpoint to the `.env` file in `frontend/.env` as a production API endpoint.

```
DEV_API_URL=https://sez1p3dsia.execute-api.us-east-1.amazonaws.com
PROD_API_URL=https://k40qchmtvf.execute-api.us-east-1.amazonaws.com
```

Run the below command to open the SST Console in **prod** stage to test the production endpoint.

```bash
npm run console --stage prod
```

Go to the **API** tab and click **Send** button to send a `POST` request.

![API explorer prod invocation response](/assets/examples/angular-app/api-explorer-prod-invocation-response.png)

Now we are ready to ship our app!

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npm run remove
$ npm run remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless click counter app in Flutter. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
