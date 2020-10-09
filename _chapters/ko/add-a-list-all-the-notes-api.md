---
layout: post
title: Add a List All the Notes API
date: 2017-01-01 00:00:00
description: 노트 작성 앱에서 사용자가 노트를 검색 할 수있게 하려면 노트 목록 GET API를 추가해야합니다. 이를 위해 우리는 Serverless Framework 프로젝트에 새로운 Lambda 함수를 추가 할 것입니다. Lambda 함수는 DynamoDB 테이블에서 모든 사용자의 노트를 검색합니다.
lang: ko
ref: add-a-list-all-the-notes-api
context: true
code: backend
comments_id: add-a-list-all-the-notes-api/147
---

자 이번에는 사용자가 가진 모든 노트목록을 가져오는 API를 추가하겠습니다.

### 함수 추가하기 

{%change%} 아래 내용을 가진 `list.js` 파일을 신규로 생성합니다.

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: "notes",
    // 'KeyConditionExpression' 조건을 가진 쿼리를 정의합니다.
    // - 'userId = :userId': 파티션 키인  'userId' 값과 같은 데이터를 반환하도록 합니다.
    // 'ExpressionAttributeValues' 조건 값을 정의합니다.
    // - ':userId': 'userId' 값을 사용자 인증을 완료한 Cognito Identity Pool의 인증 ID
    //   를 정의합니다. 
    KeyConditionExpression: "userId = :userId",
    ExpressionAttributeValues: {
      ":userId": event.requestContext.identity.cognitoIdentityId
    }
  };

  const result = await dynamoDb.query(params);
  // 응답 본문에 일치하는 아이템의 목록을 반환합니다.
  return result.Items;
});
```

이 파일은 DynamoDB의 `query` 호출 내용에 `userId` 값을 전달한다는 것을 제외하면 `get.js`와 매우 유사합니다.

### API 엔드포인트 구성하기 

{%change%} `serverless.yml` 파일을 열고 아래 내용을 추가합니다.

``` yaml
  list:
    # list.js의 메인 함수를 호출하는 HTTP API 엔드포인트를 정의합니다. 
    # - path: url 경로는 /notes
    # - method: GET 요청 
    handler: list.main
    events:
      - http:
          path: notes
          method: get
          cors: true
          authorizer: aws_iam
```


이것은 GET 요청을 취하는 `/notes` 엔드포인트를 정의합니다.

### 테스트 

{%change%} `mocks/list-event.json` 파일을 생성하고 아래 내용을 추가합니다.

``` json
{
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

그리고 이 프로젝트의 루트 디렉토리에서 함수를 실행합니다.

``` bash
$ serverless invoke local --function list --path mocks/list-event.json
```

이에 대한 응답은 아래와 유사해야합니다.

``` bash
{
  statusCode: 200,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true
  },
  body: '[{"attachment":"hello.jpg","content":"hello world","createdAt":1487800950620,"noteId":"578eb840-f70f-11e6-9d1a-1359b3b22944","userId":"USER-SUB-1234"}]'
}
```
이 API는 단 하나의 노트 객체를 반환하는`get.js` 함수와 대조적으로 노트 객체의 배열을 반환합니다.

그럼 다음 API를 추가하여 노트를 업데이트하겠습니다.
