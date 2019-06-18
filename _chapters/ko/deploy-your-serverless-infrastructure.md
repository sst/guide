---
layout: post
title: Deploy Your Serverless Infrastructure
date: 2018-03-04 00:00:00
lang: ko
description: 인프라와 함께 Serverless Framework 프로젝트를 AWS에 배포하려면 serverless deploy -v 명령을 사용하십시오. 스택 출력이 배포의 일부로 표시됩니다. 
comments_id: deploy-your-serverless-infrastructure/167
ref: deploy-your-serverless-infrastructure
---

이제 모든 리소스가 구성되었으므로 전체 인프라를 배포하십시오.

현재 프로젝트는 자습서의 첫 번째 파트에서 작성한 모든 자원과 람다 함수가 포함되어 있습니다. 이것은 서버리스 프로젝트에서 일반적인 트렌드입니다. 여러분의 *코드* 및 *인프라*는 서로 다르게 취급되지 않습니다. 물론 프로젝트가 커짐에 따라 프로젝트가 분할됩니다. 따라서 다른 프로젝트가 람다 함수를 배포하는 동안 인프라를 배치하는 별도의 Serverless Framework 프로젝트가 있을 수 있습니다.

### 프로젝트 배포

`serverless deploy` 명령 덕분에 프로젝트의 배포는 매우 간단합니다. 따라서 프로젝트의 루트에서 이 작업을 실행하십시오.

``` bash
$ serverless deploy -v
```

결과는 다음과 같이 보여야합니다.:

``` bash
Serverless: Stack update finished...
Service Information
service: notes-app-2-api
stage: dev
region: us-east-1
stack: notes-app-2-api-dev
api keys:
  None
endpoints:
  POST - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes
  GET - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  GET - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes
  PUT - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
  DELETE - https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev/notes/{id}
functions:
  create: notes-app-2-api-dev-create
  get: notes-app-2-api-dev-get
  list: notes-app-2-api-dev-list
  update: notes-app-2-api-dev-update
  delete: notes-app-2-api-dev-delete

Stack Outputs
AttachmentsBucketName: notes-app-2-api-dev-attachmentsbucket-oj4rfiumzqf5
UserPoolClientId: ft93dvu3cv8p42bjdiip7sjqr
UserPoolId: us-east-1_yxO5ed0tq
DeleteLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-delete:2
CreateLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-create:2
GetLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-get:2
UpdateLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-update:2
IdentityPoolId: us-east-1:64495ad1-617e-490e-a6cf-fd85e7c8327e
BillingLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-billing:1
ListLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:232771856781:function:notes-app-2-api-dev-list:2
ServiceEndpoint: https://mqqmkwnpbc.execute-api.us-east-1.amazonaws.com/dev
ServerlessDeploymentBucketName: notes-app-2-api-dev-serverlessdeploymentbucket-1p2o0dshaz2qc
```

여기서 몇 가지 짚고 넘어가겠습니다.:

- `dev`라는 stage에 배포하고 있습니다. 이것은 `serverless.yml`에서 `provider:` 블록 아래에 설정되어 있습니다. `serverless deploy --stage $STAGE_NAME` 명령을 대신 실행하여 이를 명시적으로 전달할 수도 있습니다.

- deploy 명령(`-v` 옵션 사용)은 자원에 대한 요청의 결과를 출력합니다. 예를 들어, `AttachmentsBucketName`은 생성된 S3 파일 업로드 버킷이며 `UserPoolId`는 사용자 풀의 ID입니다.

- 마지막으로, deploy 명령을 실행해서 CloudFormation을 이용해 변경된 부분만 업데이트합니다. 따라서 전체 인프라를 처음부터 다시 만드는 것에 대한 걱정 없이 이 명령을 언제든지 실행할 수 있습니다.

자 이제 우리의 전체 인프라는 완전히 자동으로 구성 및 배포되도록 만들었습니다.

다음으로 3rd-party API를 사용하기 위해 새로운 API(및 람다 함수)를 추가합니다. 이 경우 Stripe을 사용하여 노트 앱의 사용자에게 청구할 API를 추가 할 예정입니다.
