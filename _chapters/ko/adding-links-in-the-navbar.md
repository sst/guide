---
layout: post
title: Adding Links in the Navbar
date: 2017-01-11 12:00:00
lang: ko
ref: adding-links-in-the-navbar
description: React.js 앱의 Navbar에 링크를 추가하려면 NavItem React-Bootstrap 구성 요소를 사용합니다. 사용자가 링크를 사용하여 탐색 할 수있게하려면 React-Router의 Route 구성 요소를 사용하고 nav.push 메서드를 호출해야합니다.
context: true
comments_id: adding-links-in-the-navbar/141
---

이제 첫 번째 경로를 설정 했으므로 앱의 navbar에 몇 가지 링크를 더 추가해 보겠습니다. 사용자가 처음 방문했을 때 로그인 또는 가입하도록 안내합니다.

{%change%} `src/App.js`에 있는`render` 메쏘드를 다음으로 대체하십시오.

```coffee
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
        <Navbar.Collapse>
          <Nav pullRight>
            <NavItem href="/signup">Signup</NavItem>
            <NavItem href="/login">Login</NavItem>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes />
    </div>
  );
}
```

`NavItem` Bootstrap 컴포넌트를 사용하여 navbar에 두 개의 링크를 추가합니다. `Navbar.Collapse` 컴포넌트는 모바일 장치에서 두 개의 링크가 접혀지도록합니다.

헤더에 필요한 구성 요소를 포함시켜 봅시다.

{%change%} import 항목인 `react-router-dom`와 `react-bootstrap`를 `src/App.js`에서 제거하고 아래 내용으로 대체합니다.

```coffee
import { Link } from "react-router-dom";
import { Nav, Navbar, NavItem } from "react-bootstrap";
```

이제 부라우저 화면을 보면 Navbar에 두 개의 링크가 표시됩니다.
![Navbar links added screenshot](/assets/navbar-links-added.png)

그런데 링크를 클릭하면 리디렉션되는 동안 브라우저가 새로 고침됩니다. 단일 페이지 앱을 제작하고 있으므로 패이지 새로 고침 없이 새 링크로 연결해야 합니다.

이 문제를 해결하려면 [React Router Bootstrap](https://github.com/react-bootstrap/react-router-bootstrap)이라는 React Router 및 React Bootstrap에서 작동하는 컴포넌트가 필요합니다. 이 컴포넌트는 `Navbar` 링크를 감쌀뿐만 아니라 React Router를 사용하여 브라우저를 새로 고치지 않고도 앱을 필요한 링크에 연결할 수 있습니다.

{%change%} 작업 디렉토리에서 다음 명령을 실행하십시오.

```bash
$ npm install react-router-bootstrap --save
```

{%change%} 그리고 `src/App.js`의 최상단에 아래 내용을 추가합니다.

```coffee
import { LinkContainer } from "react-router-bootstrap";
```

{%change%} 이제 링크를`LinkContainer`로 감쌉니다. `src/App.js`에 있는 `render` 메쏘드를 아래 내용으로 바꾸십시오.

```coffee
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
        <Navbar.Collapse>
          <Nav pullRight>
            <LinkContainer to="/signup">
              <NavItem>Signup</NavItem>
            </LinkContainer>
            <LinkContainer to="/login">
              <NavItem>Login</NavItem>
            </LinkContainer>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes />
    </div>
  );
}
```

이게 전부입니다! 이제 브라우저로 넘어 가서 로그인 링크를 클릭하면 링크가 탐색 표시 줄에 강조 표시됩니다. 또한 리디렉션하는 동안 페이지를 새로 고치지 않습니다.

![Navbar 링크 강조 화면](/assets/navbar-link-highlighted.png)

현재 로그인 페이지가 없기 때문에 페이지에 아무 것도 렌더링하지 않습니다. 요청한 페이지를 찾을 수 없는 경우를 위한 처리를 해야합니다.

다음으로 404 응답을 다루기 위한 라우터 설정 방법을 살펴 보겠습니다.
