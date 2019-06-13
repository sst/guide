---
layout: post
title: Add the Session to the State
date: 2017-01-15 00:00:00
lang: ko
ref: add-the-session-to-the-state
redirect_from: /chapters/add-the-user-token-to-the-state.html
description: React.js 앱에서 App 세션 상태에 사용자 세션을 추가해야합니다. 상태를 추가하게 되면 해당 사용자 세션을 모든 하위 컨테이너에 전달할 수 있습니다. 
context: true
comments_id: add-the-session-to-the-state/136
---

로그인 프로세스를 완료하려면 사용자가 로그인했음을 알리기 위해 세션과 함께 App state를 업데이트해야합니다.

### App State 업데이트 

먼저 사용자 로그인을 한 상태에서 App state를 업데이트하는 것으로 시작합니다. 이 항목을 `Login` 컨테이너에 저장하고 싶지만 다른 곳에서도 이 항목을 사용하므로 가장 적합한 곳은 `App` 컨테이너입니다.

<img class="code-marker" src="/assets/s.png" />`src/App.js`를 열어서 `class App extends Component {` 줄 바로 아래에 다음 내용을 추가합니다.

``` javascript
constructor(props) {
  super(props);

  this.state = {
    isAuthenticated: false
  };
}

userHasAuthenticated = authenticated => {
  this.setState({ isAuthenticated: authenticated });
}
```

이것은 App state의 `isAuthenticated` 플래그를 초기화합니다. `userHasAuthenticated`를 호출하면 업데이트됩니다. 그러나 `Login` 컨테이너가 이 메소드를 호출하기 위해서는 이 메소드에 대한 참조를 전달해야합니다.

### Routes에 세션 상태 전달하기

우리는 `App` 컴포넌트에서 생성된 경로의 자식 컴포넌트에 두 개의 속성값을 전달함으로써 이를 수행 할 수 있습니다.

<img class="code-marker" src="/assets/s.png" />`src/App.js`의 `render() {` 줄 바로 아래에 다음 내용을 추가합니다 .

``` javascript
const childProps = {
  isAuthenticated: this.state.isAuthenticated,
  userHasAuthenticated: this.userHasAuthenticated
};
```

<img class="code-marker" src="/assets/s.png" />`src/App.js`의 `render` 메쏘드에서 다음 라인을 대체하여 `Routes` 컴포넌트로 전달하십시오.

``` coffee
<Routes />
```

<img class="code-marker" src="/assets/s.png" />위 내용을 다음 내용으로 변경

``` coffee
<Routes childProps={childProps} />
```

현재 `Routes` 컴포넌트는 `childProps`에 전달 된 값을 가지고 아무것도 하지 않습니다. 이러한 속성을 렌더링 할 하위 컴포넌트에 이를 적용해야합니다. 이 경우에는 `Login` 컴포넌트에 적용 할 필요가 있을 것 같습니다.

이를 위해 새로운 컴포넌트를 생성합니다.

<img class="code-marker" src="/assets/s.png" />작업 디렉토리에서 다음 명령을 실행하여 `src/components/` 디렉토리를 만듭니다.

``` bash
$ mkdir src/components/
```

이곳에 우리는 API를 직접 다루지 않거나 경로에 응답하는 모든 React 구성 요소들을 저장하겠습니다.

<img class="code-marker" src="/assets/s.png" />`src/components/AppliedRoute.js`라는 새로운 컴포넌트를 만들고 다음을 추가하십시오.

``` coffee
import React from "react";
import { Route } from "react-router-dom";

export default ({ component: C, props: cProps, ...rest }) =>
  <Route {...rest} render={props => <C {...props} {...cProps} />} />;
```

이 간단한 컴포넌트는 전달할 속성값을 렌더링하는 자식 컴포넌트에 `Route`를 생성합니다. 이 작업이 어떻게 수행되는지 간단히 살펴 보겠습니다.

- `Route` 컴포넌트는 일치하는 경로가 발견되었을 때 렌더링 될 컴포넌트를 나타내는 `component`라는 속성을 가집니다. 여기서 `childProps`가 이 컴포넌트로 전달 되도록 말이죠.

- `Route` 컴포넌트는 `component` 대신 `render` 메소드를 사용할 수도 있습니다. 이를 통해 우리는 컴포넌트로 전달되는 것들을 제어 할 수 있습니다.

