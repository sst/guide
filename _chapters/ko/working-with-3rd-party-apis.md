---
layout: post
title: Working with 3rd Party APIs
date: 2018-03-05 00:00:00
lang: ko
description: AWS Lambda 함수에서 3rd-party API를 사용하는 방법을 배우려면 Stripe을 사용하여 결제 API를 작성해야합니다.
comments_id: working-with-3rd-party-apis/168
ref: working-with-3rd-party-apis
---

튜토리얼의 첫 번째 부분에서는 기본적인 CRUD API를 만들었습니다. 우리는 3rd-party API와 함께 작동하는 엔드포인트를 작성하여 기존 API에 기능을 추가할 것입니다. 이 섹션에서는 비밀 환경 변수를 사용하는 방법과 Stripe을 사용하여 신용 카드 지불을 수락하는 방법을 설명합니다.

일반적인 Serverless Stack의 확장 스택은 Stripe와 함께 작동하는 빌링 API를 추가하는 것입니다. 노트 앱의 경우 사용자가 특정 수의 노트를 저장하는데 비용을 지불할 수있게 됩니다. 순서는 다음과 같습니다.

1. 사용자는 그가 저장하고자 하는 노트의 수를 선택하고 신용 카드 정보를 입력할 것입니다.

2. 프론트엔드에서 Stripe SDK를 호출하여 일회용 토큰을 생성하여 신용 카드 정보가 유효한지 확인합니다.

3. 우리는 노트 수와 생성된 토큰을 전달하는 API를 호출합니다.

4. API는 노트 수를 가져오고(요금 책정 계획에 따라) 청구 할 금액을 파악한 다음, Stripe API에 요청하여 사용자에게 청구합니다.

우리는 이 정보를 데이터베이스에 저장하기 위해 그다지 많은 작업을 하지는 않을 것입니다. 여러분들을 위해 실습으로 남겨둘 예정입니다.

먼저 Stripe 계정을 설정해 보겠습니다.

