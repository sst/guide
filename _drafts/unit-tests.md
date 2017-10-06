---
layout: post
---

### What is different?

In the serverless architecture, your Lambda function will most likely talk to a lot of services. In this tutorial, we utilized the database service AWS DynamoDB. But as your project grows, soon you might find your Lambda functions talking to AWS ElasticCache for in-memory cache, AWS SNS for sending notifications, and etc. All of which are hard to test because you can't control them in code. To void these unwanted side-effects, a good practice is mocking the AWS services. You replace the difficult parts of your tests with something that makes testing simple.

In this chapter, we are going to use [Jest](https://facebook.github.io/jest/) for our testing framework.


### Structure code

Let's take the example of an **aws_iam** authorized API that loads a user's info from DynamoDB; formats the data; and then return as a JSON string. The code in `handler.js` would look like

``` javascript
import AWS from 'aws-sdk';
AWS.config.update({region:'us-east-1'});
const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function getUser(event, context, callback) {
  const params = {
    TableName: 'users',
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
    },
  };
  const userRet = await dynamoDb.get(params).promise();
  const user = userRet.Item;

  const fullName = ( ! user.firstName  &&  ! user.lastName)
    ? 'Anonymous'
    : `user.firstName user.lastName`;

  callback(null, {
    statusCode: 200,
    body: JSON.stringify({
      userId: user.userId,
      fullName: fullName,
    })
  });
};
```

The code does a couple of things:

- first it reads the Cognito federated identity id from the event object and uses it as the user id;
- then it makes a call to DynamoDB to get the user object;
- lastly it builds user's full name and returns it along with the user's id.

Testing this function as a whole is rather cumbersome. It requires mocking of the AWS module and the callback function. Let's refactor the code so we can keep the business logic separate.

**db.js**

``` javascript
import AWS from 'aws-sdk';
AWS.config.update({region:'us-east-1'});
const dynamoDb = new AWS.DynamoDB.DocumentClient();

export async function getUserById(userId) {
  const params = {
    TableName: 'users',
    Key: {
      userId: userId,
    },
  };
  const ret = await dynamoDb.get(params).promise();
  return ret.Item;
}
```

**user.js**

``` javascript
import * as db from './db';

export async function getUser(userId) {

  const user = await db.getUserById(userId);
  const fullName = ( ! user.firstName  &&  ! user.lastName)
    ? 'Anonymous'
    : `user.firstName user.lastName`;

  return {
    userId: user.userId,
    fullName: fullName,
  };
}
```

**handler.js**

``` javascript
import * as user from 'user';

export async function getUser(event, context, callback) {
  const userId = event.requestContext.identity.cognitoIdentityId,
  const user = user.getUser(userId);
  callback(null, {
    statusCode: 200,
    body: JSON.stringify(user)
  });
};
```

Now, the business logic is kept separate in **user.js**.

### Setup tests

Under the project root directory, run

``` bash
$ npm install --save-dev jest
```

Open the `package.json` file and add a **test** command under **scripts**.

``` json
{
...
  "scripts": {
    "test": "jest"
  },
...
}
```

Create a new file called `handler.test.js` with the following.

``` javascript
// Mock db module
jest.mock('./db', () => {
  return {
    getUserById: jest.fn((userId) => {
      if (userId == 111) {
        return {
          userId: userId,
          firstName: 'Hello',
          lastName: 'World',
        };
      }
      else if (userId == 222) {
        return {
          userId: userId,
        };
      }
    })
  };
});


// Tests
import * as user from './user';

test('user has name', async () => {
  const userId = 111;
  const value = await user.getUser(userId);
  const expected = {
    userId: userId,
    fullName: 'Hello World',
  };

  expect(value).toEqual(expected);
});

test('user does not have name', async () => {
  const userId = 222;
  const value = await user.getUser(userId);
  const expected = {
    userId: userId,
    fullName: 'Anonymous',
  };

  expect(value).toEqual(expected);
});
```

The code first mocks the **db.js** module to eliminate the side effect introduced by the DynamoDB. The mocked **getUserById()** method will return mocked user objects depending on the passed in userId. With the mocked user objects, we are then able to test the scenarios of a user having first and last name and a user not having them.

Run the tests.

``` bash
$ npm test

 PASS  ./hello.test.js
  ✓ user has name (4ms)
  ✓ user does not have name (1ms)

Test Suites: 1 passed, 1 total
Tests:       2 passed, 2 total
Snapshots:   0 total
Time:        0.918s, estimated 1s
Ran all test suites.
```
