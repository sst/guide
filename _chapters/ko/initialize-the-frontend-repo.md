---
layout: post
title: Initialize the Frontend Repo
date: 2018-03-18 00:00:00
lang: ko
description: React 앱의 배포를 자동화함으로써 앱을 프로덕션 환경에 배포하면됩니다. 그렇게하려면 Git에 React 앱 레포를 추가하십시오. 
comments_id: initialize-the-frontend-repo/181
ref: initialize-the-frontend-repo
---

백엔드 파트에서 했던 것처럼 프로젝트를 만들고 GitHub에 추가하는 것으로 시작합니다. 우리는 파트I에서 만들었던 결과에서 부터 그 출발점으로 하겠습니다.

### 원본 저장소 복제

<img class="code-marker" src="/assets/s.png" />작업 디렉토리에서 [원본 저장소]({{ site.frontend_github_repo }})를 복제하는 것으로 시작합니다. 주의할 점은 현재 위치가 백앤드 디렉토리 내부가 아니어야 한다는 점입니다. 

``` bash
$ git clone --branch part-1 --depth 1 https://github.com/AnomalyInnovations/serverless-stack-demo-client.git serverless-stack-2-client/
$ cd serverless-stack-2-client/
```

<img class="code-marker" src="/assets/s.png" />`.git/` 디렉토리를 삭제합니다.

``` bash
$ rm -rf .git/
```

<img class="code-marker" src="/assets/s.png" />Node 모듈을 설치합니다.

``` bash
$ npm install
```

### 새로운 GitHub 저장소를 만들기

[GitHub](https://github.com)에 로그인 후, **New repository**를 클릭합니다.

![신규 GitHub 저장소 생성 화면](/assets/part2/create-new-github-repository.png)

직접 저장소 이름을 지정합니다. 여기서는 `serverless-stack-2-client`로 하고 **Create repository**를 클릭합니다.

![신규 GitHub 저장소 이름 지정 화면](/assets/part2/name-new-client-github-repository.png)

새로운 저장소가 생성되면, URL을 복사합니다. 곧 사용하겠습니다.

![새로운 GitHub 저장소 url 복사 화면](/assets/part2/copy-new-client-github-repo-url.png)

여기에서 사용한 URL:

```
https://github.com/jayair/https://github.com/jayair/serverless-stack-2-client.git
```

### 새로운 저장소 초기화하기 

<img class="code-marker" src="/assets/s.png" />이제 프로젝트로 돌아가서 다음 명령을 사용하여 새 저장소를 초기화하십시오.

``` bash
$ git init
```

<img class="code-marker" src="/assets/s.png" />기존에 작업 파일들을 추가합니다.

``` bash
$ git add .
```

<img class="code-marker" src="/assets/s.png" />첫 번째 커밋을 실행합니다.

``` bash
$ git commit -m "First commit"
```

<img class="code-marker" src="/assets/s.png" />그리고 여러분이 생성한 Github에 연결합니다.

``` bash
$ git remote add origin REPO_URL
```

여기서 `REPO_URL`은 GitHub에서 복사한 URL입니다. 다음을 실행하여 올바르게 설정되었는지 확인할 수 있습니다.

``` bash
$ git remote -v
```

<img class="code-marker" src="/assets/s.png" />마지막으로, 커밋한 내용을 다음과 같이 푸시합니다.:

``` bash
$ git push -u origin master
```

다음으로 백엔드 환경에서 프론트엔드 클라이언트를 구성하는 방법을 살펴 보겠습니다.
