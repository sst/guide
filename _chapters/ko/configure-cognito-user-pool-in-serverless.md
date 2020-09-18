---
layout: post
title: Configure Cognito User Pool in Serverless
date: 2018-03-01 00:00:00
lang: ko
description: serverless.yml에서 CloudFormation을 사용하여 Infrastructure as Code 패턴을 사용하여 Cognito 사용자 풀을 정의할 수 있습니다. 우리는 배포 stage에 따라 사용자 풀 및 앱 클라이언트 이름을 설정하려고합니다. 사용자 풀 및 앱 클라이언트 ID도 출력합니다.
context: true
comments_id: configure-cognito-user-pool-in-serverless/164
ref: configure-cognito-user-pool-in-serverless
---

이제 'serverless.yml'을 통해 Cognito 사용자 풀을 설정하는 방법을 살펴 보겠습니다. 이것은 [Cognito 사용자 풀 만들기]({% link _chapters/create-a-cognito-user-pool.md %}) 챕터에서 직접 작성한 것과 매우 유사해야합니다.

### 리소스 만들기

{%change%} `resources/cognito-user-pool.yml`에 아래 내용을 추가합니다.

``` yml
Resources:
  CognitoUserPool:
    Type: AWS::Cognito::UserPool
    Properties:
      # Generate a name based on the stage
      UserPoolName: ${self:custom.stage}-user-pool
      # Set email as an alias
      UsernameAttributes:
        - email
      AutoVerifiedAttributes:
        - email

  CognitoUserPoolClient:
    Type: AWS::Cognito::UserPoolClient
    Properties:
      # Generate an app client name based on the stage
      ClientName: ${self:custom.stage}-user-pool-client
      UserPoolId:
        Ref: CognitoUserPool
      ExplicitAuthFlows:
        - ADMIN_NO_SRP_AUTH
      GenerateSecret: false

# Print out the Id of the User Pool that is created
Outputs:
  UserPoolId:
    Value:
      Ref: CognitoUserPool

  UserPoolClientId:
    Value:
      Ref: CognitoUserPoolClient
```

여기서 뭘하고 있는지 빨리 알아 보겠습니다.

- 사용자 정의 변수 `${self: custom.stage}`를 사용하여 stage를 기반으로 사용자 풀(및 사용자 풀 앱 클라이언트)의 이름을 지정합니다.

- `UsernameAttributes`를 이메일로 설정하고 있습니다. 이것은 사용자가 사용자 이름으로 이메일을 사용하여 로그인할 수 있도록 사용자 풀에 알려줍니다.

- S3 버킷과 마찬가지로 CloudFormation에서 사용자 풀 ID와 생성된 사용자 풀 클라이언트 ID를 전달해야합니다. 끝 부분의 `Outputs:` 블럭에서 이 작업을 수행합니다.

### 리소스 추가

{%change%} `serverless.yml`에서 자원을 참조합니다. `resources:` 블럭을 다음으로 대체하십시오.

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
  # DynamoDB
  - ${file(resources/dynamodb-table.yml)}
  # S3
  - ${file(resources/s3-bucket.yml)}
  # Cognito
  - ${file(resources/cognito-user-pool.yml)}
```

### 코드 커밋 

{%change%} 지금까지 변경 내용을 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding our Cognito User Pool resource"
```

다음으로 Cognito Identity Pool을 구성하여 이 모든 것을 하나로 묶겠습니다.
