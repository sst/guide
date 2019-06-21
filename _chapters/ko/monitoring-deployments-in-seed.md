---
layout: post
title: Monitoring Deployments in Seed
date: 2018-03-17 00:00:00
lang: ko
description: Lambda 기능 및 API 게이트웨이 엔드포인트에 대한 CloudWatch 로그 및 메트릭을보고 Seed에서 Serverless 배포를 모니터링할 수 있습니다. Seed 콘솔에서 API 게이트웨이에 대한 액세스 로그를 사용할 수도 있습니다. 
context: true
code: backend_full
comments_id: monitoring-deployments-in-seed/180
ref: monitoring-deployments-in-seed
---

우리가 아무리 최선을 다해도 잘못된 코드가 운영에 배포되는 사례가 발생할 수 있습니다. 그럴경우 이에 대한 계획을 가지고 있어야합니다. [Seed](https://seed.run)에서 어떻게 처리하는지 살펴 보겠습니다.

### 잘못된 코드 푸시

먼저 분명히 잘못된 코드를 push 하십시오.

<img class="code-marker" src="/assets/s.png" />`functions/create.js` 파일의 맨 위 함수에 다음을 추가합니다. 

``` js
gibberish.what;
```

`gibberish` 변수가 없기 때문에 이 코드는 실패해야합니다.

<img class="code-marker" src="/assets/s.png" />dev에 커밋하고 푸시합니다.

``` bash
$ git add .
$ git commit -m "Making a mistake"
$ git push
```

빌드가 진행된는 것을 확인할 수 있습니다. 잠시 후 완료되면 **Promote**를 클릭합니다.

![변경 사항을 prod에 Promote 시키는 화면](/assets/part2/promote-changes-to-prod.png)


**Confirm**을 눌러 변경 세트를 확인합니다.

![변경 세트 운영 확인 화면](/assets/part2/confirm-changeset-to-prod.png)

### Access Logs 활성화

이제 오류 코드를 테스트하기 전에 API 게이트웨이 액세스 로그를 켜면 오류를 확인할 수 있습니다. **prod** stage **View Resources**를 클릭하십시오.

![운영 배포 보기 화면](/assets/part2/click-view-deployment-in-prod.png)

**Settings**을 클릭합니다.

![운영 배포 설정을 클릭하는 화면](/assets/part2/click-deployment-settings-in-prod.png)

**Enable Access Logs**를 클릭합니다.

![운영 access logs 활성화 화면](/assets/part2/enable-access-logs-in-prod.png)

이 작업에는 몇 분이 걸리지 만 Seed는 자동으로 이 작업에 필요한 IAM 역할을 구성하고 사용중인 환경에 대한 API 게이트웨이 액세스 로그를 사용합니다.

### 오류 코드 테스트


이제 코드를 테스트하기 위해 [마지막 챕터]({% link _chapters/test-the-configured-apis.md %})에서 동일한 명령을 실행하여 API를 테스트하십시오.

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

prod 버전의 리소스를 사용하고 있습니다.

다음과 같은 오류가 표시되어야합니다.

``` bash
Authenticating with User Pool
Getting temporary credentials
Making API request
{ status: 502,
  statusText: 'Bad Gateway',
  data: { message: 'Internal server error' } }
```

### 로그와 지표 보기

Seed 콘솔로 돌아가서 **Access Logs**를 클락합니다.

![운영 access logs 클릭 화면](/assets/part2/click-access-logs-in-prod.png)

최근 요청에 `502`에러가 보여야 합니다.

![운영 access logs  보기 화면](/assets/part2/view-access-logs-in-prod.png)

이전 화면으로 돌아가서 요청들에 대한 개략적인 정보를 보기 위해 **Metrics**를 클릭할 수 있습니다.

![운영 API 지표 화면](/assets/part2/click-api-metrics-in-prod.png)

4xx 에러, 5xx 에러, 요청에 대한 지연시간 및 이전에 생성했던 여러 요청들을 확인 할 수 있습니다.

![운영 API 지표 보기 화면](/assets/part2/view-api-metrics-in-prod.png)

이제 다시 돌아가서 **생성된** 람다 함수의 **Logs**를 클릭합니다.

![운영 람다 로그 클릭하기 화면](/assets/part2/click-lambda-logs-in-prod.png)

이렇게하면 코드에 오류가 있다는 것을 분명하게 보여줄 것입니다. `gibberish`가 정의되어 있지 않다고 불평하고 있습니다.

![운영 람다 로그 보기 화면](/assets/part2/view-lambda-logs-in-prod.png)

또한 API 지표 항목과 마찬가지로 Lambda 지표 항목은 함수 수준에서 수행중인 작업에 대한 개요를 보여줍니다.

![운영 람라 지표 보기 화면](/assets/part2/view-lambda-metrics-in-prod.png)

### 운영에서의 롤백

이제 분명히 문제가 있다는 것을 확인했습니다. 일반적으로 코드를 수정하고 변경 사항을 적용하고 다시 배포하려는 유혹을받을 수 있습니다. 그러나 사용자가 잘못된 배포로 인해 영향을 받을 수 있으므로 즉시 변경 사항을 롤백해야합니다.

이렇게하려면 **prod** stage로 돌아가십시오. 운영에서 사용했던 이전 빌드의 **Rollback** 버튼을 누르십시오.

![운영 롤백 클릭 화면](/assets/part2/click-rollback-in-prod.png)

Seed는 과거 빌드를 추적하고 이전에 빌드된 패키지를 사용하여 다시 배포합니다.

![운영 롤백 완료 화면](/assets/part2/rollback-complete-in-prod.png)

그리고 지금부터 테스트 명령을 실행하면됩니다.

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

성공하면 아래와 같은 결과를 볼 수 있습니다.

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

### 코드 되돌리기

<img class="code-marker" src="/assets/s.png"/> 마지막으로 `functions/create.js`에서 코드를 이전으로 되돌리는 것을 잊지 마십시오.

```js
gibberish.what;
```

<img class="code-marker" src="/assets/s.png"/> 변경을 커밋하고 푸시합니다.

```bash

$ git add.
$ git commit -m "Fixing the mistake"
$ git push

```

됐습니다! 이제 프론트엔드에 연결할 준비가되었습니다.
