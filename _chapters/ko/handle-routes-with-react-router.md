---
layout: post
title: Handle Routes with React Router
date: 2017-01-10 00:00:00
lang: ko 
ref: handle-routes-with-react-router
description: Create React App은 경로가 설정된 상태로 제공되지 않습니다. 이를 위해 React Router를 사용할 것입니다. React Router의 최신 버전인 React Router v4는 React 구성 요소의 조합 가능한 특성을 포함하며 단일 페이지 응용 프로그램에서 경로 작업을 하기가 쉽습니다.
context: true
comments_id: handle-routes-with-react-router/116
---

Create React App은 기본적으로 많은 것이 이미 설정되어 있지만, 경로에 대한 처리는 기본으로 제공되지 않습니다. 따라서 단일 페이지 앱을 개발하기 위해 [React Router](https://reacttraining.com/react-router/)를 사용하여 처리 할 것입니다.


먼저 React Router를 설치해 보겠습니다. React Router의 최신 버전인 React Router v4를 사용할 것입니다. React Router v4는 웹과 네이티브에서 사용할 수 있습니다. 여기서는 웹 용으로 설치하십시오.

### React Router v4 설치하기

<img class="code-marker" src="/assets/s.png" />작업 디렉토리에서 아래 명령어를 실행하세요.

``` bash
$ npm install react-router-dom@4.3.1 --save
```

이렇게하면 NPM 패키지가 설치되고 `package.json`에 의존성이 추가됩니다.

### React Router  설정하기

앱에 경로가 설정되어 있지는 않지만 기본 구조를 구성하고 실행할 수 있습니다. 우리의 앱은 현재 `src/App.js`의 `App` 컴포넌트에서 실행됩니다. 우리는 이 구성 요소를 전체 앱의 컨테이너로 사용하려고합니다. 이를 위해 우리는 `Router` 내에 `App` 컴포넌트를 캡슐화 할 것입니다.

<img class="code-marker" src="/assets/s.png" />`src/index.js` 에서 아래 코드를 대체합니다:

``` coffee
ReactDOM.render(<App />, document.getElementById('root'));
```

<img class="code-marker" src="/assets/s.png" />바꿀 내용:

``` coffee
ReactDOM.render(
  <Router>
    <App />
  </Router>,
  document.getElementById("root")
);
```

<img class="code-marker" src="/assets/s.png" />그리고 `src/index.js`에 아래 내용을 맨 윗 부분에 붙여 넣습니다.

``` coffee
import { BrowserRouter as Router } from "react-router-dom";
```

우리는 위에서 다음 두 가지를 조금 수정했습니다.

1. 라우터로 `BrowserRouter`를 사용합니다. 브라우저의 [History](https://developer.mozilla.org/en-US/docs/Web/API/History) API를 사용하여 실제 URL을 만듭니다.
2. `Router`를 사용하여 우리의 `App` 컴포넌트를 렌더링합니다. 이렇게하면 우리가 필요한 경로를 우리의 `App` 구성 요소 안에 만들 수 있습니다.

이제 브라우저로 이동하면 앱이 이전과 마찬가지로 로드됩니다. 유일한 차이점은 React Router를 사용하여 페이지를 제공한다는 것입니다.

다음으로 앱의 다른 페이지를 추가하는 방법을 살펴 보겠습니다.

