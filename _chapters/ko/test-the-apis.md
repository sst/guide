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

이제 백엔드를 완성했습니다! 다음으로 앱의 프론트 엔드를 만드는 단계로 넘어가겠습니다.

---

#### 공통 문제

- `{status: 403}` 응답

이 응답은 가장 자주 접하는 공통되는 문제이며, 다소 일반적인 사항으로 디버깅하기가 어려울 수 있습니다. 다음은 디버깅을 시작하기 전에 확인해야할 몇 가지 사항입니다.

   - `apig-test` 명령의`--path-template` 옵션이`notes`가 아니라`/notes`를 가리키고 있는지 확인하십시오. 형식은 요청을 안전하게 서명하는데 중요합니다.

   - `YOUR_API_GATEWAY_URL`에는 슬래시가 없습니다. 예제의 경우 URL은`https ://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod`입니다. `/`로 끝나지 않습니다.

   - Windows에서 Git Bash를 사용하는 경우 `--path-template`에서 선행 슬래시를 제거하는 반면 `YOUR_API_GATEWAY_URL`에는 후행 슬래시를 추가하십시오. 예제의 경우 `--invoke-url https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/ --path-template notes`가 됩니다. 보다 궁금한 부분에 대해서는 [이 곳에서](https://github.com/AnomalyInnovations/serverless-stack-com/issues/112#issuecomment-345996566) 논의 하실 수 있습니다.

 람다 함수가 호출되기 전에도이 오류가 발생할 가능성이 큽니다. 따라서 IAM 역할이 자격 증명 풀에 대해 올바르게 구성되어 있는지 확인할 필요가 있습니다. [서버리스 API 문제 디버깅]({% link _chapters/debugging-serverless-api-issues.md %}#missing-iam-policy) 챕터에 설명 된 단계를 수행하여 IAM 역할에 올바른 권한이 정의되어 있는지 확인하십시오.

  다음으로 [API 게이트웨이 로그 사용]({% link _chapters/api-gateway-and-lambda-logs.md %}#enable-api-gateway-cloudwatch-logs) 및 [지침] ({% link _chapters/api-gateway-and-lambda-logs.md %}#viewing-api-gateway-cloudwatch-logs)를 사용하여 기록중인 로그를 조회합니다. 무슨 일이 일어났는지 더 잘 이해할 수 있습니다.

  마지막으로, 아래의 주석 스레드를 확인하십시오. 비슷한 문제를 가진 상당수의 사람들의 사례가 도움이 될 수 있으며 누군가와 유사한 문제가 발생했을 가능성이 큽니다.

- `{status : false}` 응답

  만일 실행된 명령이`{status : false}` 응답으로 실패하면; 우리는 이것을 디버깅하기 위해 몇 가지 작업이 필요할 수 있습니다. 이 응답은 오류가있을 때 Lambda 함수에 의해 생성됩니다. 여러분의 핸들러 함수에서 `console.log`를 추가하십시오.

  ``` javascript
  catch(e) {
    console.log(e);
    callback(null, failure({status: false}));
  }
  ```

  그리고 `serverless deploy function -f create`를 사용하여 배포하십시오. 그러나 console의 로그가 HTTP 응답에서 전송되지 않기 때문에 우리가 HTTP 요청을 할 때 이 디버그에 대한 출력을 볼 수 없습니다. 이를 확인하려면이 로그를 확인해야합니다. API 게이트웨이 및 람다 로그 작업에 대한 [자세한 정보]({% link _chapters/api-gateway-and-lambda-logs.md %}#viewing-lambda-cloudwatch-logs)가 있습니다. 디버그 메시지는 [여기]({% link _chapters/api-gateway-and-lambda-logs.md %}#viewing-lambda-cloudwatch-logs)를 확인하십시오.

  일반적인 에러의 대부분은 잘못 들여 쓰여진 `serverless.yml`입니다. `serverless.yml`에서 들여 쓰기를 [해당 챕터](https://github.com/AnomalyInnovations/serverless-stack-demo-api/blob/master/serverless.yml)의 것과 비교하여  거듭 확인하십시오.

- `‘User: arn:aws:... is not authorized to perform: dynamodb:PutItem on resource: arn:aws:dynamodb:...’`

  이 오류는 기본적으로 Lambda 함수에 DynamoDB 요청을 수행할 수있는 올바른 권한이 없다는 것을 나타냅니다. 람다 함수가 DynamoDB에 요청할 수있게하는 IAM 역할은 `serverless.yml`에서 설정된다는 것을 상기하십시오. 그리고 이 에러의 일반적인 원인은 `iamRoleStatements :`가 부적절하게 들여 쓰기되었을 때입니다. 이 `serverless.yml`을 [repo에있는 것과]({{ site.backend_github_repo }}) 비교하십시오. 

