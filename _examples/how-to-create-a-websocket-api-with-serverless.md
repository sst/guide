---
layout: example
title: How to create a WebSocket API with serverless
short_title: WebSocket API
date: 2021-02-04 00:00:00
lang: en
index: 2
type: api
description: In this example we will look at how to create a serverless WebSocket API on AWS using SST. We'll be using the WebSocketApi construct to define the routes of our API.
short_desc: Building a simple WebSocket API.
repo: websocket
ref: how-to-create-a-websocket-api-with-serverless
comments_id: how-to-create-a-websocket-api-with-serverless/2397
---

In this example we will look at how to create a serverless WebSocket API on AWS using [SST]({{ site.sst_github_repo }}). You'll be able to connect to the WebSocket API and send messages to all the connected clients in real time.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=minimal/typescript-starter websocket
$ cd websocket
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "websocket",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `services/` — App Code

   The code that's run when your API is invoked is placed in the `services/` directory of your project.

## Storing connections

We are going to use [Amazon DynamoDB](https://aws.amazon.com/dynamodb/) to store the connection ids from all the clients connected to our WebSocket API. DynamoDB is a reliable and highly-performant NoSQL database that can be configured as a true serverless database. Meaning that it'll scale up and down automatically. And you won't get charged if you are not using it.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { StackContext, Table, WebSocketApi } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create the table
  const table = new Table(stack, "Connections", {
    fields: {
      id: "string",
    },
    primaryIndex: { partitionKey: "id" },
  });
}
```

This creates a serverless DynamoDB table using [`Table`]({{ site.docs_url }}/constructs/Table). It has a primary key called `id`. Our table is going to look something like this:

| id       |
| -------- |
| abcd1234 |

Where the `id` is the connection id as a string.

## Setting up the WebSocket API

Now let's add the WebSocket API.

{%change%} Add this below the `Table` definition in `stacks/MyStack.ts`.

```ts
// Create the WebSocket API
const api = new WebSocketApi(stack, "Api", {
  defaults: {
    function: {
      environment: {
        tableName: table.tableName,
      },
    },
  },
  routes: {
    $connect: "functions/connect.handler",
    $disconnect: "functions/disconnect.handler",
    sendmessage: "functions/sendMessage.handler",
  },
});

// Allow the API to access the table
api.attachPermissions([table]);

// Show the API endpoint in the output
stack.addOutputs({
  ApiEndpoint: api.url,
});
```

We are creating a WebSocket API using the [`WebSocketApi`]({{ site.docs_url }}/constructs/WebSocketApi) construct. It has a couple of routes; the `$connect` and `$disconnect` handles the requests when a client connects or disconnects from our WebSocket API. The `sendmessage` route handles the request when a client wants to send a message to all the connected clients.

We also pass in the name of our DynamoDB table to our API as an environment variable called `tableName`. And we allow our API to access (read and write) the table instance we just created.

## Connecting clients

Now in our functions, let's first handle the case when a client connects to our WebSocket API.

{%change%} Add the following to `services/functions/connect.ts`.

```ts
import { DynamoDB } from "aws-sdk";
import { APIGatewayProxyHandler } from "aws-lambda";

const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandler = async (event) => {
  const params = {
    TableName: process.env.tableName,
    Item: {
      id: event.requestContext.connectionId,
    },
  };

  await dynamoDb.put(params).promise();

  return { statusCode: 200, body: "Connected" };
};
```

Here when a new client connects, we grab the connection id from `event.requestContext.connectionId` and store it in our table.

{%change%} We are using the `aws-sdk`, so let's install it in the `services/` folder.

```bash
$ npm install aws-sdk
```

## Disconnecting clients

Similarly, we'll remove the connection id from the table when a client disconnects.

{%change%} Add the following to `services/functions/disconnect.ts`.

```ts
import { DynamoDB } from "aws-sdk";
import { APIGatewayProxyHandler } from "aws-lambda";

const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandler = async (event) => {
  const params = {
    TableName: process.env.tableName,
    Key: {
      id: event.requestContext.connectionId,
    },
  };

  await dynamoDb.delete(params).promise();

  return { statusCode: 200, body: "Disconnected" };
};
```

Now before handling the `sendmessage` route, let's do a quick test. We'll leave a placeholder function there for now.

{%change%} Add this to `services/functions/sendMessage.ts`.

```ts
import { APIGatewayProxyHandler } from "aws-lambda";

