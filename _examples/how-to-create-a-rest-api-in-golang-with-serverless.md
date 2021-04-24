---
layout: example
title: How to create a REST API in Golang with serverless
date: 2021-04-04 00:00:00
lang: en
description: In this example we will look at how to create a serverless REST API on AWS with Golang using Serverless Stack (SST). We'll be using the sst.Api construct to define the routes of our API.
repo: rest-api-go
ref: how-to-create-a-rest-api-in-golang-with-serverless
comments_id: how-to-create-a-rest-api-in-golang-with-serverless/2367
---

In this example we'll look at how to create a serverless REST API with Golang on AWS using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1 for our CDK code
- Golang 1.16 or similar for our Lambda code
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest --language go rest-api-go
$ cd rest-api-go
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "rest-api-go",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `lib/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `lib/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure. CDK doesn't currently support Golang, so we'll be using JavaScript here.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project. We'll be using Golang for this.

## Setting up our routes

Let's start by setting up the routes for our API.

{%change%} Replace the `lib/MyStack.js` with the following.

``` js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create the HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /notes": "src/list.go",
        "GET /notes/{id}": "src/get.go",
        "PUT /notes/{id}": "src/update.go",
      },
    });

    // Show API endpoint in output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

We are creating an API here using the [`sst.Api`](https://docs.serverless-stack.com/constructs/api) construct. And we are adding three routes to it.

```
GET /notes
GET /notes/{id}
PUT /notes/{id}
```

The first is getting a list of notes. The second is getting a specific note given an id. And the third is updating a note.

## Adding function code

For this example, we are not using a database. We'll look at that in detail in another example. So internally we are just going to get the list of notes from a file.

{%change%} Let's add a file that contains our notes in `db/notes.go`.

``` go
package db

import (
	"strconv"
	"time"
)

func Notes() map[string]map[string]string {
	return map[string]map[string]string{
		"id1": {
			"noteId":    "id1",
			"userId":    "user1",
			"content":   "Hello World!",
			"createdAt": strconv.FormatInt(time.Now().Unix(), 10),
		},
		"id2": {
			"noteId":    "id2",
			"userId":    "user2",
			"content":   "Hello Old World!",
			"createdAt": strconv.FormatInt(time.Now().Unix()-1000, 10),
		},
	}
}
```

Now add the code for our first endpoint.

### Getting a list of notes

{%change%} Add a `src/list.go`.

``` go
package main

import (
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/serverless-stack/examples/rest-api-go/db"
)

func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	response, _ := json.Marshal(db.Notes())

	return events.APIGatewayProxyResponse{
		Body:       string(response),
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(Handler)
}
```

Here we are simply converting a list of notes to string, and responding with that in the request body.

### Getting a specific note

{%change%} Add the following to `src/get.go`.

``` go
package main

import (
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/serverless-stack/examples/rest-api-go/db"
)

func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	var notes = db.Notes()
	var note = notes[request.PathParameters["id"]]

	if note == nil {
		return events.APIGatewayProxyResponse{
			Body:       `{"error":true}`,
			StatusCode: 404,
		}, nil
	}

	response, _ := json.Marshal(note)

	return events.APIGatewayProxyResponse{
		Body:       string(response),
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(Handler)
}
```

Here we are checking if we have the requested note. If we do, we respond with it. If we don't, then we respond with a 404 error. 

### Updating a note

{%change%} Add the following to `src/update.go`.

``` go
package main

import (
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/serverless-stack/examples/rest-api-go/db"
)

func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	var notes = db.Notes()
	var note = notes[request.PathParameters["id"]]

	if note == nil {
		return events.APIGatewayProxyResponse{
			Body:       `{"error":true}`,
			StatusCode: 404,
		}, nil
	}

	var body map[string]string
	_ = json.Unmarshal([]byte(request.Body), &body)

	note["content"] = body["content"]

	response, _ := json.Marshal(note)

	return events.APIGatewayProxyResponse{
		Body:       string(response),
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(Handler)
}
```

We first check if the note with the requested id exists. And then we update the content of the note and return it. Of course, we aren't really saving our changes because we don't have a database!

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

``` bash
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
dev-rest-api-go-my-stack: deploying...

 ✅  dev-rest-api-go-my-stack


Stack dev-rest-api-go-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://rxk5buowgi.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Now let's get our list of notes. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://rxk5buowgi.execute-api.us-east-1.amazonaws.com/notes
```

You should see the list of notes as a JSON string.

And use the following endpoint to to retrieve a specific note.

```
https://rxk5buowgi.execute-api.us-east-1.amazonaws.com/notes/id1
```

Now to update our note, we need to make a `PUT` request. Our browser cannot make this type of request. So use the following command in your terminal.

``` bash
curl -X PUT \
-H 'Content-Type: application/json' \
-d '{"content":"Updating my note"}' \
https://rxk5buowgi.execute-api.us-east-1.amazonaws.com/notes/id1
```

This should respond with the updated note.

## Making changes

Let's make a quick change to our API. It would be good if the JSON strings are pretty printed to make them more readable.

{%change%} Replace `Handler` function in `src/list.go` with the following.

``` go
func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	response, _ := json.MarshalIndent(db.Notes(), "", "  ")

	return events.APIGatewayProxyResponse{
		Body:       string(response),
		StatusCode: 200,
	}, nil
}
```

Here we are just adding some spaces to pretty print the JSON.

If you head back to the `/notes` endpoint.

```
https://rxk5buowgi.execute-api.us-east-1.amazonaws.com/notes
```

You should see your list of notes in a more readable format.

## Deploying your API

Now that our API is tested, let's deploy it to production. You'll recall that we were using a `dev` environment, the one specified in our `sst.json`. However, we are going to deploy it to a different environment. This ensures that the next time we are developing locally, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

``` bash
$ npx sst deploy --stage prod
```

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

``` bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!


