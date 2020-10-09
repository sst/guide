---
layout: post
title: Add an Update Note API
date: 2017-01-02 00:00:00
description: 노트 작성 앱에서 사용자가 노트를 업데이트할 수있게 하려면 노트 업데이트 PUT API를 추가해야합니다. 이를 위해 우리는 Serverless Framework 프로젝트에 새로운 Lambda 함수를 추가 할 것입니다. Lambda 함수는 DynamoDB 테이블에서 사용자 노트를 업데이트합니다.
lang: ko
ref: add-an-update-note-api
context: true
code: backend
comments_id: add-an-update-note-api/144
---

이제는 사용자가 ID를 사용하여 노트를 새 노트 객체로 업데이트 할 수있는 API를 작성해 보겠습니다.

### 함수 추가하기

{%change%} `update.js` 파일을 새로 만들고 아래 코드 내용을 붙여 넣으세요. 

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const data = JSON.parse(event.body);
  const params = {
    TableName: "notes",
    // 'Key' 수정하고자 하는 아이템의 파티션 키와 정렬 키를 정의합니다.
    // - 'userId': 인증된 사용자의 Cognito Identity Pool의 인증 ID
    // - 'noteId': 경로 파라미터 
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id
    },
    // 'UpdateExpression' 업데이트 될 속성을 정의합니다.
    // 'ExpressionAttributeValues' 업데이트 표현식의 값을 정의합니다.
    UpdateExpression: "SET content = :content, attachment = :attachment",
    ExpressionAttributeValues: {
      ":attachment": data.attachment || null,
      ":content": data.content || null
    },
    // 'ReturnValues' 아이템 속성을 반환할지 여부와 방법을 지정합니다.
    // 여기서 ALL_NEW는 업데이트 후 항목의 모든 속성을 반환합니다.
    // 아래에서 '결과값'을 검사하여 다른 설정에서 작동하는 방식을 확인할 수 있습니다.
    ReturnValues: "ALL_NEW"
  };

  await dynamoDb.update(params);
  return { status: true };
});
```

이것은 `create.js` 함수와 비슷하게 보일 것입니다. 여기서 우리는 `매개 변수`에 새로운`content` 와 `attachment` 값으로 `update` DynamoDB를 호출합니다.

### API 엔드포인트 구서하기 

{%change%} `serverless.yml` 파일을 열어서 아래 코드를 추가합니다.

``` yaml
  update:
    # update.js의 메인 함수를 호출하는 HTTP API 엔드포인트를 정의합니다.
    # - path: url 경로는 /notes/{id} 입니다.
    # - method: PUT 요청 
    handler: update.main
    events:
      - http:
          path: notes/{id}
          method: put
          cors: true
          authorizer: aws_iam
```

여기에서는 PUT 요청에 대한 핸들러를 `/notes/{id}` 엔드 포인트에 추가합니다.

### 테스트

{%change%} `mocks/update-event.json` 파일을 생성하고 아래 내용을 추가합니다.

그리고 `pathParameters` 블록에 있는 `id`에 이전에 사용했던 `noteId` 값으로 대체하는 것을 잊지 마세요.

``` json
{
  "body": "{\"content\":\"new world\",\"attachment\":\"new.jpg\"}",
  "pathParameters": {
    "id": "578eb840-f70f-11e6-9d1a-1359b3b22944"
  },
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

그리고 루트 디렉토리에서 새로 만든 함수를 실행합니다.

``` bash
$ serverless invoke local --function update --path mocks/update-event.json
```

반환되는 결과는 아래와 유사해야합니다.

``` bash
{
  statusCode: 200,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true
  },
  body: '{"status":true}'
}
```

다음은 ID 값을 이용해 해당 노트를 삭제하는 API를 추가해 보겠습니다.