export const handler: APIGatewayProxyHandler = async (event) => {
  return { statusCode: 200, body: "Message sent" };
};
```

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
manitej-websocket-my-stack: deploying...

 ✅  manitej-websocket-my-stack


Stack manitej-websocket-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: wss://oivzpnqnb6.execute-api.us-east-1.amazonaws.com/manitej
```

The `ApiEndpoint` is the WebSocket API we just created. Let's test our endpoint.

Head over to [**WebSocket Echo Test**](https://www.piesocket.com/websocket-tester) to create a WebSocket client that'll connect to our API.

Enter the `ApiEndpoint` from above as the **url** field and hit **Connect**.

![Connect to serverless WebSocket API](/assets/examples/websocket/connect-to-serverless-websocket-api.png)

You should see `CONNECTED` being printed out in the **Log**.

![Serverless WebSocket API response](/assets/examples/websocket/serverless-websocket-api-response.png)

Whenever a new client is connected to the API, we will store the connection ID in the DynamoDB **Connections** table.

Let's go to the **DynamoDB** tab in the SST Console and check that the value has been created in the table.

Note, The [DynamoDB explorer]({{ site.docs_url }}/console#dynamodb) allows you to query the DynamoDB tables in the [`Table`]({{ site.docs_url }}/constructs/Table) constructs in your app. You can scan the table, query specific keys, create and edit items.

![DynamoDB table view of connections table](/assets/examples/websocket/dynamo-table-view-of-connections-table.png)

You should see a random connection ID created in the table.

## Sending messages

Now let's update our function to send messages.

{%change%} Replace your `services/functions/sendMessage.ts` with:

```ts
import { DynamoDB, ApiGatewayManagementApi } from "aws-sdk";
import { APIGatewayProxyHandler } from "aws-lambda";

const TableName = process.env.tableName;
const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandler = async (event) => {
  const messageData = JSON.parse(event.body).data;
  const { stage, domainName } = event.requestContext;

  // Get all the connections
  const connections = await dynamoDb
    .scan({ TableName, ProjectionExpression: "id" })
    .promise();

  const apiG = new ApiGatewayManagementApi({
    endpoint: `${domainName}/${stage}`,
  });

  const postToConnection = async function ({ id }) {
    try {
      // Send the message to the given client
      await apiG
        .postToConnection({ ConnectionId: id, Data: messageData })
        .promise();
    } catch (e) {
      if (e.statusCode === 410) {
        // Remove stale connections
        await dynamoDb.delete({ TableName, Key: { id } }).promise();
      }
    }
  };

  // Iterate through all the connections
  await Promise.all(connections.Items.map(postToConnection));

  return { statusCode: 200, body: "Message sent" };
};
```

We are doing a couple of things here:

1. We first JSON decode our message body.
2. Then we grab all the connection ids from our table.
3. We iterate through all the ids and use the `postToConnection` method of the [`AWS.ApiGatewayManagementApi`](https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/ApiGatewayManagementApi.html) class to send out our message.
4. If it fails to send the message because the connection has gone stale, we delete the connection id from our table.

Now let's do a complete test!

Create another client by opening the [**WebSocket Echo Test**](https://www.piesocket.com/websocket-tester) page in **a different browser window**. Just like before, paste the `ApiEndpoint` as the **url** and hit **Connect**.

![Connect to serverless WebSocket API again](/assets/examples/websocket/connect-to-serverless-websocket-api-again.png)

Once connected, paste the following into the **Message** field and hit **Send**.

```
{"action":"sendmessage", "data":"Hello World"}
```

![Send message to serverless WebSocket API](/assets/examples/websocket/send-message-to-serverless-websocket-api.png)

You'll notice in the **Log** that it sends the message (`SENT:`) and receives it as well (`RECEIVED:`).

Also, if you flip back to our original WebSocket client window, you'll notice that the message was received there as well!

![Receive message from serverless WebSocket API](/assets/examples/websocket/receive-message-from-serverless-websocket-api.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless WebSocket API. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
