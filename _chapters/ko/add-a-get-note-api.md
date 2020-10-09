---
layout: post
title: Add a Get Note API
date: 2016-12-31 00:00:00
description: 노트 작성 앱에서 사용자가 노트를 검색 할 수 있도록 GET 노트 API를 추가 할 예정입니다. 이것을 위해 Serverless Framework 프로젝트에 새로운 Lambda 함수를 추가할 것입니다. 생성된 Lambda 함수는 DynamoDB 테이블에서 노트를 검색합니다. 
lang: ko
ref: add-a-get-note-api
context: true
code: backend
comments_id: add-a-get-note-api/132
---

이제 데이터베이스에 노트를 생성하고 저장했습니다. 이제 생성된 노트 ID를 이용해 노트 정보를 불러오는 API를 추가해보겠습니다.

### 함수 추가하기 

{%change%} 신규 파일인 `get.js`를 생성하고 아래 코드를 붙여넣기 합니다.

``` javascript
import handler from "./libs/handler-lib";
import dynamoDb from "./libs/dynamodb-lib";

export const main = handler(async (event, context) => {
  const params = {
    TableName: "notes",
	 // 'Key'는 검색 할 항목의 파티션 키와 정렬 키를 정의합니다.
     // - 'userId': 인증 된 사용자의 ID 풀에 해당하는 인증 아이디
     // - 'noteId': 경로 매개 변수
    Key: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: event.pathParameters.id
    }
  };

  const result = await dynamoDb.get(params);
  if ( ! result.Item) {
    throw new Error("Item not found.");
  }

  // 불러온 아이템을 반환합니다.
  return result.Item;
});
```

이 파일은 이전의 `create.js` 함수와 똑같은 구조를 따릅니다. 가장 큰 차이점은 요청을 통해 전달되는`noteId` 와 `userId`가 주어진 노트 객체를 얻기 위해 `dynamoDb.get(params)`을 수행한다는 것입니다.

### API 엔드포인트 구성하기 

{%change%} `serverless.yml` 파일을 열고 아래 코드를 추가합니다.

``` yaml
  get:
    #  get.js의 main 함수를 호출하는 HTTP API 엔드포인트를 정의합니다.
    # - path: /notes/{id} url 경로
    # - method: GET 요청 
    handler: get.main
    events:
      - http:
          path: notes/{id}
          method: get
          cors: true
          authorizer: aws_iam
```

이 코드 블록이 앞의 `create` 블록과 정확히 같은 방법으로 들여 쓰는지 확인하십시오.

이것은 get note API를 정의합니다. `/notes/{id}` 엔드포인트와 함께 GET 요청 핸들러를 추가합니다.

### 테스트

Get note API를 테스트하려면`noteId` 매개 변수를 전달해야합니다. 우리는 이전 장에서 작성한 노트의 `noteId`를 사용하고`pathParameters` 블록을 모의 객체에 추가 할 것입니다. 그러면 해당 내용은 아래와 유사하게 보일 것입니다. `id`의 값을 이전의 `create.js` 함수를 호출 할 때 받았던 ID로 대체하십시오.

{%change%} `mocks/get-event.json` 파일을 만들고 아래 코드를 추가합니다.

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

그리고 새로 생성된 함수를 실행합니다.

``` bash
$ serverless invoke local --function get --path mocks/get-event.json
```

반환된 응답은 아래와 유사해야 합니다.

``` bash
{
  statusCode: 200,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true
  },
  body: '{"attachment":"hello.jpg","content":"hello world","createdAt":1487800950620,"noteId":"578eb840-f70f-11e6-9d1a-1359b3b22944","userId":"USER-SUB-1234"}'
}
```

다음으로 사용자가 가지고 있는 모든 노트들의 목록을 보여주는 API를 만들어 보겠습니다.
