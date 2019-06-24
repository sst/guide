---
layout: post
title: Load Secrets from env.yml
date: 2018-03-08 00:00:00
lang: ko
description: 우리는 serverless.yml에 비밀 환경 변수를 저장해서는 안됩니다. 이를 위해 소스 버전관리에 체크인되지 않는 env.yml 파일을 생성합니다. 그리고 이 파일을 serverless.yml에서 로드합니다. 
context: true
comments_id: load-secrets-from-env-yml/171
ref: load-secrets-from-env-yml
---

이전에 언급했듯이 우리는 비밀 환경 변수를 코드에 저장하지 않습니다. 이 경우에는 Stripe 비밀 키가 이에 해당됩니다. 이 챕터에서는 이를 수행하는 방법을 살펴 보겠습니다.

이러한 용도로 사용하기 위해 미리 `env.example` 파일을 준비해놨습니다.

<img class="code-marker" src="/assets/s.png" />`env.example` 파일을 `env.yml`로 이름을 바꾸고 내용을 다음과 같이 변경합니다.

``` yml
# Add the environment variables for the various stages

prod:
  stripeSecretKey: "STRIPE_PROD_SECRET_KEY"

default:
  stripeSecretKey: "STRIPE_TEST_SECRET_KEY"
```

`STRIPE_PROD_SECRET_KEY` 와 `STRIPE_TEST_SECRET_KEY`를 [Setup a Stripe account]({% link _chapters/setup-a-stripe-account.md %}) 챕터에서 설명한 것 처럼 **비밀 key**로 대체하십시오. 이 경우에는 Stripe 비밀 키의 테스트 버전만 있으므로 둘 다 동일합니다.

다음으로 이들에 대한 참조를 추가해 보겠습니다.

<img class="code-marker" src="/assets/s.png" />`serverless.yml`의 `custom:` 블럭에 다음 내용을 추가합니다.

``` yml
  # Load our secret environment variables based on the current stage.
  # Fallback to default if it is not in prod.
  environment: ${file(env.yml):${self:custom.stage}, file(env.yml):default}
```

`serverless.yml`의 `custom :` 블럭은 다음과 같이 보일 것입니다.:

``` yml
custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}
  # Set the table name here so we can use it while testing locally
  tableName: ${self:custom.stage}-notes
  # Set our DynamoDB throughput for prod and all other non-prod stages.
  tableThroughputs:
    prod: 5
    default: 1
  tableThroughput: ${self:custom.tableThroughputs.${self:custom.stage}, self:custom.tableThroughputs.default}
  # Load our webpack config
  webpack:
    webpackConfig: ./webpack.config.js
    includeModules: true
  # Load our secret environment variables based on the current stage.
  # Fallback to default if it is not in prod.
  environment: ${file(env.yml):${self:custom.stage}, file(env.yml):default}
```

<img class="code-marker" src="/assets/s.png" />그리고 `serverless.yml`의 `environment:` 블럭에 다음 내용을 추가합니다. 

``` yml
  stripeSecretKey: ${self:custom.environment.stripeSecretKey}
```

여러분의 `environment:` 블럭은 다음 내용과 같이 보일 것입니다.:

``` yml
  # These environment variables are made available to our functions
  # under process.env.
  environment:
    tableName: ${self:custom.tableName}
    stripeSecretKey: ${self:custom.environment.stripeSecretKey}
```

위 작업 내용에 대한 간단한 설명 :

- 우리는 `env.yml` 파일에서 `environment`라는 커스텀 변수를 로드합니다. 이는 `file(env.yml):${self:custom.stage}`를 사용하여 stage(우리가 배포 할)를 기반으로 합니다. 그러나 그 단계가 `env.yml`에 정의되어 있지 않으면 `file:env.yml:default`를 사용하여 `default:`블록 아래에있는 내용을 로딩합니다. 따라서 Serverless Framework는 첫 번째 stage가 사용 가능한지 확인한 후 두 번째 stage를 자동으로 확인합니다.

- 다음으로 이것을 사용하여`${self:custom.environment.stripeSecretKey}`를 `environment:` 블럭에 `stripeSecretKey`를 환경 변수에 추가합니다. 이를 통해 람다 함수에서 `process.env.stripeSecretKey`로 사용할 수 있습니다. 이전 챕터에서 다뤘던 내용을 기억할 것입니다.

### 변경사항 커밋

이제 `env.yml` 파일을 git에 적용하지 않도록해야합니다. 우리가 사용하고있는 스타터 프로젝트의 `.gitignore`는 다음과 같습니다.

```
# Env
env.yml
```

위 파일은 Git으로 하여금 커밋할 경우, `env.yml` 파일을 제외하도록 합니다.

<img class="code-marker" src="/assets/s.png" />그럼 나머지 변경사항들을 커밋하겠습니다.

``` bash
$ git add .
$ git commit -m "Adding stripe environment variable"
```

이제 결제 API를 테스트할 준비가 되었습니다.
