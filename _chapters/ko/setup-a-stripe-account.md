---
layout: post
title: Setup a Stripe Account
date: 2018-03-06 00:00:00
lang: ko
description: 우리는 Stripe을 사용하여 신용 카드 지불을 처리 할 것입니다. 이렇게 하려면 먼저 무료 스트라이프 계정을 만드십시오. 
context: true
comments_id: setup-a-stripe-account/169
ref: setup-a-stripe-account
---

무료 Stripe 계정을 만들어 보겠습니다. [Stripe](https://dashboard.stripe.com/register)로 가서 계정을 등록하십시오.

![Stripe 계정 스크린 샷 만들기](/assets/part2/create-a-stripe-account.png)

로그인한 다음 왼쪽에있는 **개발자** 링크를 클릭하십시오.

![스트라이프 대시 보드 스크린 샷](/assets/part2/stripe-dashboard.png)

**API 키**를 누르십시오.

![Stripe 대시 보드 스크린 샷의 개발자 섹션](/assets/part2/developer-section-in-stripe-dashboard.png)

우선 여기에서 유의할 점은 테스트 키 버전의 API 키로 작업한다는 것입니다. 운영 버전을 만들려면 이메일 주소와 비즈니스 세부 정보를 확인하여 계정을 활성화해야합니다. 이 가이드의 목적을 위해 우리는 테스트 버전으로 계속 작업하겠습니다.

두 번째로 주목해야 할 것은 **Publishable 키**와 **비밀 키**를 생성해야한다는 것입니다. Publishable 키는 Stripe SDK를 사용하여 프론트엔드 클라이언트에서 사용할 것입니다. 그리고 비밀 키는 Stripe가 사용자에게 요금을 청구할 때 API에서 사용할 것입니다. 표시된 바와 같이 Publishable 키는 공개 키이고 비밀 키는 비공개로 유지해야합니다.

**Reveal test key token**을 클릭하십시오.

![Stripe 대시 보드 Stripe API 키 스크린 샷](/assets/part2/stripe-dashboard-stripe-api-keys.png)

**Publishable 키** 및 **비밀 키**를 기록하십시오. 나중에 이것들을 사용할 것입니다.

다음으로 청구 API를 작성해 보겠습니다.
