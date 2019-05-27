---
layout: post
title: Create a Cognito Test User
date: 2016-12-28 12:00:00
description: Cognito 사용자 풀을 serverless API 백엔드의 승인자로 사용하여 테스트하려면 테스트 사용자를 생성해야합니다. aws cognito-idp 가입 및 admin-confirm-sign-up 명령을 사용하여 AWS CLI에서 사용자를 만들 수 있습니다.
lang: ko
ref: create-a-cognito-test-user
context: true
comments_id: create-a-cognito-test-user/126
---

이 장에서는 Cognito 사용자 풀에 대한 테스트 사용자를 생성 할 것입니다. 나중에 앱의 인증 부분을 테스트하기 위해이 사용자가 필요합니다.

### 사용자 만들기

먼저 AWS CLI를 사용하여 이메일과 비밀번호로 사용자를 등록합니다.

<img class="code-marker" src="/assets/s.png" />여러분의 터미널에서 실행합니다.

``` bash
$ aws cognito-idp sign-up \
  --region YOUR_COGNITO_REGION \
  --client-id YOUR_COGNITO_APP_CLIENT_ID \
  --username admin@example.com \
  --password Passw0rd!
```

이제 사용자는 Cognito 사용자 풀에서 생성됩니다. 그러나 사용자가 사용자 풀을 사용하여 인증을 받기 전에 계정을 확인해야합니다. 관리자 명령을 사용하여 사용자를 신속하게 확인해 봅시다.

<img class="code-marker" src="/assets/s.png" />여러분의 터미널에서 실행합니다.

``` bash
$ aws cognito-idp admin-confirm-sign-up \
  --region YOUR_COGNITO_REGION \
  --user-pool-id YOUR_COGNITO_USER_POOL_ID \
  --username admin@example.com
```

이제 테스트 사용자가 준비되었습니다. 다음으로 Serverless Framework를 설정하여 백엔드 API를 작성하십시오.
