---
layout: post
title: Create a New React.js App
date: 2017-01-06 00:00:00
lang: ko 
ref: create-a-new-react-js-app
description: React Create App은 설정 없이 React.js 앱을 쉽게 빌드할 수 있습니다. NPM 패키지를 사용하여 Create React App CLI를 설치하고 명령을 사용하여 새로운 React.js 프로젝트를 시작합니다. 
context: true
comments_id: create-a-new-react-js-app/68
---

이번에는 프론트엔드를 시작하겠습니다. 우리는 [React.js](https://facebook.github.io/react/)를 사용하여 단일 페이지 응용 프로그램을 만들 계획입니다. [Create React App](https://github.com/facebookincubator/create-react-app) 프로젝트를 사용하여 모든 것을 설정합니다. 이것은 React팀이 공식적으로 지원하며, React.js 프로젝트의 모든 의존성을 편리하게 패키징해줍니다.

{%change%} 백앤드를 위해 작업했던 디렉토리에서 나옵니다.

``` bash
$ cd ../
```

### 신규 React App 만들기

{%change%} 노트 앱을 위한 클라이언트를 만들기 위해 아래 명령어를 실행합니다.

``` bash
$ npx create-react-app notes-app-client
```

이 작업을 실행하는 데는 1 초가 걸리고 신규 프로젝트와 신규 작업 디렉토리가 만들어집니다.

{%change%} 생성된 디렉토리로 이동해서 프론트앤드 프로젝트를 바로 실행해 보겠습니다.

``` bash
$ cd notes-app-client
$ npm start
```

이렇게하면 브라우저에 새로 생성 된 앱이 실행됩니다.

![신규 Create React App 화면](/assets/new-create-react-app.png)

### 제목 바꾸기

{%change%} 노트 작성 앱의 제목을 빠르게 변경해 보겠습니다. `public/index.html`을 열고`title` 태그를 다음과 같이 편집하십시오:

``` html
<title>Scratch - A simple note taking app</title>
```

Create React App은 매우 편리하면서도 최소한의 개발 환경으로 미리 로딩되어 있습니다. 라이브 리로딩, 테스트 프레임 워크, ES6 지원 그리고 [기타 다양한 기능](https://github.com/facebookincubator/create-react-app#why-use-this)을 포함하고 있습니다. 

계속해서 앱 아이콘을 만들고 favicon을 업데이트 해보겠습니다.

