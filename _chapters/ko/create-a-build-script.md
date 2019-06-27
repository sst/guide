---
layout: post
title: Create a Build Script
date: 2018-03-26 00:00:00
lang: ko
code: frontend_full
description: Netlify로 Create React App을 구성하려면 프로젝트 루트에 빌드 스크립트를 추가해야합니다. 우리가 React Router 라우트에 대해 HTTP 상태 코드 200을 반환하도록하려면 리다이렉트 규칙을 추가해야합니다. 
comments_id: create-a-build-script/189
ref: create-a-build-script
---

프로젝트를 [Netlify](https://www.netlify.com)에 추가하기 전에 빌드 스크립트를 설정합니다. 이전의 상황을 떠올려보면, 우리는 `REACT_APP_STAGE` 빌드 환경 변수를 사용하도록 애플리케이션을 구성했었습니다. 우리는 Netlify가 다른 배포 사례에 대해 이 변수를 설정하도록 빌드 스크립트를 작성하려고합니다.

### Netlify 빌드 스크립트 추가

<img class="code-marker" src="/assets/s.png" />프로젝트 루트에  `netlify.toml` 파일을 생성 후 다음 내용을 추가합니다.

``` toml
# Global settings applied to the whole site.
# “base” is directory to change to before starting build, and
# “publish” is the directory to publish (relative to root of your repo).
# “command” is your build command.

[build]
  base    = ""
  publish = "build"
  command = "REACT_APP_STAGE=dev npm run build"

# Production context: All deploys to the main
# repository branch will inherit these settings.
[context.production]
  command = "REACT_APP_STAGE=prod npm run build"

# Deploy Preview context: All Deploy Previews
# will inherit these settings.
[context.deploy-preview]
  command = "REACT_APP_STAGE=dev npm run build"

# Branch Deploy context: All deploys that are not in
# an active Deploy Preview will inherit these settings.
[context.branch-deploy]
  command = "REACT_APP_STAGE=dev npm run build"
```

빌드 스크립트는 컨텍스트를 기반으로 구성됩니다. 맨 위에는 기본값 하나가 있습니다. 그리고 이것은 다시 세 부분으로 구성되어 있습니다.

1. `base`는 Netlify가 빌드 명령을 실행할 디렉토리입니다. 이 경우 프로젝트 루트입니다. 그래서 비어 있습니다.

2. `publish` 옵션은 빌드가 생성되는 곳을 가리 킵니다. React Create App의 경우 프로젝트 루트의 `build` 디렉토리입니다.

3. `command` 옵션은 Netlify가 사용할 빌드 명령입니다. [Create React App의 환경 관리]({% link _chapters/manage-environments-in-create-react-app.md %}) 챕터를 떠올려보십시오. 기본 컨텍스트에서 명령은 `REACT_APP_STAGE=dev npm run build`입니다.

`context.production`이라는 운영 컨텍스트는 `REACT_APP_STAGE` 변수를 `prod`로 설정한 유일한 컨텍스트입니다. 이것은 우리가 `마스터`에게 푸시할 때 실행됩니다. `branch-deploy`는 다른 비 운영 브랜치로 푸시할 때 사용할 것입니다. 그리고 `deploy-preview`는 PR 요청을위한 것입니다.

### HTTP 상태 코드 처리

튜토리얼의 첫 번째 파트와 마찬가지로 앱의 경로가 루트가 아닌 경우, 이에 대한 요청을 처리해야합니다. 프론트엔드는 단일 페이지 앱이며 라우팅은 클라이언트측에서 처리됩니다. 우리는 Netlify에게 요청을 항상 우리의`index.html`에 리다이렉트시키고 200 상태 코드를 리턴 할 필요가 있습니다.

<img class="code-marker" src="/assets/s.png" />이를 위해, `netlify.toml` 아래에 리디렉션 규칙을 추가합니다.:

``` toml
# Always redirect any request to our index.html
# and return the status code 200.
[[redirects]]
    from    = "/*"
    to      = "/index.html"
    status  = 200
```

### 빌드 명령어 변경하기

애플리케이션을 Netlify에 배포하기 위해 우리는`package.json`의 빌드 명령어를 수정해야 합니다.


<img class="code-marker" src="/assets/s.png" />`package.json`에 있는`scripts` 블록을 이것으로 바꾸십시오.

``` coffee
"scripts": {
  "start": "react-scripts start",
  "build": "react-scripts build",
  "test": "react-scripts test --env=jsdom",
  "eject": "react-scripts eject"
}
```

이전 빌드를 제거하고 스크립트를 배포하는 중임을 알 수 있습니다. 우리는 S3에 배포하지 않을 것입니다.

### 변경 사항 커밋 

<img class="code-marker" src="/assets/s.png" />Git에 빠르게 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding a Netlify build script"
```

### 변경 사항 푸시 

<img class="code-marker" src="/assets/s.png" />우리는 프로젝트에 많은 변경들을 반영했습니다. 이제 GitHub으로 이동해 봅시다.

``` bash
$ git push
```

이제 우리의 프로젝트를 Netlify에 추가할 준비가 완료되었습니다.
