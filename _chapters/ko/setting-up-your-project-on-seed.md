---
layout: post
title: Setting up Your Project on Seed
date: 2018-03-12 00:00:00
lang: ko
description: Serverless 배포를 자동화하기 위해 Seed(https://seed.run)라는 서비스를 사용합니다. 무료 계정에 가입하고 프로젝트 저장소를 추가하며 AWS IAM 자격 증명을 설정합니다.
context: true
comments_id: setting-up-your-project-on-seed/175
ref: setting-up-your-project-on-seed
---

[Seed](https://seed.run)를 사용하여 serverless 배포를 자동화하고 환경을 관리합니다.

[여기](https://console.seed.run/signup-account)에서 무료 계정에 가입하십시오.

![신규 Seed 계정 만들기 화면](/assets/part2/create-new-seed-account.png)

**앱을 추가**합니다.

![첫 번째 Seed 앱 추가 화면](/assets/part2/add-your-first-seed-app.png)

이제 프로젝트를 추가하려면 **GitHub**를 git 제공 업체로 선택하십시오. GitHub 계정에 Seed 권한을 부여하라는 메시지가 나타납니다.

![Git 제공 업체 선택 화면](/assets/part2/select-git-provider.png)

지금까지 사용했던 저장소를 선택하십시오. Seed는 프로젝트 루트에서 `serverless.yml`을 가져옵니다. 이를 확인하고 **서비스 추가**를 클릭 하십시오.

![Serverless.yml 발견 화면](/assets/part2/serverless-yml-detected.png)

`serverless.yml` 파일이 프로젝트 루트에 없을 경우, 경로를 변경해야합니다.

이제 Seed가 대신해서 AWS 계정에 배포합니다. 프로젝트에 필요한 정확한 권한을 가진 별도의 IAM 사용자를 만들어야합니다. 이에 대한 자세한 내용은 [여기](https://seed.run/docs/customizing-your-iam-policy)를 참조하십시오. 하지만 여기서는 간단히 이 튜토리얼에서 사용했던 것을 사용한다.

<img class="code-marker" src="/assets/s.png" />다음 명령을 실행합니다.

``` bash
$ cat ~/.aws/credentials
```

다음과 같은 내용이 보여야합니다.

```
[default]
aws_access_key_id = YOUR_IAM_ACCESS_KEY
aws_secret_access_key = YOUR_IAM_SECRET_KEY
```

**앱 추가**를 클릭하고 입력합니다.

![AWS IAM 자격 증명 입력 화면](/assets/part2/add-aws-iam-credentials.png)

새로 생성된 앱을 클릭합니다.

![신규 Seed 앱 클릭 화면](/assets/part2/click-on-new-seed-app.png)

여기에 몇 가지 사실을 알게 될 것입니다. 먼저 **default**라는 서비스가 있습니다. Serverless 앱은 여러가지 서비스를 가질 수 있습니다. 서비스(간단히 부른다면)는 `serverless.yml` 파일에 대한 참조입니다. 우리는 Git 저장소의 루트에 한 개의 서비스가 있습니다. 두 번째로 우리는 앱을 위해 두가지 stage(환경)를 설정했습니다.

이제 앱을 배포하기 전에 단위 테스트를 빌드 프로세스의 일부로 실행해야합니다. [단위 테스트]({% link _chapters/unit-tests-in-serverless.md %}) 챕터에 몇 가지 테스트를 추가했던 것을 기억할 것입니다. 앱을 배포하기 전에 만들었던 테스트들을 실행하려고합니다.

이렇게 하려면 **설정** 버튼을 클릭하고 **단위 테스트 사용**을 클릭하십시오.

![Seed의 단위 테스트 기능 켜기 클릭 화면](/assets/part2/click-enable-unit-tsts-in-seed.png)

우리의 **dev** 스테이지가 마스터에 연결되어 있음을 알 수 있습니다. 이것은 마스터에 대한 모든 커밋이 dev의 빌드를 트리거링한다는 것을 의미합니다.

**dev**을 클릭하십시오.

![Seed 프로젝트에서 dev 스테이지 만들기 화면](/assets/part2/click-dev-stage-in-seed-project.png)

아직 해당 stage에 배포되지 않았다는 것을 알 수 있습니다.

![Seed 프로젝트의 개발 stage 화면](/assets/part2/dev-stage-in-seed-project.png)

배포하기 전에 먼저 비밀 환경 변수를 추가해야합니다.
