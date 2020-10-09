---
layout: post
title: Configure DynamoDB in Serverless
date: 2018-02-27 00:00:00
lang: ko
description: We can define our DynamoDB table using the Infrastructure as Code pattern by using CloudFormation in our serverless.yml. We are going to define the AttributeDefinitions, KeySchema, and ProvisionedThroughput.
context: true
comments_id: configure-dynamodb-in-serverless/162
ref: configure-dynamodb-in-serverless
---

이제 `serverless.yml`을 통해 리소스를 생성하겠습니다. DynamoDB로 시작합니다.

### 리소스 만들기

{%change%} `resources/dynamodb-table.yml`에 아래 내용을 추가합니다.

``` yml
Resources:
  NotesTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: ${self:custom.tableName}
      AttributeDefinitions:
        - AttributeName: userId
          AttributeType: S
        - AttributeName: noteId
          AttributeType: S
      KeySchema:
        - AttributeName: userId
          KeyType: HASH
        - AttributeName: noteId
          KeyType: RANGE
      # Set the capacity based on the stage
      ProvisionedThroughput:
        ReadCapacityUnits: ${self:custom.tableThroughput}
        WriteCapacityUnits: ${self:custom.tableThroughput}
```

여기서 하려는 작업을 빨리 알아 보겠습니다.

1. 우리는 `NotesTable`이라고하는 DynamoDB 테이블 리소스를 기술합니다.

2. 커스텀 변수 `${self:custom.tableName}`으로부터 테이블 이름을 받아 `serverless.yml`에서 동적으로 생성됩니다. 이에 대해서는 아래에서 자세히 살펴 보겠습니다.

3. 테이블의 두 속성을 `userId` 와`noteId`로 설정하고 있습니다.

4. 마지막으로 몇 가지 사용자 정의 변수를 통해 테이블의 읽기/쓰기 용량을 프로비저닝합니다. 우리는 이것을 곧 정의할 예정입니다.

### 리소스 추가

이제 프로젝트에서 이 리소스에 대한 참조를 추가해 보겠습니다.

{%change%} `serverless.yml` 파일의 아래쪽에 있는 `resources:` 블럭 내용을 다음으로 대체합니다.:

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
  # DynamoDB
  - ${file(resources/dynamodb-table.yml)}
```

{%change%} `serverless.yml` 위쪽에 `custom:` 블럭을 다음 내용으로 대체합니다.:

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or falls back to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  # Set the table name here so we can use it while testing locally
  tableName: ${self:custom.stage}-notes
  # Set our DynamoDB throughput for prod and all other non-prod stages.
  tableThroughputs:
    prod: 5
    default: 1
  tableThroughput: ${self:custom.tableThroughputs.${self:custom.stage}, self:custom.tableThroughputs.default}
  # Load our webpack config
  webpack:
    webpackConfig: ./webpack.config.js
    includeModules: true
```

여기에 시간을 투자할만한 가치가 있는 몇 가지를 추가했습니다.

- 먼저 `stage`라는 사용자 정의 변수를 만듭니다. `provider:` 블럭에 `stage: dev`가 이미 있는데 이것을 위해 커스텀 변수가 필요한 이유가 궁금 할 것입니다. `serverless deploy --stage $STAGE` 명령을 통해 설정한 값을 기반으로 프로젝트의 현재 stage를 구성하기 때문입니다. 또한 배포할 때 stage가 설정되지 않은 경우 provider 블럭에서 설정된 stage 값으로 대체됩니다. 그래서 `${opt:stage, self:provider.stage}`는 Serverless로 하여금 `opt:stage`(명령줄을 통해 전달된 값)를 먼저 체크하고, 만일 없다면 `self:provider.stage`(provider 블럭에 있는 값)를 참조하라는 내용입니다.

