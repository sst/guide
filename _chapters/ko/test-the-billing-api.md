---
layout: post
title: Test the Billing API
date: 2018-03-09 00:00:00
lang: ko
description: Serverless Stripe 결제 API를 테스트하기 위해 Lambda HTTP 이벤트를 가상으로 처리하도록합니다. Stripe 테스트 토큰을 전달하고 serverless invoke local 명령을 호출하십시오. 
comments_id: test-the-billing-api/172
ref: test-the-billing-api
---

이제 결제 API를 모두 설정했으므로 로컬 환경에서 신속하게 테스트 해보겠습니다.

<img class="code-marker" src="/assets/s.png" />`mocks/billing-event.json` 파일을 만들고 다음 내용을 추가합니다.

``` json
{
  "body": "{\"source\":\"tok_visa\",\"storage\":21}",
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

우리는`tok_visa`라는 Stripe 테스트 토큰과 저장하고자하는 노트의 수인 `21`을 테스트할 것입니다. Stripe 테스트 카드 및 토큰에 대한 자세한 내용은 [Stripe API 문서](https://stripe.com/docs/testing#cards)를 참조하십시오.

이제 프로젝트 루트에서 다음을 실행하여 결제 API를 호출 해보겠습니다.

``` bash
$ serverless invoke local --function billing --path mocks/billing-event.json
```

결과는 다음과 같이 나와야합니다.

``` json
{
    "statusCode": 200,
    "headers": {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true
    },
    "body": "{\"status\":true}"
}
```

### 변경사항 커밋 

<img class="code-marker" src="/assets/s.png" />변경사항을 Git에 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding a mock event for the billing API"
```

이제 새로운 결제 API를 준비했습니다. 비즈니스 로직이 올바르게 구성되었는지 확인하기 위해 단위 테스트를 설정하는 방법에 대해 살펴 보겠습니다.
