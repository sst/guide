---
layout: post
title: Set Custom Domains Through Seed
date: 2018-03-15 00:00:00
lang: ko
description: Seed 콘솔을 사용하여 사용자 정의 도메인이있는 Serverless 프로젝트에서 API 게이트웨이 엔드 포인트를 구성합니다. 사용자 정의 도메인으로 스테이지를 구성하려면 stage 설정으로 이동하여 Route 53 도메인, 하위 도메인 및 기본 경로를 선택하십시오. 
context: true
comments_id: set-custom-domains-through-seed/178
ref: set-custom-domains-through-seed
---

Severless API는 API 게이트웨이를 사용해 자동 생성된 엔드포인트를 제공합니다. `api.my-domain.com` 같은 도메인을 사용하도록 구성하고 싶습니다. 이 작업은 AWS Console을 통해 몇 가지 단계를 거칠 수 있지만 [Seed](https://seed.run)를 통해 구성하면 매우 간단합니다.

**prod** state에서 **View Resources**를 클릭하십시오.

![운영 스테이지 배포 보기 화면](/assets/part2/prod-stage-view-deployment.png)

여기에는 배포의 일부인 API 엔드포인트 및 람다 함수의 목록이 표시됩니다. 이제 **Settings**를 클릭하십시오.

![운영 스테이지 배포 화면](/assets/part2/prod-stage-deployment.png)

**Update Custom Domain**을 클릭하십시오.

![사용자 정의 도메인 패널 앱 화면](/assets/part2/custom-domain-panel-prod.png)

튜토리얼의 첫 번째 부분에서는 Route 53에 도메인을 추가했습니다. 그렇게하지 않았다면 [여기에 대해 자세히 알아보세요](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html). **Select a domain**을 클릭하면 모든 Route 53 도메인의 목록이 표시됩니다. 사용하려는 도메인을 선택하십시오. 하위 도메인 및 기본 경로를 채웁니다. 예를 들어, `api.my-domain.com/prod`를 사용할 수 있습니다. 여기서 `api`는 하위 도메인이고 `prod`는 기본 경로입니다.

**Update**를 클릭하십시오.

![사용자 정의 도메인 세부 정보 화면](/assets/part2/custom-domain-details-prod.png)

이제 Seed가 이 API 게이트웨이 엔드포인트에 대한 도메인을 구성하고 SSL 인증서를 만든 다음 도메인에 연결합니다. 이 프로세스는 최대 40 분이 소요될 수 있습니다.

기다리는 동안, 우리는 `dev` stage에서 똑같이 할 수 있습니다. **dev** stage로 이동하고 **View Deployment**를 클릭 한 다음 **Settings**를 클릭하고 **Update Custom Domain**을 클릭하십시오. 그리고 도메인, 하위 도메인 및 기본 경로를 선택하십시오. 이 경우에는 `api.my-domain.com/dev`를 사용할 것입니다.

![dev 맞춤 도메인 세부 정보 화면](/assets/part2/custom-domain-details-dev.png)

**Update**를 클릭하고 변경 사항이 적용될 때까지 기다리십시오.

완료되면 완벽하게 구성된 Severless API 백엔드를 테스트할 준비가되었습니다!
