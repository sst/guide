---
layout: post
title: Give Feedback While Logging In
date: 2017-01-18 00:00:00
lang: ko
ref: give-feedback-while-logging-in
description: React.js 앱에 로그인하는 동안 사용자에게 몇 가지 피드백을 제공해야합니다. 이렇게하려면 React-Bootstrap Button 구성 요소 내에서 Glyphicon 새로 고침 아이콘을 움직이는 컴포넌트를 만듭니다. 로그인 호출이 진행되는 동안 애니메이션을 수행합니다. 
context: true
comments_id: give-feedback-while-logging-in/46
---

로그인하는 동안 사용자에게는 몇 가지 피드백을 제공하는 것이 중요합니다. 그래서 응답이 없는 것과는 달리 앱이 여전히 작동 중임을 알 수 있습니다.

### isLoading 플래그 사용하기

{%change%} `src/containers/Login.js`의 state에 `isLoading` 플래그를 추가합니다. 그러면 `constructor`의 초기 state는 다음과 같습니다.

``` javascript
this.state = {
  isLoading: false,
  email: "",
  password: ""
};
```

{%change%} 그리고 로그인하는 동안 업데이트합니다. 그러면 `handleSubmit` 메쏘드는 다음과 같습니다:

``` javascript
handleSubmit = async event => {
  event.preventDefault();

  this.setState({ isLoading: true });

  try {
    await Auth.signIn(this.state.email, this.state.password);
    this.props.userHasAuthenticated(true);
    this.props.history.push("/");
  } catch (e) {
    alert(e.message);
    this.setState({ isLoading: false });
  }
}
```

### Loader Button 만들기

이제 버튼의 상태 변화를 반영하기 위해 `isLoading` 플래그에 따라 다르게 렌더링 합니다. 그리고 우리는 다른 곳들에서 이 코드를 사용할 예정입니다. 따라서 재사용 가능한 컴포넌트를 만드는 것이 보다 합리적입니다.

{%change%} `src/components/LoaderButton.js` 파일을 만들고 아래 내용을 추가합니다.

``` coffee
import React from "react";
import { Button, Glyphicon } from "react-bootstrap";
import "./LoaderButton.css";

export default ({
  isLoading,
  text,
  loadingText,
  className = "",
  disabled = false,
  ...props
}) =>
  <Button
    className={`LoaderButton ${className}`}
    disabled={disabled || isLoading}
    {...props}
  >
    {isLoading && <Glyphicon glyph="refresh" className="spinning" />}
    {!isLoading ? text : loadingText}
  </Button>;
```

이것은 `isLoading` 플래그와 버튼이 두 가지 상태(기본 상태 및 로드 상태)를 나타내도록 텍스트를 사용하는 매우 간단한 컴포넌트입니다. `disabled` 속성은 `Login` 버튼이 현재 가지고있는 결과입니다. 그리고 `isLoading`이 `true` 일 때 버튼이 비활성화되도록 합니다. 이렇게 하면 사용자가 로그인하는 동안 이 버튼을 클릭 할 수 없게됩니다.

로딩 아이콘에 애니메이션을 적용하는 몇 가지 스타일을 추가해 보겠습니다.

{%change%} `src/components/LoaderButton.css` 파일에 아래 내용을 추가합니다.

``` css
.LoaderButton .spinning.glyphicon {
  margin-right: 7px;
  top: 2px;
  animation: spin 1s infinite linear;
}
@keyframes spin {
  from { transform: scale(1) rotate(0deg); }
  to { transform: scale(1) rotate(360deg); }
}
```

초 단위로 회전하는 Glyphicon은 새로 고침을 이용해 무한대로 회전시킵니다. 그리고 이 스타일을 `LoaderButton`의 일부분으로 추가함으로써 컴포넌트 내에 포함시킵니다.

### isLoading 플래그를 사용하여 렌더링하기

이제 우리의 새로운 컴포넌트를 `Login` 컨테이너에서 사용할 수 있습니다.

{%change%} `src/containers/Login.js` 파일의 `render` 함수에서 `<Button>` 컴포넌트를 찾습니다.

``` html
<Button
  block
  bsSize="large"
  disabled={!this.validateForm()}
  type="submit"
>
  Login
</Button>
```

{%change%} 그리고 위 내용을 아래와 같이 바꿉니다.

``` html
<LoaderButton
  block
  bsSize="large"
  disabled={!this.validateForm()}
  type="submit"
  isLoading={this.state.isLoading}
  text="Login"
  loadingText="Logging in…"
/>
```

{%change%} 또한 헤더에서 `LoaderButton`을 import 합니다. 그리고 `Button`에 대한 참조를 제거합니다.

``` javascript
import { FormGroup, FormControl, FormLabel } from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
```

이제 브라우저로 전환하여 로그인을 시도하면 로그인이 완료되기 전에 로딩이 진행중인 상태가 표시됩니다.

![로그인 로딩 상태 화면](/assets/login-loading-state.png)

사용자를 위한 _비밀번호 찾기_ 기능을 추가하려면 [사용자 관리에 관한 추가 크레딧 시리즈]({% link _chapters/manage-user-accounts-in-aws-amplify.md %})를 참조하십시오.

이제 계속해서 회원 가입 프로세스를 구현해보도록 하겠습니다.
