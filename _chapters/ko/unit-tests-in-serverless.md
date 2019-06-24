---
layout: post
title: Unit Tests in Serverless
date: 2018-03-10 00:00:00
lang: ko
description: Serverless에서 비즈니스 로직을 테스트하기 위해 Jest를 사용하여 프로젝트에 단위 테스트를 추가합니다. "npm test" 명령을 사용하여이 테스트를 실행할 수 있습니다. 
context: true
code: backend
comments_id: unit-tests-in-serverless/173
ref: unit-tests-in-serverless
---

이제 우리는 사용자들이 저장하고 싶은 노트의 수를 기반으로 사용자에게 청구할 금액을 정확하게 파악하는 간단한 비즈니스 로직을 작성하였습니다. 사용자들에게 요금을 부과하기 전에 가능한 모든 케이스를 시험해보기를 원합니다. 이를 위해 우리는 Serverless Framework 프로젝트를 위한 단위 테스트를 구성할 것입니다.

이를 위해 [Jest](https://facebook.github.io/jest/)를 사용할 것이고 이미 [우리의 스타터 프로젝트](https://github.com/AnomalyInnovations/serverless-nodejs)의 일부입니다.

그러나 만약에 새로운 Serverless Framework 프로젝트를 시작한다면 다음을 실행하여 Jest를 dev 환경에 추가하십시오.

``` bash
$ npm install --save-dev jest
```

`package.json`의 `scripts` 블럭에 다음을 추가하십시오.

```
"scripts": {
  "test": "jest"
},
```

이를 통해 `npm test` 명령어를 실행하면 테스트를 수행할 수 있습니다.

### 단위 테스트 추가

<img class="code-marker" src="/assets/s.png" />새로운 `tests/billing.test.js` 파일을 생성하고 다음 내용을 추가합니다.

``` js
import { calculateCost } from "../libs/billing-lib";

test("Lowest tier", () => {
  const storage = 10;

  const cost = 4000;
  const expectedCost = calculateCost(storage);

  expect(cost).toEqual(expectedCost);
});

test("Middle tier", () => {
  const storage = 100;

  const cost = 20000;
  const expectedCost = calculateCost(storage);

  expect(cost).toEqual(expectedCost);
});

test("Highest tier", () => {
  const storage = 101;

  const cost = 10100;
  const expectedCost = calculateCost(storage);

  expect(cost).toEqual(expectedCost);
});
```

단위 테스트는 매우 간단해야합니다. 여기서 우리는 3 개의 테스트를 추가했습니다. 이 테스트들은 가격 체계의 여러 단계를 테스트하고 있습니다. 사용자가 10, 100 및 101 개의 노트를 저장하려고 하는 경우를 테스트합니다. 그리고 계산된 비용을 우리가 기대하는 것과 비교합니다. Jest 사용에 대한 자세한 내용은 [Jest 문서는 여기](https://facebook.github.io/jest/docs/en/getting-started.html)에서 볼 수 있습니다.

### 테스트 실행

프로젝트의 루트에서 다음 명령을 사용하여 테스트를 실행할 수 있습니다.

``` bash
$ npm test
```

다음과 같은 같은 결과를 볼 수 있어야 합니다.:

``` bash
> jest

 PASS  tests/billing.test.js
  ✓ Lowest tier (4ms)
  ✓ Middle tier
  ✓ Highest tier (1ms)

Test Suites: 1 passed, 1 total
Tests:       3 passed, 3 total
Snapshots:   0 total
Time:        1.665s
Ran all test suites.
```

자, 이제 단위 테스트 설정이 모두 완료되었습니다.

### 변경사항 커밋

<img class="code-marker" src="/assets/s.png" />변경사항을 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding unit tests"
```

### 변경사항 푸시 

<img class="code-marker" src="/assets/s.png" />프로젝트를 변경 했으므로 GitHub에 푸시(Push)하겠습니다.

``` bash
$ git push
```

다음으로 우리는 Git 저장소를 사용하여 배포를 자동화합니다. 이렇게하면 Git에 변경 사항을 적용 할 때마다 테스트가 실행되어 자동으로 배포됩니다. 또한 여러 환경을 구성하는 방법을 배우게됩니다.
