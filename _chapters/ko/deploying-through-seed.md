---
layout: post
title: Deploying Through Seed
date: 2018-03-14 00:00:00
lang: ko
description: Git에서 Serverless 프로젝트에 커밋을 시도하여 Seed에서 배포를 시작합니다. Seed 콘솔에서 빌드 로그를보고 CloudFormation 출력을 볼 수 있습니다.
context: true
comments_id: deploying-through-seed/177
ref: deploying-through-seed
---

이제 첫 번째 배포를 시작할 준비가 되었습니다. Git을 사용하여 마스터에 새 변경 사항을 적용하여 트리거할 수 있습니다. 또는 **dev** stage로 들어가서 **트리거 배포** 버튼을 누르십시오.

Git을 통해 해보겠습니다.

<img class="code-marker" src="/assets/s.png" />프로젝트 루트로 돌아가서 다음을 실행합니다.

``` bash
$ npm version patch
```

이것은 단순히 프로젝트의 NPM 버전을 업데이트하는 것입니다. 프로젝트의 변경 사항을 추적하는 좋은 방법입니다. 그리고 그것은 Seed를 통한 자동 배포를 위한 Git 커밋을 빠르게 만들어줍니다.

<img class="code-marker" src="/assets/s.png" />변경 사항을 Push합니다.

``` bash
$ git push
```

이제 Seed에서 **dev** stage로 가면 빌드가 진행 중입니다. 이제 빌드 로그를보고 **Build v1**을 누를 수 있습니다.

![Seed dev build 진행 화면](/assets/part2/seed-dev-build-in-progress.png)

여기에서 빌드가 실행되는 것을 볼 수 있습니다. 진행중인 서비스를 클릭하십시오. 이 경우에는 하나의 서비스만 있습니다.

![Dev build가 진행중인 페이지 화면](/assets/part2/dev-build-page-in-progress.png)

진행중인 빌드에 대한 빌드 로그가 여기에 표시됩니다.

![진행중인 Dev build 로그 화면](/assets/part2/dev-build-logs-in-progress.png)

테스트가 빌드의 일부로 실행되고 있음을 알 수 있습니다.

![Dev build 테스트 실행 화면](/assets/part2/dev-build-run-tests.png)

여기서 주목할 점은 빌드 프로세스가 몇 가지 부분으로 나뉘어져 있다는 것입니다. 먼저 코드가 Git을 통해 체크 아웃되고 테스트가 실행됩니다. 그러나 직접 배포하지 않습니다. 대신에, 우리는`dev` stage와 `prod` stage를 위한 패키지를 생성합니다. 그리고 마지막으로 우리는 그 패키지로 `dev`에 배포합니다. 이것이 나뉘어진 이유는 'prod'로 전환하면서 발생하는 빌드 프로세스를 피하기 위해서입니다. 이렇게하면 테스트된 작업 빌드가 있을 경우 운영 환경으로 전환할 때 작동하게 됩니다.

또한 다음과 같은 몇 가지 경고를 볼 수 있습니다.


``` bash
Serverless Warning --------------------------------------

A valid file to satisfy the declaration 'file(env.yml):dev,file(env.yml):default' could not be found.


Serverless Warning --------------------------------------

A valid file to satisfy the declaration 'file(env.yml):dev,file(env.yml):default' could not be found.


Serverless Warning --------------------------------------

A valid service attribute to satisfy the declaration 'self:custom.environment.stripeSecretKey' could not be found.
```

이것은 `env.yml`이 Git 저장소의 일부가 아니기 때문에 예상되며, 빌드 프로세스에서는 사용할 수 없습니다. 대신 Stripe 키가 Seed 콘솔에 직접 설정됩니다.

빌드가 완료되면 빌드 로그를보고 다음을 기록하십시오.

- Region: `region`
- Cognito 사용자 풀 ID: `UserPoolId`
- Cognito 앱 클라이언트 ID: `UserPoolClientId`
- Cognito Identity 풀 ID: `IdentityPoolId`
- S3 파일 업로드 버킷: `AttachmentsBucketName`
- API Gateway URL: `ServiceEndpoint`

이 정보들은 프론트엔드와 API를 테스트 할 때 필요할 것입니다.

![Dev build 스택 결과 화면](/assets/part2/dev-build-stack-output.png)

이제 앱 홈페이지로 이동하십시오. 바로 운영으로 배포할 준비가 되었습니다.

수동 배포 단계를 통해 변경 사항을 검토하고 운영 환경으로 push를 할 준비가 되었는지 확인할 수 있습니다.


**Promote** 버튼을 클릭하십시오.

![Promote 준비된 Dev build 화면](/assets/part2/dev-build-ready-to-promote.png)

그러면 CloudFormation Change Set이 생성되는 대화 상자가 나타납니다. 이것은 운영중인 배포와 관련하여 업데이트되는 리소스를 비교합니다. 배포하려는 인프라의 변경 사항을 비교할 수있는 좋은 방법입니다.

![promote 변경 사항 검토 화면](/assets/part2/review-promote-change-set.png)

스크롤 다운해서 **Promote to Production**을 클릭합니다.

![dev build promote 확인 화면](/assets/part2/confirm-promote-dev-build.png)

빌드가 **prod** stage로 배포되고 있음을 알 수 있습니다.

![prod build 진행 화면](/assets/part2/prod-build-in-progress.png)

**prod** stage로 넘어 가면 prod 배포가 실제로 작동하는지 확인해야합니다. 운영 환경에 배포하는데는 몇 초가 걸립니다. 이전과 마찬가지로 다음 사항을 기록해 두십시오.

- Region: `region`
- Cognito 사용자 풀 ID: `UserPoolId`
- Cognito 앱 클라이언트 ID: `UserPoolClientId`
- Cognito Identity 풀 ID: `IdentityPoolId`
- S3 파일 업로드 버킷: `AttachmentsBucketName`
- API Gateway URL: `ServiceEndpoint`

![Prod build 스택 결과 화면](/assets/part2/prod-build-stack-output.png)

다음으로 Serverless API를 사용자 정의 도메인으로 구성 해 보겠습니다.
