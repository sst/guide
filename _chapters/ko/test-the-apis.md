---
layout: post
title: Test the APIs
date: 2017-01-05 18:00:00
description: IAM 및 Cognito 사용자 풀을 사용하여 인증 요청이 반영된 서버리스 백엔드 API를 테스트하려면 몇 단계를 수행해야합니다. 먼저 사용자 풀을 사용하여 인증하여 사용자 토큰을 생성합니다. 그런 다음 사용자 토큰을 사용하여 자격 증명 풀을 사용하여 임시 IAM 자격 증명을 가져옵니다. 마지막으로 IAM 자격 증명으로 API를 서명(Signature Version 4) 처리하여 요청합니다. 이 프로세스를 단순화하기 위해 "aws-api-gateway-cli-test" 도구를 사용할 것입니다. 
lang: ko
ref: test-the-apis
context: true
code: backend_part1
comments_id: comments-for-test-the-apis/122
---

이제 백엔드를 완전히 설정하고 인증을 설정했으므로 방금 배포 한 API를 테스트해 보겠습니다.

API 엔드포인트를 안전하게 사용하려면 다음 단계를 따라야합니다.

1. 사용자 풀에 대해 인증하고 사용자 토큰을 획득하십시오.
2. 사용자 토큰으로 자격 증명 풀에서 임시 IAM 자격 증명을 가져옵니다.
3. IAM 자격 증명을 사용하여 Google API 요청에 [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html으로)으로 서명합니다.
서명하십시오.

이러한 과정들은 모두 손수 해야하는 작업으로 다소 까다로울 수 있습니다. 그래서 [AWS API Gateway Test CLI](https://github.com/AnomalyInnovations/aws-api-gateway-cli-test)라고 불리는 간단한 도구를 만들었습니다.

이를 사용하려면 다음을 실행하십시오.

``` bash
$ npx aws-api-gateway-cli-test
```

`npx` 명령은 패키지를 전역적으로 설치하지 않고 NPM 모듈을 바로 실행할 수 있는 편리한 방법입니다.

이제 위 단계를 완료하기 위해 많은 정보를 전달해야합니다.

- [Cognito 테스트 사용자 만들기]({% link _chapters/create-a-cognito-test-user.md %}) 챕터에서 만든 사용자 이름과 암호를 이용하기 
- [Cognito 사용자 풀 만들기]({% link _chapters/create-a-cognito-user-pool.md %}) 챕터에서 생성한 값으로 **YOUR_COGNITO_USER_POOL_ID**, **YOUR_COGNITO_APP_CLIENT_ID**, 그리고 **YOUR_COGNITO_REGION** 를 바꾸기. 여기서 사용하는 리전은 `us-east-1` 입니다.
-[Cognito 자격 증명 풀 만들기]({% link _chapters/create-a-cognito-identity-pool.md %}) 챕터에서 생성한 값으로 **YOUR_IDENTITY_POOL_ID** 를 바꾸기.
- [API 배포하기]({% link _chapters/deploy-the-apis.md %}) 챕터에서 생성한 값으로 **YOUR_API_GATEWAY_URL** 와 **YOUR_API_GATEWAY_REGION**을 바꾸기. 여기서는 `https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod` 와 `us-east-1`를 사용합니다.

그리고 다음 내용을 실행합니다.

``` bash
$ npx aws-api-gateway-cli-test \
--username='admin@example.com' \
--password='Passw0rd!' \
--user-pool-id='YOUR_COGNITO_USER_POOL_ID' \
--app-client-id='YOUR_COGNITO_APP_CLIENT_ID' \
--cognito-region='YOUR_COGNITO_REGION' \
--identity-pool-id='YOUR_IDENTITY_POOL_ID' \
--invoke-url='YOUR_API_GATEWAY_URL' \
--api-gateway-region='YOUR_API_GATEWAY_REGION' \
--path-template='/notes' \
--method='POST' \
--body='{"content":"hello world","attachment":"hello.jpg"}'
```

다소 거추장스러운 내용으로 보일 수도 있지만, 기본적인 HTTP 요청을하기 전에 사전에 보안 헤더를 생성하는 점에 주의해야합니다. React.js 앱을 API 백엔드에 연결할 때 이러한 과정을 더 많이 볼 수 있습니다.

Windows 사용자인 경우 아래 명령을 사용하십시오. 각 옵션 사이의 간격은 매우 중요합니다.

``` bash
$ npx aws-api-gateway-cli-test --username admin@example.com --password Passw0rd! --user-pool-id YOUR_COGNITO_USER_POOL_ID --app-client-id YOUR_COGNITO_APP_CLIENT_ID --cognito-region YOUR_COGNITO_REGION --identity-pool-id YOUR_IDENTITY_POOL_ID --invoke-url YOUR_API_GATEWAY_URL --api-gateway-region YOUR_API_GATEWAY_REGION --path-template /notes --method POST --body "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}"
```

아래와 유사한 결과를 보인다면 명령 실행이 성공한겁니다.

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
> 역자주: 만일 400번대 오류가 발생했다면 Test CLI 파라미터의 값을 다시 한 번 확인하시고, 500번대 오류가 발생했다면 CloudWatch 로그를 확인하세요. 권한 문제일 경우 `serverless.yml`에서 들여쓰기를 확인하세요.

이제 백엔드를 완성했습니다! 다음으로 앱의 프론트 엔드를 만드는 단계로 넘어가겠습니다.

---

#### 공통 문제

- `{status: 403}` 응답

이 응답은 가장 자주 접하는 공통되는 문제이며, 다소 일반적인 사항으로 디버깅하기가 어려울 수 있습니다. 다음은 디버깅을 시작하기 전에 확인해야할 몇 가지 사항입니다.

   -`apig-test` 명령의`--path-template` 옵션이`notes`가 아니라`/notes`를 가리키고 있는지 확인하십시오. 형식은 요청을 안전하게 서명하는데 중요합니다.

   - `YOUR_API_GATEWAY_URL`에는 슬래시가 없습니다. 예제의 경우 URL은`https ://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod`입니다. `/`로 끝나지 않습니다.

   - Windows에서 Git Bash를 사용하는 경우 `--path-template`에서 선행 슬래시를 제거하는 반면 `YOUR_API_GATEWAY_URL`에는 후행 슬래시를 추가하십시오. 예제의 경우 `--invoke-url https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/ --path-template notes`가 됩니다. 보다 궁금한 부분에 대해서는 [이 곳에서](https://github.com/AnomalyInnovations/serverless-stack-com/issues/112#issuecomment-345996566) 논의 하실 수 있습니다.

