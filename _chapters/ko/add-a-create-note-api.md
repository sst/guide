---
layout: post
title: Add a Create Note API
date: 2016-12-30 00:00:00
description: 노트 작성 응용 프로그램에서 사용자가 노트를 작성할 수 있도록 노트 작성 POST API를 추가합니다. 이를 위해 우리는 Serverless Framework 프로젝트에 새로운 Lambda 함수를 추가 할 것입니다. 람다 함수는 노트를 DynamoDB 테이블에 저장하고 새로 생성 된 노트를 반환합니다. 또한 serverless 백엔드 API에 CORS를 사용할 수 있도록 Access-Control 헤더를 설정해야합니다.
lang: ko
ref: add-a-create-note-api
context: true
code: backend
comments_id: add-a-create-note-api/125
---

먼저 노트를 만드는 API를 추가하여 백엔드를 시작해 보겠습니다. 이 API는 노트 오브젝트를 입력으로 사용하고 새 ID로 데이터베이스에 저장합니다. 노트 오브젝트는 `content` 필드(노트의 내용)와 `attachment` 필드(업로드 된 파일의 URL)를 포함합니다.

### 함수 추가하기 

첫 번째 함수를 추가해 보겠습니다.

<img class="code-marker" src="/assets/s.png" />프로젝트 루트에 다음과 같이`create.js`라는 새로운 파일을 만듭니다.

``` javascript
import uuid from "uuid";
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export function main(event, context, callback) {
  //요청 본문은 'event.body'의 JSON 인코딩 문자열로 전달됩니다.
  const data = JSON.parse(event.body);

  const params = {
    TableName: "notes",
     // 'Item'은 생성 될 항목의 속성을 포함합니다.
     // - 'userId': 사용자 신원은 Cognito ID 풀 ID는 인증 된 사용자의 사용자 ID를 사용합니다.
     // - 'noteId': 고유한 uuid
     // - 'content': 요청 본문으로부터 파싱 됨
     // - 'attachment': 요청 본문에서 파싱 됨
     // - 'createdAt': 현재 유닉스 타임 스탬프
    Item: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: uuid.v1(),
      content: data.content,
      attachment: data.attachment,
      createdAt: Date.now()
    }
  };

  dynamoDb.put(params, (error, data) => {
    // CORS (Cross-Origin Resource Sharing)를 사용하도록 응답 헤더를 설정합니다.
    const headers = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": true
    };

    // 에러발생시 상태코드 500을 반환합니다.
    if (error) {
      const response = {
        statusCode: 500,
        headers: headers,
        body: JSON.stringify({ status: false })
      };
      callback(null, response);
      return;
    }

	// 새로운 항목이 생성되면 상태 코드 200을 반환합니다.
    const response = {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify(params.Item)
    };
    callback(null, response);
  });
}
```

코드에도 몇 가지 주석을 달았지만 여기서는 간단한 몇 가지 작업을 처리합니다.

- AWS JS SDK는 람다 함수의 현재 리전을 기반으로 작업 리전을 가정합니다. 따라서 DynamoDB 테이블이 다른 리전에있는 경우 DynamoDB 클라이언트를 초기화하기 전에 AWS.config.update ({region : "my-region"})를 호출하여 설정해야합니다.
- `event.body`에서 입력을 파싱합니다. 이것은 HTTP 요청 매개변수를 나타냅니다.
- `userId`는 요청의 일부로 들어오는 연합 ID입니다. 이것은 접속자가 사용자 풀을 통해 인증 된 후에 설정됩니다. 우리는 Cognito 인증 풀을 설정할 다음 장에서 이에 대해 더 자세히 설명하겠습니다. 별도로 사용자 풀에 있는 사용자 ID를 이용하려는 경우; [Cognito ID 매핑 및 사용자 풀 ID]({% link _chapters/mapping-cognito-identity-id-and-user-pool-id.md %}) 장을 살펴보십시오.
- DynamoDB를 호출하여 생성 된 `noteId` 및 현재 날짜가 `createdAt`인 새 객체를 넣습니다.
- 성공하면 HTTP 상태 코드가 `200`인 새로 생성 된 노트 객체와 응답 헤더를 반환하여 **CORS(Cross-Origin Resource Sharing)** 를 사용하도록 설정합니다.
- 그리고 DynamoDB 호출이 실패하면 HTTP 상태 코드가 '500'인 오류를 반환합니다.

