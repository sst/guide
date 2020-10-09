---
layout: post
title: Load the State from the Session
date: 2017-01-15 00:00:00
lang: ko
ref: load-the-state-from-the-session
description: 사용자가 React.js 앱에서 Amazon Cognito에 로그인 한 상태로 유지하려면 App 세션 state에서 사용자 세션을 로드해야합니다. AWS Amplify Auth.currentSession() 메소드를 사용하여 componentDidMount에 세션을로드합니다.
context: true
comments_id: load-the-state-from-the-session/157
---

로그인 정보를 계속 유지하려면 브라우저 세션에 저장하고 로드해야합니다. 쿠키 또는 로컬 저장소를 사용하여이 작업을 수행 할 수 있는 몇 가지 방법이 있습니다. 고맙게도 AWS Amplify는 자동으로이 작업을 수행하며, AWS Amplify를 통해 해당 내용을 읽고 응용 프로그램 state로 불러오면 됩니다.

Amplify는 `Auth.currentSession()` 메소드를 사용하여 현재 사용자 세션을 얻을 수 있는데, 만일 세션 객체가 있다면 promise 형태로 반환합니다.

### 사용자 세션 불러오기

앱이 브라우저에 로드 될 때 사용자 세션을 불러오겠습니다. 먼저 `componentDidMount`에서 이를 처리합니다. `Auth.currentSession()`이 promise를 반환하므로 앱이 완전히 로드가 완료된 상태로 준비가 되어 있어야합니다.

{%change%} 이를 위해 `isAuthenticating`라고 하는 `src/App.js`의 state에 플래그를 추가합니다. 생성자의 초기 상태는 다음과 같아야합니다.

``` javascript
this.state = {
  isAuthenticated: false,
  isAuthenticating: true
};
```

{%change%} `Auth` 모듈을 `src/App.js` 헤더에 다음과 같이 추가해 보겠습니다.

``` javascript
import { Auth } from "aws-amplify";
```

{%change%} 이제 사용자 세션을 불러오기 위해 우리는 `src/App.js`의 `constructor` 메소드 아래에 다음을 추가 할 것입니다.

``` javascript
async componentDidMount() {
  try {
    await Auth.currentSession();
    this.userHasAuthenticated(true);
  }
  catch(e) {
    if (e !== 'No current user') {
      alert(e);
    }
  }

  this.setState({ isAuthenticating: false });
}
```

위 코드는 현재 세션을 불러오는 것입니다. 일단 로드가 되고 나면 `isAuthenticating` 플래그를 갱신합니다. 만일 아무도 현재 로그인하지 않았다면 `Auth.currentSession()` 메소드는 `현재 사용자 없음` 오류를 던질겁니다. 그러나 여기서는 로그인하지 않은 상태에서 이 오류를 사용자에게 보여주고 싶지 않습니다.

### 준비가 되면 렌더링하기

사용자 세션을 로드하는 것은 비동기 프로세스이기 때문에 처음 로드 할 때 앱이 state를 변경하지 않도록 해야합니다. 이렇게 하기 위해 `isAuthenticating`가 `false`가 될 때까지 앱을 렌더링하지 말아야 합니다.

여기서는`isAuthenticating` 플래그에 기반하여 앱을 조건부로 렌더링합니다.

{%change%} `src/App.js`의 `render` 메소드는 아래와 같아야 합니다. 

``` coffee
render() {
  const childProps = {
    isAuthenticated: this.state.isAuthenticated,
    userHasAuthenticated: this.userHasAuthenticated
  };

  return (
    !this.state.isAuthenticating &&
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
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes childProps={childProps} />
    </div>
  );
}
```

이제 브라우저로 가서 페이지를 새로 고침하면 사용자가 로그인되어 있어야합니다.

![세션에서로드 된 스크린 샷 스크린 샷](/assets/login-from-session-loaded.png)

하지만 로그 아웃하고 페이지를 새로 고침하면 여전히 로그인되어 있을겁니다. 이를 해결하기 위해 다음 장에서 로그아웃할 때 세션을 지우도록 하겠습니다.