- 테이블 이름은 배포할 stage-`${self:custom.stage}-notes`에 따라 달라집니다. 이것이 동적으로 설정되는 이유는 새로운 stage(환경)에 배포할 때, 별도의 테이블을 만들기 때문입니다. 그래서 우리가 `dev`에 전개할 때에는 `dev-notes`라는 DynamoDB 테이블을 생성 할 것이고 `prod`에 전개 할 때에는 `prod-notes`를 생성할 것입니다. 이를 통해 우리는 다양한 환경에서 사용하는 리소스(및 데이터)를 명확하게 구분할 수 있습니다.

- 이제 테이블에 대한 읽기/쓰기 용량을 프로비저닝하는 방법을 구성하려고 합니다. 특히 우리는 프로덕션 환경이 dev(프로덕션 환경이 아닌 다른 환경) 보다 높은 처리량을 갖도록하고 싶습니다. 이를 위해 우리는`tableThroughputs`라는 커스텀 변수를 만들었습니다. 이 변수는 `prod` 와 `default`라고하는 두 개의 개별적인 설정을 가지고 있습니다. `prod` 옵션은 `5`로 설정되어 있고 `default`(프로덕션 환경이 아닌 모든 경우에 사용)는 `1`로 설정되어 있습니다.

- 마지막으로, 우리는 `tableThroughput: ${self:custom.tableThroughputs.${self:custom.stage}, self:custom.tableThroughputs.default}`을 위 두 가지 옵션을 구현하기 위해 사용합니다. 위의 DynamoDB 리소스에서 사용한 `tableThroughput`이라는 사용자 정의 변수를 만듭니다. 이것은 `tableThroughputs` 변수에서 관련 옵션을 찾도록 설정됩니다(복수형 참고). 예를 들어, 우리가 프로덕션 stage라면 처리량은 `self:custom.tableThroughputs.prod`에 기준으로 설정할 것입니다. 그러나 `alpha`라는 stage에 있다면 존재하지 않는 `self:custom.tableThroughputs.alpha`를 참조하려고 할 것입니다. 그래서 `self:custom.tableThroughputs.default`로 대체 될 것이고, `1`로 설정되어 있습니다.

위의 많은 내용들은 꽤 까다롭고 지나치게 복잡하게 보일지도 모릅니다. 그러나 우리는 전체 설정을 자동화하고 복제할 수 있도록 설정하고자 합니다 .

또한 생성하려는 DynamoDB 리소스를 참조할 수 있도록 변경을 빠르게 처리하겠습니다.

{%change%} `serverless.yml`의 `iamRoleStatements:` 블럭을 다음으로 대체하십시오.

``` yml
  # These environment variables are made available to our functions
  # under process.env.
  environment:
    tableName: ${self:custom.tableName}

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
      # Restrict our IAM role permissions to
      # the specific table for the stage
      Resource:
        - "Fn::GetAtt": [ NotesTable, Arn ]
```

**들여 쓰기를 올바르게 복사했는지** 확인하세요. 이 두 블록은 `provider` 블록 아래에 들여 쓰기해야합니다.

여기서 처리하는 몇 가지 흥미로운 것들:

1. `environment:` 블럭은 기본적으로 Serverless Framework에게 람다 함수에서 변수를 `process.env`로 사용할 수 있도록 설정하고 있습니다. 예를 들어, `process.env.tableName`은 이 stage의 DynamoDB 테이블 이름으로 설정됩니다. 나중에 데이터베이스를 연결할 때 필요합니다.

2. 특히 `tableName`에 대해서는 위의 사용자 정의 변수를 참조하고 있습니다.

3. `iamRoleStatements:`의 경우에는 연결하고자하는 테이블을 명시하고 있습니다. 이 블럭은 람다 함수가 액세스할 수 있는 유일한 리소스라는 것을 AWS에 전달합니다.

### 코드 커밋 


{%change%} 지금까지 수정한 내용을 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding our DynamoDB resource"
```

다음으로 파일 업로드를 위해 S3 버킷을 추가합니다.
