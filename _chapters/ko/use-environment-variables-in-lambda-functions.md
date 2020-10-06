---
layout: post
title: Use Environment Variables in Lambda Functions
date: 2018-03-03 00:00:00
lang: ko
description: 우리의 자원을 infrastructure as code로 전개하기 위해 Serverless Framework 프로젝트를 구성하려면 람다 함수를 몇 가지 변경해야합니다. 리소스를 하드 코딩하는 대신 process.env 변수를 사용하여 리소스를 참조할 수 있습니다.
comments_id: use-environment-variables-in-lambda-functions/166
ref: use-environment-variables-in-lambda-functions
---

[Serverless의 DynamoDB 구성]({% link _chapters/configure-dynamodb-in-serverless.md %}) 챕터 뒷부분에서 CloudFormation을 통해 테이블을 생성했습니다. 생성된 테이블은 현재 stage를 기반으로합니다. 즉, 우리 Lambda 함수에서 데이터베이스와 대화할 때 테이블 이름을 단순히 하드코딩할 수는 없습니다. `dev` stage에서는 `dev-notes`라고 불리우며 `prod`에서는 `prod-notes`라고 불릴 것입니다.

이와 같이 우리가 람다 함수에서 환경변수를 사용하여 어떤 테이블을 사용해야 하는지를 알려줍니다. 지금 `create.js`를 열어 보면 다음 내용을 보게 될 것입니다.

``` js
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
```

관련 테이블 이름을 사용하려면 `TableName : "notes"` 행을 변경해야합니다. [Serverless의 DynamoDB 구성]({% link _chapters/configure-dynamodb-in-serverless.md %}) 챕터에서는 `environment:` 블록 아래의 `serverless.yml`에도 `tableName :`을 추가했습니다.

``` yml
# These environment variables are made available to our functions
# under process.env.
environment:
  tableName: ${self:custom.tableName}
```

거기에서 확인했듯이, 람다 함수에서 이것을 `process.env.tableName`으로 참조할 수 있습니다.

그럼 해당 내용으로 변경해보겠습니다.

{%change%} `create.js`의 아래 행을

```
TableName: "notes",
```

{%change%} 다음 내용으로 바꿉니다.:

```
TableName: process.env.tableName,
```

{%change%} 같은 방법으로, `get.js` 파일도 수정합니다.:

```
TableName: "notes",
```

{%change%} 다음 내용으로 바꿉니다.:

```
TableName: process.env.tableName,
```

{%change%} `list.js` 파일도 마찬가지로:

```
TableName: "notes",
```

{%change%} 수정합니다.:

```
TableName: process.env.tableName,
```

{%change%} `update.js` 파일:

```
TableName: "notes",
```

{%change%} 마찬가지로 수정합니다.:

```
TableName: process.env.tableName,
```

{%change%} 마지막으로 `delete.js` 파일도:

```
TableName: "notes",
```

{%change%} 아래 내용으로 수정합니다.:

```
TableName: process.env.tableName,
```

### 코드 커밋

{%change%} 지금까지 수정한 내용을 커밋합니다.:

``` bash
$ git add .
$ git commit -m "Use environment variables in our functions"
```

다음으로, 새로 구성된 Serverless 백엔드 API를 배포해보겠습니다.
