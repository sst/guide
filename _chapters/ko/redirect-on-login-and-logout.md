---
layout: post
title: Redirect on Login and Logout
date: 2017-01-17 00:00:00
lang: ko
ref: redirect-on-login-and-logout
description: 로그인 후 사용자가 React.js 앱에서 로그아웃 한 후 리디렉션 되도록 React Router v6의 withRouter higher-order 컴포넌트를 사용하고 nav.push 메서드를 사용하여 앱을 탐색합니다.
context: true
comments_id: redirect-on-login-and-logout/154
---

자연스로운 로그인 흐름을 완성하려면 추가적으로 두 가지 작업을 더 수행해야합니다.

1. 로그인 한 후 사용자를 홈페이지로 리디렉션하십시오.
2. 로그아웃 한 후 다시 로그인 페이지로 리디렉션하십시오.

React Router v6와 함께 제공되는 `nav.push` 메소드를 사용합니다.

### 로그인시 홈 화면으로 리디렉션

`Login` 컴포넌트는 `Route`를 사용하여 렌더링되기 때문에, 라우터 속성을 추가합니다. 그래서 `this.props.nav.push` 메쏘드를 사용하여 리디렉션할 수 있습니다.

```js
this.props.nav("/");
```

{%change%} `src/containers/Login.js`의 `handleSubmit` 메소드를 다음과 같이 갱신하십시오:

```js
handleSubmit = async (event) => {
  event.preventDefault();

  try {
    await Auth.signIn(this.state.email, this.state.password);
    this.props.userHasAuthenticated(true);
    this.props.nav("/");
  } catch (e) {
    alert(e.message);
  }
};
```

이제 브라우저로 가서 로그인을 시도하면 로그인 한 후에 홈페이지로 리디렉션되어야합니다.

![React Router v6 로그인 후 홈페이지로 리디렉션 화면](/assets/redirect-home-after-login.png)

### 로그아웃 한 후에 로그인 화면으로 리디렉션

이제 실제와 같은 로그아웃 프로세스와 동일한 처리를 하겠습니다. 그러나 `App` 컴포넌트는 `Route` 컴포넌트 내부에서 렌더링되지 않기 때문에 라우터 속성에 직접 접근 할 수 없습니다. `App` 컴포넌트에서 라우터 속성을 사용하기 위해서는 `withRouter` [Higher-Order 컴포넌트](https://facebook.github.io/react/docs/higher-order-components)(또는 HOC)를 사용할 필요가 있습니다. [여기서](https://reacttraining.com/react-router/web/api/withRouter)에 `withRouter` HOC에 대한 자세한 내용을 볼 수 있습니다.

이 HOC를 사용하기 위해 App 컴포넌트를 내보내는 방식을 변경하겠습니다.

{%change%} `src/App.js`에서 아래 행을 변경합니다.

```coffee
export default App;
```

{%change%} 위 내용을 다음으로 바꿉니다.

```coffee
export default withRouter(App);
```

{%change%} 그리고 `src/App.js`의 헤더에 있는 `import {Link}` 행을 다음과 같이 바꾸어 `withRouter`를 가져옵니다:

```coffee
import { Link, withRouter } from "react-router-dom";
```

{%change%} `src/App.js`에 있는 `handleLogout` 메소드의 맨 아래에 다음을 추가하십시오.

```coffee
this.props.nav("/login");
```

그래서 handleLogout 메소드는 다음과 같이 보일 것입니다.

```coffee
handleLogout = async event => {
  await Auth.signOut();

  this.userHasAuthenticated(false);

  this.props.nav("/login");
}
```

사용자가 로그아웃하면 다시 로그인 페이지로 리디렉션됩니다.

이제 브라우저로 이동하여 실제 로그아웃하면 로그인 페이지로 리디렉션되어야합니다.

로그인 호출에 약간의 지연이 있기 때문에이 호출을 테스트하는 동안 로그인 호출이 진행 중임을 사용자에게 피드백해야 할 수도 있습니다. 이어서 바로 처리 해보겠습니다.