- 결과적으로 우리는 `Route`를 리턴하고`component` 와 `childProps` 속성을 가지는 컴포넌트를 생성 할 수 있습니다. 이를 통해 렌더링하고자하는 컴포넌트와 적용하고자하는 속성들을 전달할 수 있습니다.

마지막으로 `component`(`C`로 설정)과 `props`(`cProps`으로 설정)을 가져 와서 `Route` 내부에서 인라인 함수를 사용하여 렌더링합니다. `props => <C {... props} {... cProps} />` 에서 말이죠. 이 경우 `props` 변수는 Route 컴포넌트가 우리에게 전달하는 변수입니다. 반면, `cProps`는 우리가 설정하고자하는 `childProps`입니다.

이제 이 컴포넌트를 사용하기 위해 우리는 `childProps`를 전달해야 할 경로에 이 컴포넌트를 포함시킵니다.

<img class="code-marker" src="/assets/s.png" />`src/Routes.js` 파일의 `export default () => (` 메소드를 다음으로 대체합니다. 

``` coffee
export default ({ childProps }) =>
  <Switch>
    <AppliedRoute path="/" exact component={Home} props={childProps} />
    <AppliedRoute path="/login" exact component={Login} props={childProps} />
    { /* Finally, catch all unmatched routes */ }
    <Route component={NotFound} />
  </Switch>;
```

<img class="code-marker" src="/assets/s.png" />`src/Routes.js` 파일의 헤더에 새로운 컴포넌트를 추가합니다.

``` coffee
import AppliedRoute from "./components/AppliedRoute";
```

이제 `Login` 컨테이너에서 `userHasAuthenticated` 메소드를 호출 할 것입니다.

<img class="code-marker" src="/assets/s.png" />`src/containers/Login.js`에 `alert ( 'Logged in');` 행을 다음 행으로 대체하십시오.

``` javascript
this.props.userHasAuthenticated(true);
```

### 로그아웃 버튼 만들기

이제 사용자가 로그인하면 `로그아웃`으로 버튼을 표시해야합니다. `src/App.js`에서 다음을 찾아보세요.

``` coffee
<LinkContainer to="/signup">
  <NavItem>Signup</NavItem>
</LinkContainer>
<LinkContainer to="/login">
  <NavItem>Login</NavItem>
</LinkContainer>
```

<img class="code-marker" src="/assets/s.png" />그리고 다음 내용으로 대체합니다:

``` coffee
{this.state.isAuthenticated
  ? <NavItem onClick={this.handleLogout}>Logout</NavItem>
  : <Fragment>
      <LinkContainer to="/signup">
        <NavItem>Signup</NavItem>
      </LinkContainer>
      <LinkContainer to="/login">
        <NavItem>Login</NavItem>
      </LinkContainer>
    </Fragment>
}
```

그리고 헤더에 `Fragment`를 import 합니다. 

<img class="code-marker" src="/assets/s.png" />`src/App.js` 파일의 헤더에 `import React` 행을 다음으로 대체합니다. 

``` coffee
import React, { Component, Fragment } from "react";
```

`Fragment` 컴포넌트는 placeholder 컴포넌트로 생각할 수 있습니다. 사용자가 로그인하지 않은 경우 두 개의 링크를 렌더링해야하기 때문에 이 정보가 필요합니다. 이렇게 하려면 'div'와 같은 단일 컴포넌트 안에 감쌀 필요가 있습니다. 그러나 `Fragment` 컴포넌트를 사용하여 React에 두 개의 링크가 이 컴포넌트 안에 있음을 알려주지만 추가 HTML은 렌더링하지 않습니다.

<img class="code-marker" src="/assets/s.png" />`src/App.js` 파일의 `handleLogout` 메소드를 추가하고 `render() {` 위에 다음 내용을 추가합니다.

``` coffee
handleLogout = event => {
  this.userHasAuthenticated(false);
}
```

이제 브라우저로 가서 [Cognito 테스트 사용자 만들기]({% link _chapters/create-a-cognito-test-user.md %}) 챕터에서 만든 관리자 자격 증명으로 로그인 해보십시오. 로그아웃 버튼이 바로 나타납니다.

![로그인 상태 업데이트 스크린 샷](/assets/login-state-updated.png)

이제 페이지를 새로 고침하면 다시 로그아웃해야 합니다. 이것은 브라우저 세션에서 실제로는 상태를 초기화하지 않기 때문입니다. 다음에 그 방법을 살펴 보도록 하겠습니다.
