---
layout: post
title: Create a Serverless API with lambda
---

To create API endpoints for our note taking web app to call, we will reply on Serverless Framework to create microservices on AWS Lambda and configure the HTTP endpoints with AWS API Gateway.

### Install Serverless

Install serverless globally
{% highlight bash %}
$ npm install serverless -g
{% endhighlight %}

Setup AWS credentials. 
{% highlight bash %}
$ serverless config credentials --provider aws --key 1234 --secret 5678
{% endhighlight %}

Create an AWS Lambda function in Node.js
{% highlight bash %}
$ serverless create --template aws-nodejs
{% endhighlight %}

Now the directory should contain 2 files, namely **handler.js** and **serverless.yml**
{% highlight bash %}
$ ls
handler.js    serverless.yml
{% endhighlight %}

**serverless.yml** contains the configuration on what AWS services serverless will provision and how to configure them.

**handler.js** contains actual code for microservices that will be deployed to AWS Lambda.

### Install NodeJS Dependencies

**aws-sdk** allows developer to call all AWS services.
**uuid** is used to generate unique note id when storing to DynamoDB.

{% highlight bash %}
$ npm init
$ npm install aws-sdk uuid --save
{% endhighlight %}

Now the directory should contain 3 files and 1 folder.
{% highlight bash %}
$ ls
handler.js    node_modules    package.json    serverless.yml
{% endhighlight %}

**node_modules** contains the nodejs dependencies we just installed.
**package.json** contains the nodejs configuration.

### Create an API to create a note

Create a new file create.js file and paste the following code

{% highlight javascript %}
'use strict';

const uuid = require('uuid');
const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.create = (event, context, callback) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    Item: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: uuid.v1(),
      content: data.content,
      file: data.file,
      createdAt: new Date().getTime(),
    },
  };

  dynamoDb.put(params, (error, data) => {
    const headers = {
      'Access-Control-Allow-Origin': '*',
      "Access-Control-Allow-Credentials" : true,
    };

    if (error) {
      const response = {
        statusCode: 500,
        headers: headers,
        body: JSON.stringify({status: false}),
      };
      callback(null, response);
      return;
    }

    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(params.Item),
    }
    callback(null, response);
	});
};
{% endhighlight %}

Update serverless.yml file and paste the following code

{% highlight yaml %}
service: notes-app-api

provider:
  name: aws
  runtime: nodejs4.3
  stage: prod
  region: us-east-1

  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:DescribeTable
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      Resource: "arn:aws:dynamodb:us-east-1:*:*"

functions:
  create:
    handler: create.create
    events:
      - http:
          path: notes
          method: post
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O
{% endhighlight %}

In **iamRoleStatements**, we defined the permission policy for the code. For example, in this tutorial, the code needs access to DyanmoDB.

In **functions**: we defined 1 http endpoint with path **/notes**. We enabled CORS (Cross-Origin Resource Sharing) for browswer cross domain api call. The api is authencated via the user pool we created in the previous tutorial. **us-east-1_WdHEGAi8O** is your user pool id.

### Deploy
{% highlight bash %}
$ serverless deploy
{% endhighlight %}

### Create the rest APIs

Create a new file get.js file and paste the following code
{% highlight javascript %}
'use strict';

const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.get = (event, context, callback) => {
  const params = {
    TableName: 'notes',
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
  };

  dynamoDb.get(params, (error, result) => {
    const headers = {
      'Access-Control-Allow-Origin': '*',
      "Access-Control-Allow-Credentials" : true,
    };

    if (error) {
      const response = {
        statusCode: 500,
        headers: headers,
        body: JSON.stringify({status: false}),
      };
      callback(null, response);
      return;
    }

    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(result.Item),
    }
    callback(null, response);
	});
};
{% endhighlight %}

Create a new file list.js file and paste the following code
{% highlight javascript %}
'use strict';

const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.list = (event, context, callback) => {
  const params = {
    TableName: 'notes',
    KeyConditionExpression: "userId = :userId",
    ExpressionAttributeValues: {
      ":userId": event.requestContext.authorizer.claims.sub,
    }
  };

  dynamoDb.query(params, (error, result) => {
    const headers = {
      'Access-Control-Allow-Origin': '*',
      "Access-Control-Allow-Credentials" : true,
    };

    if (error) {
      const response = {
        statusCode: 500,
        headers: headers,
        body: JSON.stringify({status: false}),
      };
      callback(null, response);
      return;
    }

    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(result.Items),
    }
    callback(null, response);
	});
};
{% endhighlight %}

Create a new file update.js file and paste the following code
{% highlight javascript %}
'use strict';

const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.update = (event, context, callback) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
    UpdateExpression: 'SET content = :content, #file = :file',
    ExpressionAttributeNames: {
      '#file': 'file',
    },
    ExpressionAttributeValues: {
      ':file': data.file ? data.file : null,
      ':content': data.content ? data.content : null,
    },
    ReturnValues: 'ALL_NEW',
  };

  dynamoDb.update(params, (error, result) => {
    const headers = {
      'Access-Control-Allow-Origin': '*',
      "Access-Control-Allow-Credentials" : true,
    };

    if (error) {
      const response = {
        statusCode: 500,
        headers: headers,
        body: JSON.stringify({status: false}),
      };
      callback(null, response);
      return;
    }

    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(result.Attributes),
    }
    callback(null, response);
	});
};
{% endhighlight %}

Create a new file delete.js file and paste the following code
{% highlight javascript %}
'use strict';

const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

module.exports.delete = (event, context, callback) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: 'notes',
    Key: {
      userId: event.requestContext.authorizer.claims.sub,
      noteId: event.pathParameters.id,
    },
  };

  dynamoDb.delete(params, (error, result) => {
    const headers = {
      'Access-Control-Allow-Origin': '*',
      "Access-Control-Allow-Credentials" : true,
    };

    if (error) {
      const response = {
        statusCode: 500,
        headers: headers,
        body: JSON.stringify({status: false}),
      };
      callback(null, response);
      return;
    }

    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify({status: true}),
    }
    callback(null, response);
	});
};
{% endhighlight %}

Update serverless.yml file and paste the following code

{% highlight yaml %}
service: notes-app-api

provider:
  name: aws
  runtime: nodejs4.3
  stage: prod
  region: us-east-1

  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:DescribeTable
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      Resource: "arn:aws:dynamodb:us-east-1:*:*"

functions:
  list:
    handler: list.list
    events:
      - http:
          path: notes
          method: get
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O

  get:
    handler: get.get
    events:
      - http:
          path: notes/{id}
          method: get
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O

  create:
    handler: create.create
    events:
      - http:
          path: notes
          method: post
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O

  update:
    handler: update.update
    events:
      - http:
          path: notes/{id}
          method: put
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O

  delete:
    handler: delete.delete
    events:
      - http:
          path: notes/{id}
          method: delete
          request:
            parameters:
              paths:
                id: true
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O
{% endhighlight %}

### Deploy again
{% highlight bash %}
$ serverless deploy
{% endhighlight %}

