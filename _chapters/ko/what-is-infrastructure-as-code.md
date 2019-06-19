---
layout: post
title: What Is Infrastructure as Code
date: 2018-02-26 00:00:00
lang: ko
description: Infrastructure as code in Serverless is a way of programmatically defining the resources your project is going to use. In the case of Serverless Framework, these are defined in the serverless.yml.
context: true
comments_id: what-is-infrastructure-as-code/161
ref: what-is-infrastructure-as-code
---

[Serverless Framework](https://serverless.com)은 `serverless.yml`을 [CloudFormation](https://aws.amazon.com/cloudformation) 템플릿으로 변환합니다. 이 템플릿은 severless 프로젝트를 구성하는 일부 인프라의 기술서입니다. 우리의 경우에는 이전에 구성했었던 람다 함수와 API 게이트웨이 엔드포인트를 기술하고 있습니다.

그러나 Part I에서는 DynamoDB 테이블, Cognito User Pool, S3 업로드 버킷 및 Cognito Identity 풀을 AWS Console을 통해 만들었습니다. 콘솔을 통해 수동으로 구성하는 대신 프로그래밍 방식으로 구성할 수 있는지 궁금 할 것입니다. 물론 확실히 할 수 있습니다!

이 일반적인 패턴을 **Infrastructure as code**라고하며, 큰 장점이 있습니다. 첫째, 몇 가지 간단한 명령으로 설정을 복제 할 수 있습니다. 둘째, 수작으로 하는 것처럼 오류가 발생하기 쉽지 않습니다. 우리는 튜토리얼을 진행하면서 각 단계에 따라 설정 관련 문제가 발생했다는 것을 알고 있습니다. 또한 전체 인프라를 코드로 기술하면 여러 환경을 아주 쉽게 작성할 수 있습니다. 예를 들어, 작업할 때 모든 변경 사항을 만들고 테스트를 할 수있는 dev 환경을 만들 수 있습니다. 또한 사용자가 상호 작용하는 프로덕션 환경과 별도로 유지할 수 있습니다.

다음 챕터에서 우리는 `serverless.yml`을 통해 다양한 인프라 요소들을 구성할 것입니다.

그럼 `serverless.yml`에서 DynamoDB를 구성해 보겠습니다.