### API 엔드포인트 구성

이제 우리 함수에 API 엔드포인트를 정의해 보겠습니다.

<img class="code-marker" src="/assets/s.png" />`serverless.yml` 파일을 열어서 아래 코드로 대치하십시오.

``` yaml
service: notes-app-api

# ES6 변환을 위해 serverless-webpack 플러그인 사용
plugins:
  - serverless-webpack
  - serverless-offline

# serverless-webpack 구성 
# 외부 모듈 패키징 자동화 활성
custom:
  webpack:
    webpackConfig: ./webpack.config.js
    includeModules: true

provider:
  name: aws
  runtime: nodejs8.10
  stage: prod
  region: us-east-1

  # 'iamRoleStatements' Lambda 함수를 위한 권한 정책 정의
  # Lmabda 함수에 DynamoDB 액세스 권한을 설정합니다.
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
  # create.js의 메인 함수를 호출하는 HTTP API 엔드포인트를 정의
  # - path: url 경로는 /notes
  # - method: POST 요청
  # - cors: 브라우저의 크로스 도메인 API 호출을 위해 CORS (Cross-Origin Resource Sharing) 활성화 
  # - authorizer: AWS IAM 역할을 통한 인증 
  create:
    handler: create.main
    events:
      - http:
          path: notes
          method: post
          cors: true
          authorizer: aws_iam
```

여기에 새로 추가 된 작성 기능을 구성에 추가합니다. 우리는`/notes` 엔드포인트에서`post` 요청을 처리하도록 지정합니다. 단일 람다 함수를 사용하여 단일 HTTP 이벤트에 응답하는이 패턴은 [Microservices 아키텍처](https://en.wikipedia.org/wiki/Microservices)와 매우 비슷합니다. 이 부분과 [Serverless Framework 프로젝트 구성하기]({% link _chapters/organizing-serverless-projects.md %}) 장에서 몇 가지 다른 패턴을 논의합니다. CORS 지원을 true로 설정했습니다. 프론트 엔드가 다른 도메인에서 제공되기 때문입니다. 승인자로서 사용자의 IAM 자격 증명을 기반으로 API에 대한 액세스를 제한하려고합니다. 이 내용과 Cognito Identity Pool 챕터에서 사용자 풀이 어떻게 작동하는지에 대해 알아볼 것입니다.

`iamRoleStatements` 섹션은 람다 함수가 어떤 리소스에 액세스 할 수 있는지 AWS에 알려줍니다. 이 경우 람다 함수가 위에 나열된 작업을 DynamoDB에서 수행할 수 있습니다. DynamoDB는`arn:aws:dynamodb:us-east-1:*:*`를 사용하여 지정합니다. 이것은 대략`us-east-1` 리전의 모든 DynamoDB 테이블을 가리 킵니다. 여기에 테이블 이름을 지정하여보다 구체적으로 설명 할 수 있지만 여러분에게 연습 문제로 남겨 두겠습니다. 반드시 DynamoDB 테이블이 생성 된 리전을 사용하십시오. 나중에 발생하는 문제의 대부분의 원인이 될 수 있습니다. 우리에게는 이 리전이 'us-east-1'입니다.


### 테스트 

자, 이제 새로운 API를 테스트할 준비가 되었습니다. 로컬에서 테스트하기 위해 입력 파라미터를 임의로 만들겠습니다.

<img class="code-marker" src="/assets/s.png" />프로젝트 루트에서 `mocks/` 디렉토리를 생성합니다.

``` bash
$ mkdir mocks
```

<img class="code-marker" src="/assets/s.png" />`mocks/create-event.json` 파일을 만들고 아래 코드를 추가합니다.

``` json
{
  "body": "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}",
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

`body`와`requestContext` 필드는 우리가 새로 추가한 함수에서 사용한 필드라는 것을 눈치 채셨을겁니다. 이 경우`cognitoIdentityId` 필드는 우리가`userId`로 사용할 문자열입니다. 여기서 임의의 문자열을 사용할 수 있습니다. 우리가 다른 기능을 테스트할 때에도 같은 값을 사용하도록 하세요.

그리고 함수를 호출하기 위해 루트 디렉토리에서 다음을 실행합니다.

``` bash
$ serverless invoke local --function create --path mocks/create-event.json
```

만일 여러분의 AWS SDK 자격 증명을 위한 프로필이 여러개인 경우 명시적으로 선택해야합니다. 그럴경우 다음 명령을 사용하십시오.

``` bash
$ AWS_PROFILE=myProfile serverless invoke local --function create --path mocks/create-event.json
```

`myProfile`은 여러분이 사용하고자 하는 AWS 프로필 이름입니다. 만일 서버리스에서 AWS 프로필을 어떻게 작동하는지 알고 싶으시다면 이 곳에 있는 [다중 AWS 프로필 설정하기]({% link _chapters/configure-multiple-aws-profiles.md %}) 챕터를 참고하십시오.

응답은 다음과 같이 나와야합니다.

``` bash
{
  statusCode: 200,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true
  },
  body: '{"userId":"USER-SUB-1234","noteId":"578eb840-f70f-11e6-9d1a-1359b3b22944","content":"hello world","attachment":"hello.jpg","createdAt":1487800950620}'
}
```

여기서 응답으로 나온 `noteId` 값을 적어 놓으세요. 다음 장에서 여기서 작성한 새 노트를 사용하겠습니다.

### 코드 리펙토링 

다음 장으로 넘어가기 전에 앞으로 모든 API에 대해 많은 것을 처리해야 하므로 코드를 빠르게 리팩토링하겠습니다.

<img class="code-marker" src="/assets/s.png" />프로젝트 루트에서 `libs/` 디렉토리를 생성합니다.

``` bash
$ mkdir libs
$ cd libs
```

<img class="code-marker" src="/assets/s.png" />그리고 아래 내용으로 `libs/response-lib.js` 파일을 만듭니다.

``` javascript
export function success(body) {
  return buildResponse(200, body);
}

