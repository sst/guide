---
layout: post
title: Add a Billing API
date: 2018-03-07 00:00:00
lang: ko
description: 우리는 serverless billing API를위한 Lambda 함수를 만들 예정입니다. 앱으로 전달 된 Stripe 토큰을 가져와 Stripe JS SDK를 사용하여 지불을 처리합니다. 
context: true
comments_id: add-a-billing-api/170
ref: add-a-billing-api
---

이제 결제 API를 작성해 보겠습니다. API는 스트라이프 토큰과 사용자가 저장하기를 원하는 노트의 수를 입력 받습니다.

### 결제 람다 추가

<img class="code-marker" src="/assets/s.png" />Stripe NPM 패키지를 설치합니다. 프로젝트의 루트에서 다음을 실행하십시오.


``` bash
$ npm install --save stripe
```

<img class="code-marker" src="/assets/s.png" />다음으로 `billing.js`에 다음 내용을 추가합니다.

``` js
import stripePackage from "stripe";
import { calculateCost } from "./libs/billing-lib";
import { success, failure } from "./libs/response-lib";

export async function main(event, context) {
  const { storage, source } = JSON.parse(event.body);
  const amount = calculateCost(storage);
  const description = "Scratch charge";

  // Load our secret key from the  environment variables
  const stripe = stripePackage(process.env.stripeSecretKey);

  try {
    await stripe.charges.create({
      source,
      amount,
      description,
      currency: "usd"
    });
    return success({ status: true });
  } catch (e) {
    return failure({ message: e.message });
  }
}
```

위 대부분은 매우 간단하지만 빨리 넘어 가겠습니다.:

- 요청 본문에서 `storage` 와 `source`를 가져옵니다. `storage` 변수는 사용자가 자신의 계정에 저장하고자 하는 노트의 수입니다. 그리고 `source`는 우리가 청구할 카드의 Stripe 토큰입니다.

- 우리는`calculateCost(저장소)` 함수(곧 우리가 추가할 예정)를 사용하여 저장 될 노트의 수를 기준으로 사용자에게 청구할 금액을 계산합니다.

- Stripe Secret 키를 사용하여 새로운 Stripe 객체를 만듭니다. 이것을 환경 변수로 사용하려고합니다. 비밀 키를 코드에 넣고 Git에 커밋하고 싶지는 않습니다. 이것은 보안상의 문제입니다.

마지막으로 `stripe.charges.create` 메소드를 사용하여 사용자에게 요금을 청구하고 모든 것이 성공적으로 완료되면 요청에 응답합니다.

### 비즈니스 로직 추가

이제 `calculateCost` 메소드를 구현해 보겠습니다. 이것은 주로 *비즈니스 로직*입니다.

<img class="code-marker" src="/assets/s.png" />`libs/billing-lib.js` 파일을 만들고 아래 내용을 추가합니다.

``` js
export function calculateCost(storage) {
  const rate = storage <= 10
    ? 4
    : storage <= 100
      ? 2
      : 1;

  return rate * storage * 100;
}
```

이것은 기본적으로 사용자가 10 개 이하의 노트를 저장하려는 경우 노트 당 4 달러를 청구한다는 내용입니다. 100 개 이하의 경우 2 달러를 청구하고 100 달러를 초과하는 항목은 노트 당 1 달러입니다. 분명히 serverless 인프라는 저렴하지만 서비스는 그렇지 않습니다!

### API 엔드포인트 구성

새로운 API 및 Lambda 함수에 대한 참조를 추가해 보겠습니다.

<img class="code-marker" src="/assets/s.png" />`serverless.yml`의 `resources :`블럭 위에 다음을 추가하십시오.

``` yml
  billing:
    handler: billing.main
    events:
      - http:
          path: billing
          method: post
          cors: true
          authorizer: aws_iam
```

위 내용이 **정확하게 들여 쓰기되어 있는지** 확인하십시오. 이 블럭은 `functions` 블럭에 속합니다.

### 변경 사항 커밋 

<img class="code-marker" src="/assets/s.png" />Git으로 빠르게 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding a billing API"
```

이제 API를 테스트하기 전에 현재 환경에서 Stripe 비밀 키를 로드해야합니다.
