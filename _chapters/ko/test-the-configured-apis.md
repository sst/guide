---
layout: post
title: Test the Configured APIs
date: 2018-03-16 00:00:00
lang: ko
description: Seed를 사용하여 배포된 Serverless API를 테스트하십시오. 이렇게하려면 aws-api-gateway-cli-test의 NPM 패키지를 사용하고 운영 환경과 개발 환경을 모두 테스트하십시오. 
comments_id: test-the-configured-apis/179
ref: test-the-configured-apis
---

이제 두 세트의 API(prod 및 dev)가 있습니다. 프론트엔드를 플러그인에 연결하기 전에 신속하게 테스트하여 제대로 작동하는지 확인하십시오. [API 테스트]({% link _chapters/test-the-apis.md %}) 챕터에서 [AWS API Gateway Test CLI](https://github.com/AnomalyInnovations/aws-api-gateway-cli-test)라는 간단한 유틸리티를 사용했습니다.

테스트를 수행하기 전에 두 환경에 대한 테스트 사용자를 생성하십시오. [Cognito 테스트 사용자 만들기]({% link _chapters/create-a-cognito-test-user.md %}) 챕터와 동일한 과정입니다.

### 테스트 사용자 생성

이를 위해 AWS CLI를 사용할 것입니다.

<img class="code-marker" src="/assets/s.png" />터미널에서 다음을 실행합니다.

``` bash
$ aws cognito-idp sign-up \
  --region YOUR_DEV_COGNITO_REGION \
  --client-id YOUR_DEV_COGNITO_APP_CLIENT_ID \
  --username admin@example.com \
  --password Passw0rd!
```

Cognito App Client ID의 **dev** 버전을 찾으려면 [Seed를 통한 배포]({% link _chapters/deploying-through-seed.md %}) 챕터를 참조하십시오. 그리고`YOUR_DEV_COGNITO_REGION`을 배포한 지역으로 대체하십시오.

<img class="code-marker" src="/assets/s.png"/> 다음으로 Cognito Admin CLI를 통해 사용자를 확인합니다.

``` bash
$ aws cognito-idp admin-confirm-sign-up \
  --region YOUR_DEV_COGNITO_REGION \
  --user-pool-id YOUR_DEV_COGNITO_USER_POOL_ID \
  --username admin@example.com
```

리전과 `YOUR_DEV_COGNITO_USER_POOL_ID`를 [Seed를 통한 배포]({% link _chapters/deploying-through-seed.md %}) 챕터의 Cognito User Pool ID의 **dev** 버전으로 대체하십시오. 

**prod** 버전에서도 동일한 작업을 신속하게 수행합니다.

<img class="code-marker" src="/assets/s.png" />터미널에서 다음을 실행합니다.

``` bash
$ aws cognito-idp sign-up \
  --region YOUR_PROD_COGNITO_REGION \
  --client-id YOUR_PROD_COGNITO_APP_CLIENT_ID \
  --username admin@example.com \
  --password Passw0rd!
```

prod 버전의 Cognito 상세 정보를 이용합니다.

<img class="code-marker" src="/assets/s.png" />그리고 사용자를 확인합니다.

``` bash
$ aws cognito-idp admin-confirm-sign-up \
  --region YOUR_PROD_COGNITO_REGION \
  --user-pool-id YOUR_PROD_COGNITO_USER_POOL_ID \
  --username admin@example.com
```

여기서도 prod 버전을 사용해야합니다.

이제 API를 테스트할 준비가되었습니다.

### API 테스트

dev 엔드 포인트를 테스트해 봅시다. 다음 명령을 실행하십시오.

``` bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='YOUR_DEV_COGNITO_USER_POOL_ID' \
--app-client-id='YOUR_DEV_COGNITO_APP_CLIENT_ID' \
--cognito-region='YOUR_DEV_COGNITO_REGION' \
--identity-pool-id='YOUR_DEV_IDENTITY_POOL_ID' \
--invoke-url='YOUR_DEV_API_GATEWAY_URL' \
--api-gateway-region='YOUR_DEV_API_GATEWAY_REGION' \
--path-template='/notes' \
--method='POST' \
--body='{"content":"hello world","attachment":"hello.jpg"}'
```

다음을 위해 [Seed를 통한 배포]({% link _chapters/deploying-through-seed.md %}) 챕터를 참조하십시오.

- `YOUR_DEV_COGNITO_USER_POOL_ID` 및 `YOUR_DEV_COGNITO_APP_CLIENT_ID`는 모두 사용자의 Cognito 사용자 풀과 관련이 있습니다.
- `YOUR_DEV_IDENTITY_POOL_ID`는 여러분의 Cognito ID 풀을 위한 것입니다.
- 그리고 `YOUR_DEV_API_GATEWAY_URL`은 API 게이트웨이 엔드포인트입니다. `https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/dev`와 유사하게 보일겁니다. 그러나 사용자 정의 도메인으로 구성한 경우 [사용자 정의 도메인을 통해 시드 설정]({% link _chapters/set-custom-domains-through-seed.md %}) 챕터를 사용하십시오.
- 마지막으로, `YOUR_DEV_API_GATEWAY_REGION` 과 `YOUR_DEV_COGNITO_REGION`은 배포한 지역입니다. 여기서는 `us-east-1`입니다.

명령이 성공하면 다음과 같이 보일 것입니다.

``` bash
Authenticating with User Pool
Getting temporary credentials
Making API request
{ status: 200,
  statusText: 'OK',
  data: 
   { userId: 'us-east-1:9bdc031d-ee9e-4ffa-9a2d-123456789',
     noteId: '8f7da030-650b-11e7-a661-123456789',
     content: 'hello world',
     attachment: 'hello.jpg',
     createdAt: 1499648598452 } }
```

prod에 대해서도 같은 명령을 실행하십시오. prod 버전을 사용해야합니다.

``` bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='YOUR_PROD_COGNITO_USER_POOL_ID' \
--app-client-id='YOUR_PROD_COGNITO_APP_CLIENT_ID' \
--cognito-region='YOUR_PROD_COGNITO_REGION' \
--identity-pool-id='YOUR_PROD_IDENTITY_POOL_ID' \
--invoke-url='YOUR_PROD_API_GATEWAY_URL' \
--api-gateway-region='YOUR_PROD_API_GATEWAY_REGION' \
--path-template='/notes' \
--method='POST' \
--body='{"content":"hello world","attachment":"hello.jpg"}'
```

그리고 dev와 비슷한 출력을 보게 될 것입니다.

이제 테스트한 API가 프론트엔드에 플러그인 될 준비가 되었습니다. 그러나 그렇게하기 전에, 실수를하고 잘못된 코드를 운영에 적용한다면 어떤 일이 벌어질지 빨리 확인해 봅시다.
