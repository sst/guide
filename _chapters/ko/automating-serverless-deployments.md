---
layout: post
title: Automating Serverless Deployments
date: 2018-03-11 00:00:00
lang: ko
description: Git 저장소에 변경 사항을 적용할 때 Serverless Framework 프로젝트를 자동으로 배포하려고합니다. 이를 위해 Seed (https://seed.run)라는 서비스를 사용하여 serverless 배포를 자동화합니다. CI/CD 파이프 라인을 구성하고 환경을 설정합니다.
context: true
comments_id: automating-serverless-deployments/174
ref: automating-serverless-deployments
---

다음은 우리가 지금까지 구성한 것들을 요약한 내용입니다.:

- 모든 인프라가 코드로 완벽하게 구성된 Serverless 프로젝트
- 보안상 중요한 정보를 로컬에서 처리하는 방법
- 마지막으로 단위 테스트를 실행하여 비즈니스 로직을 테스트하는 방법

이 모든 것들은 Git 저장소에서 깔끔하게 커밋 되었습니다.

다음으로 배포를 자동화하기 위해 Git 저장소를 사용할 것입니다. 이것은 기본적으로 Git에 변경 사항을 적용함으로써 전체 프로젝트를 배포 할 수 있음을 의미합니다. 코드를 배포하기 위해 특별한 스크립트나 구성을 따로 만들 필요가 없으므로 매우 유용할 수 있습니다. 또한 팀의 여러 사람들이 쉽게 배포 할 수 있습니다.

배포 자동화와 함께 여러 환경에서 작업하는 방법에 대해서도 알아볼 것입니다. 우리는 운영 환경과 개발 환경 간의 명확한 분리를 원합니다. dev(또는 non-prod) 환경에 지속적으로 배포할 작업 흐름을 만들 예정입니다. 그러나 운영으로 전환되어야 할 때는 수동으로 처리하게 될 것입니다. 또한 API용 사용자 정의 도메인 구성에 대해서도 알아보겠습니다.

Severless 백엔드를 자동화하기 위해 [Seed](https://seed.run)라는 서비스를 사용하게 될 것입니다. 공개하자면, 우리가 Seed를 만들었습니다. 이 섹션의 대부분은 [Travis CI](https://travis-ci.org)나 [Circle CI](https://circleci.com)와 같은 서비스로 대체 할 수 있습니다. 좀 더 성가시고 스크립팅이 필요하지만 앞으로 이 내용을 다룰 수 있습니다.

Seed에서 프로젝트를 시작하는 것으로 시작하겠습니다.
