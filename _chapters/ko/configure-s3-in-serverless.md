---
layout: post
title: Configure S3 in Serverless
date: 2018-02-28 00:00:00
lang: ko
description: serverless.yml에서 CloudFormation을 사용하여 Infrastructure as Code 패턴으로 사용하여 S3 버킷을 정의 할 수 있습니다. 우리는 CORS 정책을 설정하고 생성된 버켓의 이름을 출력 할 것입니다.
context: true
comments_id: configure-s3-in-serverless/163
ref: configure-s3-in-serverless
---

이제 DynamoDB를 구성했으므로 serverless.yml을 통해 S3 파일 업로드 버킷을 구성하는 방법을 살펴 보겠습니다.

### 리소스 만들기


<img class="code-marker" src="/assets/s.png" />`resources/s3-bucket.yml` 파일을 만들고 아래 내용을 추가합니다.

``` yml
Resources:
  AttachmentsBucket:
    Type: AWS::S3::Bucket
    Properties:
      # Set the CORS policy
      CorsConfiguration:
        CorsRules:
          -
            AllowedOrigins:
              - '*'
            AllowedHeaders:
              - '*'
            AllowedMethods:
              - GET
              - PUT
              - POST
              - DELETE
              - HEAD
            MaxAge: 3000

# Print out the name of the bucket that is created
Outputs:
  AttachmentsBucketName:
    Value:
      Ref: AttachmentsBucket
```

[파일 업로드를 위한 S3 버킷 생성]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) 챕터를 떠올려 보면 버킷을 만들고 CORS 정책을 구성했습니다. 프론트엔드 클라이언트에서 직접 업로드를 해야만 했기 때문에 이 작업을 수행해야 했습니다. 여기서도 동일한 정책을 구성합니다.

S3 버킷(DynamoDB 테이블과 달리)은 전역적으로 이름이 지정됩니다. 그래서 사전에 적합한 이름이 무엇인지를 알 수가 없습니다. 따라서 CloudFormation에서 버킷 이름을 생성하게하고 나중에 출력할 수 있도록 `Outputs:` 블럭을 추가합니다.

### 리소스 추가

<img class="code-marker" src="/assets/s.png" />`serverless.yml`에서 자원을 참조합니다. `resources :` 블럭을 다음으로 대체하십시오.

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
  # DynamoDB
  - ${file(resources/dynamodb-table.yml)}
  # S3
  - ${file(resources/s3-bucket.yml)}
```

### 코드 커밋

<img class="code-marker" src="/assets/s.png" />지금까지 변경한 내용을 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding our S3 resource"
```

다음으로 Cognito 사용자 풀 구성에 대해 살펴 보겠습니다.
