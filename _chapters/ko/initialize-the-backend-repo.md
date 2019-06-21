---
layout: post
title: Initialize the Backend Repo
date: 2018-02-24 00:00:00
lang: ko
description: By automating deployments for our Serverless Framework app, we can simply git push to deploy our app to production. To do so, start by adding your serverless app repo to Git.
comments_id: initialize-the-backend-repo/159
ref: initialize-the-backend-repo
---

우선 새 프로젝트를 만들어 GitHub에 추가 할 것입니다. 우리는 지금까지 작성한 코드를 사용하지 않을 것입니다.

### 코드 복제하기 

<img class="code-marker" src="/assets/s.png" />작업 디렉토리에서 [original 저장소]({{ site.backend_github_repo }})를 복제합니다.

``` bash
$ git clone --branch handle-api-gateway-cors-errors --depth 1 https://github.com/AnomalyInnovations/serverless-stack-demo-api.git serverless-stack-2-api/
$ cd serverless-stack-2-api/
```

<img class="code-marker" src="/assets/s.png" />그리고 `.git/` 디렉토리를 삭제합니다.

``` bash
$ rm -rf .git/
```

<img class="code-marker" src="/assets/s.png" />Node 모듈을 설치합니다.

``` bash
$ npm install
```

### 새로운 Github 저장소를 만들기 

[GitHub](https://github.com)을 방문합니다.  로그인하고 **New repository**를 클릭합니다.

![신규 GitHub 저장소 만들기 화면](/assets/part2/create-new-github-repository.png)

저장소에 이름을 지정하십시오. 이 경우에는 serverless-stack-2-api라고합니다. 다음 **Create repository**를 클릭합니다.

![신규 GitHub 저장소 이름 만들기 화면](/assets/part2/name-new-github-repository.png)

여러분의 저장소가 만들어지면, 나중에 필요하니 저장소 URL을 복사합니다.

![신규 GitHub 저장소 url 복사하기 화면](/assets/part2/copy-new-github-repo-url.png)

여기에서 URL은:

```
https://github.com/jayair/serverless-stack-2-api.git
```

### 여러분의 신규 저장소 초기화하기 

<img class="code-marker" src="/assets/s.png" />이제 프로젝트로 돌아가서 다음 명령을 사용하여 새 repo를 초기화하십시오.

``` bash
$ git init
```

<img class="code-marker" src="/assets/s.png" />기존 파일을 추가합니다.

``` bash
$ git add .
```

<img class="code-marker" src="/assets/s.png" />여러분의 첫 커밋을 생성합니다.

``` bash
$ git commit -m "First commit"
```

<img class="code-marker" src="/assets/s.png" />이제 여러분이 Github에 생성한 저장소로 링크합니다.

``` bash
$ git remote add origin REPO_URL
```

여기서 `REPO_URL`은 위의 단계에서 GitHub에서 복사 한 URL입니다. 다음을 수행하여 올바르게 설정되었는지 확인할 수 있습니다.

``` bash
$ git remote -v
```

<img class="code-marker" src="/assets/s.png" />마지막으로 첫 커밋을 GitHub에 푸시(Push)합니다:

``` bash
$ git push -u origin master
```

다음으로,  이제 정리를 위해 프로젝트에 몇 가지 수정을 빠르게 반영해보겠습니다.
