---
layout: post
title: Create Containers
date: 2017-01-11 00:00:00
lang: ko
ref: create-containers
description: React.js 앱을 여러 경로로 나누기 위해 React Router v4의 컨테이너를 사용하여 구조화 할 것이다. 또한 Navbar React-Bootstrap 구성 요소를 App 컨테이너에 추가 할 예정입니다.
context: true
comments_id: create-containers/62
---

현재 우리 앱에는 콘텐츠를 렌더링하는 컴포넌트가 하나 있습니다. 노트 작성 앱을 만들려면 노트에 대한 불러오기/수정/작성을 위해 몇 개의 다른 페이지들을 만들어야합니다. 이를 수행하기 전에 앱의 외부 컨텐트를 구성 요소 안에 모두 넣고 내부의 모든 최상위 구성 요소를 렌더링합니다. 다양한 페이지를 나타내는 이러한 최상위 구성 요소를 컨테이너라고합니다.

### 탐색 바 추가하기

먼저 탐색 바를 추가하여 애플리케이션의 외부 컨텐트를 만들어 보겠습니다. 여기서 [Navbar](https://react-bootstrap.github.io/components/navbar/) React-Bootstrap 구성 요소를 사용하겠습니다.

<img class = "code-marker" src="/assets/s.png"/> 시작하려면, Create React App에 원래 있던 `src/logo.svg`를 제거합니다.

``` bash
$ rm src/logo.svg
```

<img class="code-marker" src="/assets/s.png" />그리고 `src/App.js`에서도 코드를 제거합니다. 그리고 아래 내용으로 대체합니다.

``` coffee
import React, { Component } from "react";
import { Link } from "react-router-dom";
import { Navbar } from "react-bootstrap";
import "./App.css";

class App extends Component {
  render() {
    return (
      <div className="App container">
        <Navbar fluid collapseOnSelect>
          <Navbar.Header>
            <Navbar.Brand>
              <Link to="/">Scratch</Link>
            </Navbar.Brand>
            <Navbar.Toggle />
          </Navbar.Header>
        </Navbar>
      </div>
    );
  }
}

export default App;
```

여기에 아래와 같이 몇 가지를 더 수정했습니다.

1. `div.container`에 Bootstrap을 사용하여 고정 너비 컨테이너 생성하기.
2. `fluid` 속성을 사용하여 컨테이너 너비에 맞는 탐색 바를 내부에 추가합니다.
3. React-Router의 `Link` 컴포넌트를 사용하여 앱의 홈페이지 링크를 처리하십시오 (페이지를 새로 고치지 않아도됩니다).

또한 몇 줄의 스타일을 추가하여 좀 더 공간을 넓힙니다.

<img class="code-marker" src="/assets/s.png" />`src/App.css` 안에 모든 코드를 제거하고 아래 내용으로 바꿉니다:

``` css
.App {
  margin-top: 15px;
}

.App .navbar-brand {
  font-weight: bold;
}
```

### Home 컨테이너 추가하기 

이제 외부 컨텐트를 넣기 위한 준비가 되었으므로 홈페이지에 컨테이너를 추가해 봅시다. 홈페이지 컨테이너를 추가하면 `/` 경로에 응답합니다.

<img class="code-marker" src="/assets/s.png" />작업 디렉토리에 아래 명령을 실행해서 `src/containers/` 디렉터리를 만듭니다.

``` bash
$ mkdir src/containers/
```

최상위 레벨의 모든 구성 요소를 여기에 저장합니다. 이는 단일 페이지 앱의 경로에 응답하고 API 요청을 처리할 구성 요소들입니다. 이 자습서의 나머지 부분에서는 이들을 *컨테이너*라고 부르겠습니다.

<img class="code-marker" src="/assets/s.png" />새로운 컨테이너를 생성하기 위해 아래 코드를 새로 만든 파일인 `src/containers/Home.js`에 추가합니다.

``` coffee
import React, { Component } from "react";
import "./Home.css";

export default class Home extends Component {
  render() {
    return (
      <div className="Home">
        <div className="lander">
          <h1>Scratch</h1>
          <p>A simple note taking app</p>
        </div>
      </div>
    );
  }
}
```

사용자가 현재 로그인되어 있지 않다면 바로 이 홈페이지를 렌더링합니다.

이제 스타일을 지정하기 위해 몇 줄을 추가해 보겠습니다.

<img class="code-marker" src="/assets/s.png" />`src/containers/Home.css`에 아래 내용을 추가합니다.

``` css
.Home .lander {
  padding: 80px 0;
  text-align: center;
}

.Home .lander h1 {
  font-family: "Open Sans", sans-serif;
  font-weight: 600;
}

.Home .lander p {
  color: #999;
}
```

### 라우트 설정하기

이제 `/`에 응답하는 컨테이너를 위해 경로를 설정하겠습니다.

<img class="code-marker" src="/assets/s.png" />`src/Routes.js`를 만들고 아래 내용을 작성합니다.

``` coffee
import React from "react";
import { Route, Switch } from "react-router-dom";
import Home from "./containers/Home";

export default () =>
  <Switch>
    <Route path="/" exact component={Home} />
  </Switch>;
```

이 구성 요소는 React-Router의 `Switch` 컴포넌트를 사용하여 그 안에 정의 된 첫 번째로 일치하는 경로를 렌더링합니다. 지금은 단 하나의 경로만을 가지고 있습니다. `/`를 찾아서 일치 할 때 `Home` 컴포넌트를 렌더링합니다. 그리고 `exact` 속성을 사용하여 `/` 경로와 정확히 일치하는지 확인합니다. `/` 경로는 `/`로 시작하는 다른 경로와도 일치하기 때문입니다.

### 경로 렌더링하기 

이제 경로를 App 구성 요소로 렌더링 해 봅시다.

<img class="code-marker" src="/assets/s.png" />`src/App.js`의 헤더 부분에 아래 내용을 추가합니다.

``` coffee
import Routes from "./Routes";
```

<img class="code-marker" src="/assets/s.png" />그리고 `src/App.js`의 `render` 내부에 있는 `Navbar` 컴포넌트 아래에 다음 내용을 추가합니다.

``` coffee
<Routes />
```

그래서 `src/App.js`의 `render` 메소드는 다음과 같이 보일 것입니다.

``` coffee
render() {
  return (
    <div className="App container">
      <Navbar fluid collapseOnSelect>
        <Navbar.Header>
          <Navbar.Brand>
            <Link to="/">Scratch</Link>
          </Navbar.Brand>
          <Navbar.Toggle />
        </Navbar.Header>
      </Navbar>
      <Routes />
    </div>
  );
}
```

이렇게하면 앱의 다른 경로를 탐색할 때 탐색 표시 줄 아랫 부분이 변경되어 해당 경로가 반영됩니다.

마지막으로 브라우저로 가서 앱의 새로운 홈페이지가 표시되는지 확인합니다.

![새 홈페이지로드 스크린 샷](/assets/new-homepage-loaded.png)

다음으로 탐색 바에 로그인과 가입 링크를 추가하겠습니다.
