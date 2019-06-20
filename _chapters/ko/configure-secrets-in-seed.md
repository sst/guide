---
layout: post
title: Configure Secrets in Seed
date: 2018-03-13 00:00:00
lang: ko
description: Seed(https://seed.run)를 사용하여 Serverless 배포를 자동화하려면 Seed 콘솔에서 비밀을 설정해야합니다. env.yml에서 배포할 stage로 환경 변수를 이동하십시오.
context: true
comments_id: configure-secrets-in-seed/176
ref: configure-secrets-in-seed
---

첫 번째 배포를 수행하기 전에 비밀 환경 변수를 구성해야합니다. 우리는 명시적으로 코드(또는 Git)에 이를 저장하지 않았습니다. 즉, 우리 팀의 다른 누군가가 배포하려고 할 경우 `env.yml` 파일을 전달해야만 합니다. 대신 우리는 [Seed](https://seed.run)를 구성하여 보안이 필요한 정보를 함께 배포하려고 합니다.

그렇게하려면 **dev** 스테이지의 **Setting** 버튼을 누르십시오.

![dev 스테이지의 Settings 선택 화면](/assets/part2/select-settings-in-dev-stage.png)

**Show Env Variables** 클릭.

![dev env 변수 설정 화면](/assets/part2/show-dev-env-variables-settings.png)

그리고 **Key**로 `stripeSecretKey`를 입력하고 그 값은 [env.yml에서 비밀 키 불러오기]({% link _chapters/load-secrets-from-env-yml.md %}) 챕터의 `STRIPE_TEST_SECRET_KEY` 값을 입력합니다. 비밀 키를 저장하려면 **추가**를 누르십시오.

![dev 환경 변수로 비밀 키 추가 화면](/assets/part2/add-secret-dev-environment-variable.png)

다음으로 `prod` stage에 대한 비밀 키를 설정해야합니다. 역시 `prod`에서 **Setting** 버튼을 누릅니다.

![prod 스테이지에서 Settings 선택 화면](/assets/part2/select-settings-in-prod-stage.png)

**Show Env Variables** 클릭.

![Show prod env 변수 설정 화면](/assets/part2/show-prod-env-variables-settings.png)

그리고 **Key**로 `stripeSecretKey`를 입력하고 그 값은 [env.yml에서 비밀 키 불러오기]({% link _chapters/load-secrets-from-env-yml.md %}) 챕터의 `STRIPE_PROD_SECRET_KEY` 값을 입력합니다. 비밀 키를 저장하려면 **추가**를 누르십시오.

![prod 환경 변수로 비밀 키 추가 화면](/assets/part2/add-secret-prod-environment-variable.png)

다음으로 Seed에서 첫 배포를 시작하겠습니다.
