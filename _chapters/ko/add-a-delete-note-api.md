---
layout: post
title: Add a Delete Note API
date: 2017-01-03 00:00:00
description: 노트 작성 앱에서 사용자가 노트를 삭제할 수 있도록 노트 DELETE API를 추가합니다. 이를 위해 우리는 Serverless Framework 프로젝트에 새로운 Lambda 함수를 추가 할 것입니다. Lambda 함수는 DynamoDB 테이블에서 사용자의 노트를 삭제합니다.
lang: ko
ref: add-a-delete-note-api
context: true
code: backend
comments_id: add-a-delete-note-api/153
---

마지막으로 사용자가 특정 노트를 삭제할 수 있도록 API를 만들어 보겠습니다.

### 함수 추가하기

<img class="code-marker" src="/assets/s.png" />`delete.js` 파일을 생성하고 아래 코드를 붙여 넣기 합니다.

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: "notes",
    // 'Key' 삭제할 아이템의 파티션 키와 정렬 키를 정의합니다.
    // - 'userId': 인증 사용자의 Cognito Identity Pool 인증 ID 
    // - 'noteId': 경로 파라미터
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id
    }
  };

  await dynamoDb.delete(params);
  return { status: true };
});
```

이 파일은 삭제할 노트의 `userId` 와 `noteId` 값을 이용해 DynamoDB에 `delete`를 호출합니다. 

### API 엔드포인트 구성하기 

<img class="code-marker" src="/assets/s.png" />`serverless.yml` 파일을 열어서 아래 내용을 추가합니다. 

``` yaml
  delete:
    # delete.js의 메인 함수를 호출하는 HTTP API 엔드포인트
    # - path: url 경로는 /notes/{id} 입니다.
    # - method: DELETE 요청 
    handler: delete.main
    events:
      - http:
          path: notes/{id}
          method: delete
          cors: true
          authorizer: aws_iam
```

이것은 DELETE 요청 핸들러 함수를 `/notes/{id}` 엔드포인트에 추가합니다.

### 테스트

<img class="code-marker" src="/assets/s.png" />`mocks/delete-event.json` 파일을 만들고 아래 내용을 붙여 넣기 합니다.

역시 이전과 같이 `pathParameters` 블록에 `id` 값은 `noteId` 값으로 대체합니다.

``` json
{
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
루트 디렉토리에서 새로 추가한 함수를 실행합니다.

``` bash
$ serverless invoke local --function delete --path mocks/delete-event.json
```

반환된 응답은 아래와 유사해야합니다.

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

마침내 API들이 완성되었습니다. 그리고 이제 배포 준비가 거의 완료되었습니다.
