---
layout: post
title: 프론트엔드 작업흐름
date: 2018-03-29 00:00:00
lang: ko
description: Netlify로 구성된 Create React App의 워크플로우의 일부인 세 가지 단계가 있습니다. 새 기능을 사용하여 신규 브랜치를 만들고 브랜치 배포를 활성화합니다. 마스터로 병합하여 운영 환경에 배포하십시오. 마지막으로 운영 환경에서 롤백할 Netlify 콘솔을 통해 기존 배포를 게시하십시오. 
comments_id: frontend-workflow/192
ref: frontend-workflow
code: frontend_full
---

이제 프론트엔드를 배포하고 구성 했으므로 개발 워크플로우가 어떻게 생겼는지 살펴 보겠습니다.

### Dev 브랜치에서 작업하기

좋은 연습이 되려면 새로운 기능을 개발할 때 새로운 브랜치를 만드는 것입니다.

<img class="code-marker" src="/assets/s.png" />프로젝트 루트에서 다음 명령을 실행하세요.

``` bash
$ git checkout -b "new-feature"
```

`new-feature`라는 브랜치를 새로 만듭니다.

오류가있는 커밋을 만들어서 롤백하는 과정을 살펴 보겠습니다.

<img class="code-marker" src="/assets/s.png" />`src/containers/Home.js`의 `renderLander` 메소드를 다음으로 대체합니다.

``` coffee
renderLander() {
  return (
    <div className="lander">
      <h1>Scratch</h1>
      <p>A very expensive note taking app</p>
      <div>
        <Link to="/login" className="btn btn-info btn-lg">
          Login
        </Link>
        <Link to="/signup" className="btn btn-success btn-lg">
          Signup
        </Link>
      </div>
    </div>
  );
}
```

<img class="code-marker" src="/assets/s.png" />그리고 이 변경사항을 Git에 커밋합니다.

``` bash
$ git add .
$ git commit -m "Committing a typo"
```

### 브랜치 배포 만들기

자체 환경에서 이 변경 사항을 미리 보려면 Netlify에서 브랜치 배포를 활성화해야합니다. **Site Settings** 사이드 바에서 **Build & deploy**를 선택하십시오.

![빌드 & 배포 선택 화면](/assets/part2/select-build-and-deploy.png)

**Edit settings**를 클릭합니다.

![빌드 설정 스크린 샷 편집](/assets/part2/edit-build-settings.png)

**Branch deploys**을 **All**로 설정하고 **Save**를 클릭.

![지점 배포를 모두로 설정 화면](/assets/part2/set-branch-deploys-to-all.png)

<img class="code-marker" src="/assets/s.png"/>이제 재미있는 부분이 남았습니다. 우리는 이것을 dev에 배포할 수 있으므로 즉시 테스트할 수 있습니다. 우리가해야 할 일은 Git에 푸시하는 것뿐입니다.

``` bash
$ git push -u origin new-feature
```

이제 Netlify 프로젝트 페이지로 이동하면됩니다. 실행중인 새로운 브랜치 배포가 표시됩니다. 완료될 때까지 기다렸다가 클릭하십시오.

![신규 브랜치 배포하기 클릭화면](/assets/part2/click-on-new-branch-deploy.png)

**Preview deploy** 클릭합니다.

![신규 브랜치 배포 미리보기 화면](/assets/part2/preview-new-branch-deploy.png)

그리고 새로운 버전의 앱을 볼 수 있습니다!

![새로운 버전 앱 보기 화면](/assets/part2/preview-deploy-in-action.png)

이 버전의 프론트 엔드 앱을 테스트해 볼 수 있습니다. 그것은 우리의 백엔드 API의 dev 버전에 연결되어 있습니다. 이러한 방식은 우리가 운영 사용자에게 영향을주지 않고 여기서 변경 사항을 테스트하고 놀 수 있다는 것입니다.

### 운영으로 푸시

<img class="code-marker" src="/assets/s.png"/> 변경 사항에 만족했다면 마스터에 병합하여 운영에 적용할 수 있습니다.

``` bash
$ git checkout master
$ git merge new-feature
$ git push
```

Netlify에서 배포중인 화면.

![머지 후 운영 배포 화면](/assets/part2/production-deploy-after-merge.png)

완료되면 운영에 반영됩니다.

![운영 배포 반영 화면](/assets/part2/production-deploy-is-live.png)

### 운영 롤백

만일 운영 환경의 배포가 만족스럽지 않으면 어떤 이유로든 롤백할 수 있습니다.

이전 운영 배포를 클릭하십시오.

![이전 운영 배포 클릭 화면](/assets/part2/click-on-old-production-deployment.png)

**Publish deploy**를 클릭.

![이전 운영 배포 재배포 화면](/assets/part2/publish-old-production-deployment.png)

이전 버전을 다시 배포합니다.

![이전 운영 배포 반영 화면](/assets/part2/old-production-deploy-is-live.png)

이제 서버 없이 Create React App을 구축하고 배포하기 위한 자동화된 워크 플로우가 생겼습니다.

### 정리

변경 사항을 신속하게 정리합시다.

<img class="code-marker" src="/assets/s.png" />`src/containers/Home.js`의 `renderLander` 메소드를 원래 코드로 대체합니다.

``` coffee
renderLander() {
  return (
    <div className="lander">
      <h1>Scratch</h1>
      <p>A simple note taking app</p>
      <div>
        <Link to="/login" className="btn btn-info btn-lg">
          Login
        </Link>
        <Link to="/signup" className="btn btn-success btn-lg">
          Signup
        </Link>
      </div>
    </div>
  );
}
```

<img class="code-marker" src="/assets/s.png" />위 변경 사항을 적용하고 푸시해서 변경 내용을 적용하십시오.

``` bash
$ git add .
$ git commit -m "Fixing a typo"
$ git push
```

이렇게하면 새로운 배포가 생깁니다. 다음으로 가이드를 마무리해보겠습니다.