export function failure(body) {
  return buildResponse(500, body);
}

function buildResponse(statusCode, body) {
  return {
    statusCode: statusCode,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": true
    },
    body: JSON.stringify(body)
  };
}
```

이렇게하면 적절한 HTTP 상태 코드와 헤더를 사용하여 성공 및 실패 사례에 대한 응답 오브젝트를 작성할 수 있습니다.

<img class="code-marker" src="/assets/s.png" />다시 `libs/` 디렉토리에서 아래 내용으로  `dynamodb-lib.js` 파일을 생성합니다.

``` javascript
import AWS from "aws-sdk";

export function call(action, params) {
  const dynamoDb = new AWS.DynamoDB.DocumentClient();

  return dynamoDb[action](params).promise();
}
```

여기서는 DynamoDB 메소드의 promise 형식을 사용하고 있습니다. Promise는 표준 콜백함수 구문 대신 사용할 비동기 코드를 관리하는 방법입니다. 코드를 훨씬 쉽게 읽을 수 있습니다.

<img class="code-marker" src="/assets/s.png" />이제 우리는`create.js`로 돌아가서 우리가 만든 Helper 함수를 사용할 것입니다. `create.js`를 다음으로 대체하십시오.

``` javascript
import uuid from "uuid";
import * as dynamoDbLib from "./libs/dynamodb-lib";
import { success, failure } from "./libs/response-lib";

export async function main(event, context) {
  const data = JSON.parse(event.body);
  const params = {
    TableName: "notes",
    Item: {
      userId: event.requestContext.identity.cognitoIdentityId,
      noteId: uuid.v1(),
      content: data.content,
      attachment: data.attachment,
      createdAt: Date.now()
    }
  };

  try {
    await dynamoDbLib.call("put", params);
    return success(params.Item);
  } catch (e) {
    return failure({ status: false });
  }
}
```

또한 람다 함수를 리팩토링하기 위해 여기 `async/await` 패턴을 사용하고 있습니다. 이렇게하면 처리가 완료되면 다시 돌아올 수 있습니다. 콜백 함수를 사용하는 대신말이죠.

다음으로 API를 작성하여 ID가 지정된 노트를 가져옵니다.

---

#### 공통 이슈 

- 응답 `statusCode: 500`

함수를 호출 할 때`statusCode : 500` 응답을 보게되면 디버그하는 방법이 있습니다. 에러는 우리 코드에 의해`catch` 블록에서 생성됩니다. 이렇게`console.log`를 추가하면 문제가 무엇인지에 대한 단서를 얻을 수 있습니다.

  ``` javascript
  catch(e) {
    console.log(e);
    return failure({status: false});
  }
  ```
