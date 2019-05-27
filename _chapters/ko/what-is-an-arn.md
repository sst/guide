---
layout: post
title: What is an ARN
date: 2016-12-25 20:00:00
lang: ko
ref: what-is-an-arn
description: Amazon Resource Names (또는 ARN)은 AWS 리소스를 고유하게 식별합니다. 전 세계적으로 고유 한 식별자이며 몇 가지 미리 정의 된 형식을 따릅니다. ARN은 주로 리소스에 대한 참조를 전달하고 IAM 정책을 정의하는 데 사용됩니다.
context: true
comments_id: what-is-an-arn/34
---

지난 장에서 IAM 정책을 살펴볼 때 ARN을 사용하여 리소스를 지정하는 방법을 알아 봤습니다. ARN이 무엇인지 더 자세히 살펴 보겠습니다.

다음은 공식적인 정의입니다:

> Amazon Resource Names (ARNs)은 AWS 리소스를 고유하게 식별합니다. IAM 정책, Amazon RDS(Relational Database Service) 태그 및 API 호출과 같이 모든 AWS에서 자원을 명확하게 지정해야하는 경우 ARN이 필요합니다.

ARN은 실제로 개별 AWS 리소스에 대해 글로벌하게 유일한 식별자로서 다음 형식 중 하나를 취합니다.

```
arn:partition:service:region:account-id:resource
arn:partition:service:region:account-id:resourcetype/resource
arn:partition:service:region:account-id:resourcetype:resource
```

ARN의 몇 가지 예를 살펴 보겠습니다. 다른 형식들로 사용된 예입니다.

```
<!-- Elastic Beanstalk application version -->
arn:aws:elasticbeanstalk:us-east-1:123456789012:environment/My App/MyEnvironment

<!-- IAM 사용자 이름 -->
arn:aws:iam::123456789012:user/David

<!-- Amazon RDS 인스턴스의 태깅을 위해 사용 -->
arn:aws:rds:eu-west-1:123456789012:db:mysql-db

<!-- Amazon S3 bucket의 오브젝트-->
arn:aws:s3:::my_corporate_bucket/exampleobject.png
```

마지막으로 ARN의 일반적인 사용 사례를 살펴 보겠습니다.

1. 커뮤니케이션 

ARN은 여러 AWS 리소스가 포함된 시스템을 조율할 때 특정 리소스를 참조하는 데 사용됩니다. 예를 들어 RESTful API를 수신하고 API 경로 및 요청 메소드를 기반으로 해당하는 Lambda 함수를 호출하는 API 게이트웨이가 있습니다. 라우팅은 다음과 같습니다.

   ```
   GET /hello_world => arn:aws:lambda:us-east-1:123456789012:function:lambda-hello-world
   ```

2. IAM 정책 

지난 장에서 이미 자세히 살펴 봤으니 여기서는 정책 정의의 예제만 보여드리겠습니다.

   ``` json
   {
     "Version": "2012-10-17",
     "Statement": {
       "Effect": "Allow",
       "Action": ["s3:GetObject"],
       "Resource": "arn:aws:s3:::Hello-bucket/*"
   }
   ```
   
ARN은 액세스 권한이 부여되는 리소스(이 경우 S3 버킷)를 정의하는 데 사용됩니다. 와일드 카드`*`문자는 여기서 *Hello-bucket* 내부의 모든 자원을 일치시키는 데 사용됩니다.

다음으로 AWS CLI를 구성 해 보겠습니다. 이전에 생성 IAM 사용자 계정의 정보를 사용합니다.
