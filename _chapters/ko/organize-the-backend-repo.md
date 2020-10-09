---
layout: post
title: Organize the Backend Repo
date: 2018-02-25 00:00:00
lang: ko
description: Serverless Framework uses the service name to identify projects. Since we are creating a new project we want to ensure that we use a different name from the original.
comments_id: organize-the-backend-repo/160
ref: organize-the-backend-repo
---

시작하기 전에 프로젝트에 몇 가지 간단한 변경을 반영해 보겠습니다.

### 사용하지 않는 파일들 삭제하기

{%change%} 이제 스타터 프로젝트에서 두 개의 파일을 제거할 수 있습니다.

``` bash
$ rm handler.js
$ rm tests/handler.test.js
```

### serverless.yml 업데이트

우리는 다른 서비스명을 사용할 것입니다.

{%change%} `serverless.yml` 파일을 열어서 다음 행을 찾습니다.:

``` yml
service: notes-api
```

{%change%} 그리고 아래 내용으로 변경합니다.:

``` yml
service: notes-app-2-api
```

이것을 하는 이유는 Serverless Framework가 프로젝트를 식별하기 위해 `service` 이름을 사용하기 때문입니다. 우리는 새로운 프로젝트를 만들었으므로 원래 이름과 다른 이름을 사용해야 합니다. 그냥 간단히 기존 프로젝트를 덮어 쓸 수 있지만 코드를 통해 생성하려고할 때 이전에 손으로 작성한 리소스가 충돌합니다.

{%change%} 먼저 `serverless.yml`에서 아래 행을 찾습니다:

``` yml
stage: prod
``` 

{%change%} 그리고 다음으로 바꿉니다.:

``` yml
stage: dev
```

우리는 stage를 `prod` 대신 `dev`로 기본 설정하고 있습니다. 나중에 여러 환경을 만들 때 구분할 수 있습니다.

{%change%} 변경 사항을 빠르게 커밋합니다.

``` bash
$ git add .
$ git commit -m "Organizing project"
```

다음은 `serverless.yml`을 통해 전체 노트 앱 백엔드 구성에 대해 살펴 보겠습니다. 이것은 일반적으로 **Infrastructure as code**로 알려져 있습니다.
