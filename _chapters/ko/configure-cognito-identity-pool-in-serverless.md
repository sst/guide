---
layout: post
title: Configure Cognito Identity Pool in Serverless
date: 2018-03-02 00:00:00
lang: ko
description: serverless.yml에서 CloudFormation을 사용하여 Infrastructure as Code 패턴으로 사용하여 Cognito Identity 풀을 정의할 수 있습니다. 우리는 사용자 풀을 Cognito Identity Provider로 설정하려고합니다. S3 Bucket 및 API Gateway 엔드 포인트에 대한 액세스를 허용하는 정책으로 Auth Role을 정의하십시오. 
context: true
comments_id: configure-cognito-identity-pool-in-serverless/165
ref: configure-cognito-identity-pool-in-serverless
---

본 튜토리얼의 첫 번째 파트를 상기해 보면, 로그인한 사용자가 액세스할 수있는 AWS 리소스를 제어하는 방법으로 Cognito Identity Pool을 사용합니다. 또한 Cognito 사용자 풀을 인증 공급자로 연결합니다.

### 리소스 만들기

<img class="code-marker" src="/assets/s.png" />`resources/cognito-identity-pool.yml`에 다음 내용을 추가합니다.

``` yml
Resources:
  # The federated identity for our user pool to auth with
  CognitoIdentityPool:
    Type: AWS::Cognito::IdentityPool
    Properties:
      # Generate a name based on the stage
      IdentityPoolName: ${self:custom.stage}IdentityPool
      # Don't allow unathenticated users
      AllowUnauthenticatedIdentities: false
      # Link to our User Pool
      CognitoIdentityProviders:
        - ClientId:
            Ref: CognitoUserPoolClient
          ProviderName:
            Fn::GetAtt: [ "CognitoUserPool", "ProviderName" ]
            
  # IAM roles
  CognitoIdentityPoolRoles:
    Type: AWS::Cognito::IdentityPoolRoleAttachment
    Properties:
      IdentityPoolId:
        Ref: CognitoIdentityPool
      Roles:
        authenticated:
          Fn::GetAtt: [CognitoAuthRole, Arn]
          
  # IAM role used for authenticated users
  CognitoAuthRole:
    Type: AWS::IAM::Role
    Properties:
      Path: /
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: 'Allow'
            Principal:
              Federated: 'cognito-identity.amazonaws.com'
            Action:
              - 'sts:AssumeRoleWithWebIdentity'
            Condition:
              StringEquals:
                'cognito-identity.amazonaws.com:aud':
                  Ref: CognitoIdentityPool
              'ForAnyValue:StringLike':
                'cognito-identity.amazonaws.com:amr': authenticated
      Policies:
        - PolicyName: 'CognitoAuthorizedPolicy'
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: 'Allow'
                Action:
                  - 'mobileanalytics:PutEvents'
                  - 'cognito-sync:*'
                  - 'cognito-identity:*'
                Resource: '*'
              
              # Allow users to invoke our API
              - Effect: 'Allow'
                Action:
                  - 'execute-api:Invoke'
                Resource:
                  Fn::Join:
                    - ''
                    -
                      - 'arn:aws:execute-api:'
                      - Ref: AWS::Region
                      - ':'
                      - Ref: AWS::AccountId
                      - ':'
                      - Ref: ApiGatewayRestApi
                      - '/*'
              
              # Allow users to upload attachments to their
              # folder inside our S3 bucket
              - Effect: 'Allow'
                Action:
                  - 's3:*'
                Resource:
                  - Fn::Join:
                    - ''
                    -
                      - Fn::GetAtt: [AttachmentsBucket, Arn]
                      - '/private/'
                      - '$'
                      - '{cognito-identity.amazonaws.com:sub}/*'
  
# Print out the Id of the Identity Pool that is created
Outputs:
  IdentityPoolId:
    Value:
      Ref: CognitoIdentityPool
```

여기서 많은 작업이 일어나고 있는 것처럼 보입니다. 그러나 우리가 [Cognito ID 풀 만들기]({% link _chapters/create-a-cognito-identity-pool.md %}) 챕터에서했던 것과 거의 같습니다. CloudFormation이 보다 자세한 정보일 수 있으며 약간 어렵게 보일 수도 있습니다.

이 구성의 여러 부분을 빠르게 살펴 보겠습니다.

1. 먼저 `${self:custom.stage}`를 사용하여 스테이지 이름을 기준으로 자격 증명 풀의 이름을 지정합니다.

2. `AllowUnauthenticatedIdentities:false`를 추가하여 로그인한 사용자만 원한다고 설정했습니다.

3. 다음으로 사용자 풀을 ID 공급자로 사용하겠다고 명시합니다. 우리는 특별히 `Ref:CognitoUserPoolClient` 라인을 사용하여 이를 수행합니다. 다시 [Serverless에서 Cognito 사용자 풀 만들기]({% link _chapters/configure-cognito-user-pool-in-serverless.md %}) 챕터를 참조하면 `CognitoUserPoolClient` 블럭이 있음을 알 수 있습니다. 그리고 여기에서 참조하고있다.

4. 그런 다음 인증된 사용자에게 IAM 역할을 부여합니다.

5. 이 역할에 다양한 요소를 추가합니다. 이것은 우리가 [Cognito ID 풀 만들기]({% link _chapters/create-a-cognito-identity-pool.md %}) 챕터에서 사용하는 방법과 같습니다. CloudFormation을 사용하려면 이 방법으로 포맷해야합니다.

6. `apiGatewayRestApi` ref는 serverless 프레임 워크가 `serverless.yml`에서 API 엔드포인트를 정의할 때 생성됩니다. 따라서이 경우에는 생성중인 API 리소스를 참조하고 있습니다.

7. S3 버킷은 이름이 AWS에 의해 자동으로 생성됩니다. 따라서 이 경우 정확한 이름을 얻기 위해`Fn::GetAtt:[AttachmentsBucket, Arn]`을 사용합니다.

8. 마지막으로 생성된 자격 증명 풀 ID를 `Outputs:` 블럭에 출력합니다.

### 리소스 추가

<img class="code-marker" src="/assets/s.png" />`serverless.yml`에서 `resources:` 블럭을 다음으로 대체하십시오.

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
  - ${file(resources/cognito-identity-pool.yml)}
```

### 코드 커밋

<img class="code-marker" src="/assets/s.png" />지금까지 변경 사항을 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding our Cognito Identity Pool resource"
```

다음으로 환경 변수를 사용하여 Lambda 함수에서 DynamoDB 테이블을 빠르게 참조하도록 변경합니다.
