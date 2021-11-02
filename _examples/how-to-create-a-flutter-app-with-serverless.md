---
layout: example
title: How to create an flutter app with serverless
date: 2021-10-25 00:00:00
lang: en
description: In this example we will look at how to use flutter with a serverless API to create a simple click counter app. We'll be using the Serverless Stack Framework (SST).
repo: flutter-app
ref: how-to-create-a-flutter-app-with-serverless
comments_id: how-to-create-a-flutter-app-with-serverless/xxxx
---

In this example we will look at how to use [flutter](https://flutter.dev) with a [serverless]({% link _chapters/what-is-serverless.md %}) API to create a simple click counter app. We'll be using the [Serverless Stack Framework (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- Flutter installed
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-serverless-stack@latest flutter-app
$ cd flutter-app
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "flutter-app",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of a couple of parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

3. `frontend/` — flutter App

   The code for our frontend flutter app.

## Create our infrastructure

Our app is made up of a simple API and a flutter app. The API will be talking to a database to store the number of clicks. We'll start by creating the database.

### Adding the table

We'll be using [Amazon DynamoDB](https://aws.amazon.com/dynamodb/); a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.js` with the following.

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create the table
    const table = new sst.Table(this, "Counter", {
      fields: {
        counter: sst.TableFieldType.STRING,
      },
      primaryIndex: { partitionKey: "counter" },
    });
  }
}
```

This creates a serverless DynamoDB table using the SST [`Table`](https://docs.serverless-stack.com/constructs/Table) construct. It has a primary key called `counter`. Our table is going to look something like this:

| counter | tally |
| ------- | ----- |
| clicks  | 123   |

### Creating our API

Now let's add the API.

{%change%} Add this below the `sst.Table` definition in `stacks/MyStack.js`.

```js
// Create the HTTP API
const api = new sst.Api(this, "Api", {
  defaultFunctionProps: {
    // Pass in the table name to our API
    environment: {
      tableName: table.dynamodbTable.tableName,
    },
  },
  routes: {
    "POST /": "src/lambda.main",
  },
});

// Allow the API to access the table
api.attachPermissions([table]);

// Show the API endpoint in the output
this.addOutputs({
  ApiEndpoint: api.url,
});
```

We are using the SST [`Api`](https://docs.serverless-stack.com/constructs/Api) construct to create our API. It simply has one endpoint (the root). When we make a `POST` request to this endpoint the Lambda function called `main` in `src/lambda.js` will get invoked.

We also pass in the name of our DynamoDB table to our API as an environment variable called `tableName`. And we allow our API to access (read and write) the table instance we just created.

### Reading from our table

Our API is powered by a Lambda function. In the function we'll read from our DynamoDB table.

{%change%} Replace `src/lambda.js` with the following.

```js
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function main() {
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

{%change%} Let's install the `aws-sdk`.

```bash
$ npm install aws-sdk
```

And let's test what we have so far.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npx sst start
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

Let's test our endpoint. Run the following in your terminal.

```bash
$ curl -X POST https://sez1p3dsia.execute-api.ap-south-1.amazonaws.com
```

You should see a `0` printed out.

## Setting up our flutter app

We are now ready to use the API we just created. Let's use [flutter-cli](https://flutter.dev/docs/get-started/install) to setup our flutter app.

{%change%} Run the following in the project root.

```bash
$ flutter create frontend
$ cd frontend
```

This sets up our flutter app in the `frontend/` directory.

We also need to load the environment variables from our SST app. To do this, we'll be using the [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) package.

{%change%} Install the `flutter_dotenv` package by running the following in the `frontend/` directory.

```bash
$ flutter pub add flutter_dotenv
```

Create a `.env` file in root and create a variable to hold the API endpoint

```
API_URL=https://sez1p3dsia.execute-api.us-east-1.amazonaws.com
```

Add the `.env` file to your assets bundle in `pubspec.yaml`. Ensure that the path corresponds to the location of the .env file!

```yaml
assets:
  - .env
```

Let's start our flutter development environment.

{%change%} In the `frontend/` directory run.

```bash
$ flutter run
```

This will open up an emulator and the app will be loaded.

If the emulator isn't opened, open the emulator manually and check whether the device is detected or not using the below command

```bash
flutter devices
```

### Add the click button

We are now ready to add the UI for our app and connect it to our serverless API.

{%change%} Replace `frontend/lib/main.dart` with.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
    Uri uri = Uri.parse(dotenv.env['API_URL']!);
    var result = await http.post(uri);
    print(result.body);
    setState(() {
      counter = int.parse(result.body);
    });
    print(counter);
  }

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter serverless-stack demo"),
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

Here we are adding a simple button that when clicked, makes a request to our API. We are getting the API endpoint from the environment variable, `dotenv.env['API_URL']`.

The response from our API is then stored in our app's state. We use that to display the count of the number of times the button has been clicked.

Now if you head over to your emulator, your flutter app should look something like this.

![Click counter UI in flutter app](/assets/examples/flutter-app/phone1.jpg)

Of course if you click on the button multiple times, the count doesn't change. That's because we are not updating the count in our API. We'll do that next.

## Making changes

Let's update our table with the clicks.

{%change%} Add this above the `return` statement in `src/lambda.js`.

```js
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

![Click counter updating in flutter app](/assets/examples/flutter-app/phone2.jpg)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the app for our users.

Once deployed, you should see something like this.

```bash
 ✅  prod-flutter-app-my-stack


Stack prod-flutter-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://k40qchmtvf.execute-api.ap-south-1.amazonaws.com
```

Add the above endpoint to the `.env` file in `frontend/.env` as a production API endpoint

```
API_URL=https://hfv2gyuwdh.execute-api.us-east-1.amazonaws.com
```

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless click counter in flutter. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
