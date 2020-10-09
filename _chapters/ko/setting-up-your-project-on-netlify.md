---
layout: post
title: Setting up Your Project on Netlify
date: 2018-03-27 00:00:00
lang: ko
description: Netlify에서 Create React App의 배포를 자동화하려면 무료 계정에 가입하고 Git 저장소를 추가하십시오.
context: true
comments_id: setting-up-your-project-on-netlify/190
ref: setting-up-your-project-on-netlify
---

이제 [Netlify](https://www.netlify.com)에 우리의 React App을 설정하겠습니다. [무료 계정 생성하기](https://app.netlify.com/signup)로 시작합니다.

![Netlify 회원 가입 화면](/assets/part2/signup-for-netlify.png)

다음으로 **New site from Git** 버튼을 클릭해 신규 사이트를 생성합니다.

![Git에서 신규 사이트 클릭하기 화면](/assets/part2/hit-new-site-from-git-button.png)

제공업체로 **GitHub**을 선택합니다.

![GitHub 선택 화면](/assets/part2/select-github-as-provider.png)

프로젝트 목록에서 여러분의 프로젝트를 선택합니다.

![GitHub 저장소 목록에서 선택 화면](/assets/part2/select-github-repo-from-list.png)


기본 브랜치는 `master`입니다. 이제 앱을 배포할 수 있습니다. **Deploy site**을 클릭합니다.

![사이트 배포 클릭 화면](/assets/part2/hit-deploy-site.png)

이것으로 앱 배포가 진행되어야합니다. 완료되면 배포를 클릭합니다. 

![배포된 사이트 보기 화면](/assets/part2/view-deployed-site.png)

그리고 실제로 앱이 작동되어야 합니다.

![Netlify 노트 앱 배포 화면](/assets/part2/netlify-deployed-notes-app.png)

물론 Netlify URL에서 호스팅됩니다. 다음에 사용자 정의 도메인을 구성하여이를 변경합니다.
