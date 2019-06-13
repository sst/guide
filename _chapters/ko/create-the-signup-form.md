---
layout: post
title: Create the Signup Form
date: 2017-01-20 00:00:00
lang: ko
ref: create-the-signup-form
description: 우리는 React.js 앱을 위한 가입 페이지를 만들 예정입니다. Amazon Cognito를 사용하여 사용자를 등록하려면 사용자가 이메일로 전송된 인증 코드를 입력할 수있는 양식을 만들어야합니다. 
context: true
comments_id: create-the-signup-form/52
---

먼저 사용자의 이메일과 비밀번호를 얻을 수 있는 가입 양식을 만들어 보겠습니다.

### 컨테이너 추가

<img class="code-marker" src="/assets/s.png" />다음과 같이 `src/containers/Signup.js`에 새 컨테이너를 만듭니다.

``` coffee
import React, { Component } from "react";
import {
  HelpBlock,
  FormGroup,
  FormControl,
  ControlLabel
} from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
import "./Signup.css";

export default class Signup extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isLoading: false,
      email: "",
      password: "",
      confirmPassword: "",
      confirmationCode: "",
      newUser: null
    };
  }

  validateForm() {
    return (
      this.state.email.length > 0 &&
      this.state.password.length > 0 &&
      this.state.password === this.state.confirmPassword
    );
  }

  validateConfirmationForm() {
    return this.state.confirmationCode.length > 0;
  }

  handleChange = event => {
    this.setState({
      [event.target.id]: event.target.value
    });
  }

  handleSubmit = async event => {
    event.preventDefault();

    this.setState({ isLoading: true });

    this.setState({ newUser: "test" });

    this.setState({ isLoading: false });
  }

  handleConfirmationSubmit = async event => {
    event.preventDefault();

    this.setState({ isLoading: true });
  }

  renderConfirmationForm() {
    return (
      <form onSubmit={this.handleConfirmationSubmit}>
        <FormGroup controlId="confirmationCode" bsSize="large">
          <ControlLabel>Confirmation Code</ControlLabel>
          <FormControl
            autoFocus
            type="tel"
            value={this.state.confirmationCode}
            onChange={this.handleChange}
          />
          <HelpBlock>Please check your email for the code.</HelpBlock>
        </FormGroup>
        <LoaderButton
          block
          bsSize="large"
          disabled={!this.validateConfirmationForm()}
          type="submit"
          isLoading={this.state.isLoading}
          text="Verify"
          loadingText="Verifying…"
        />
      </form>
    );
  }

  renderForm() {
    return (
      <form onSubmit={this.handleSubmit}>
        <FormGroup controlId="email" bsSize="large">
          <ControlLabel>Email</ControlLabel>
          <FormControl
            autoFocus
            type="email"
            value={this.state.email}
            onChange={this.handleChange}
          />
        </FormGroup>
        <FormGroup controlId="password" bsSize="large">
          <ControlLabel>Password</ControlLabel>
          <FormControl
            value={this.state.password}
            onChange={this.handleChange}
            type="password"
          />
        </FormGroup>
        <FormGroup controlId="confirmPassword" bsSize="large">
          <ControlLabel>Confirm Password</ControlLabel>
          <FormControl
            value={this.state.confirmPassword}
            onChange={this.handleChange}
            type="password"
          />
        </FormGroup>
        <LoaderButton
          block
          bsSize="large"
          disabled={!this.validateForm()}
          type="submit"
          isLoading={this.state.isLoading}
          text="Signup"
          loadingText="Signing up…"
        />
      </form>
    );
  }

  render() {
    return (
      <div className="Signup">
        {this.state.newUser === null
          ? this.renderForm()
          : this.renderConfirmationForm()}
      </div>
    );
  }
}
 
```

우리가 여기에서 하는 대부분의 작업은 매우 간단하므로 빨리 넘어 가겠습니다.

1. 사용자에게 확인 코드를 입력하는 양식도 보여줘야하기 때문에 사용자 정보가 있는지 여부에 따라 두 가지 양식을 조건부로 렌더링합니다.

2. 이전에 제출 버튼을 위해 생성한 LoaderButton 컴포넌트를 사용하고 있습니다.

3. 두 가지 양식이 있기 때문에 `validateForm` 과 `validateConfirmationForm`이라는 두 가지 유효성 검사 방법이 있습니다.

4. 이메일과 확인 코드 필드에 `autoFocus` 플래그를 설정합니다.

5. `handleSubmit` 과 `handleConfirmationSubmit`은 `isLoading` 상태와 `newUser` 상태를 위한 더미 값을 설정하는 것 외에 별다른 기능이 없습니다.

<img class="code-marker" src="/assets/s.png" />그리고 `src/containers/Signup.css`에 몇 가지 스타일을 추가해 보겠습니다.


``` css
@media all and (min-width: 480px) {
  .Signup {
    padding: 60px 0;
  }

  .Signup form {
    margin: 0 auto;
    max-width: 320px;
  }
}

.Signup form span.help-block {
  font-size: 14px;
  padding-bottom: 10px;
  color: #999;
}
```

### 경로 추가

<img class="code-marker" src="/assets/s.png" />마지막으로 컨테이너를 로그인 경로 아래의 `src/Routes.js`에있는 경로로 추가하십시오. 참고로 ["세션을 state에 추가하기"]({% link _chapters/add-the-session-to-the-state.md %}) 챕터에서 작성한 `AppliedRoute` 컴포넌트를 사용하고 있습니다.

``` coffee
<AppliedRoute path="/signup" exact component={Signup} props={childProps} />
```

그리고 헤더에 컴포넌트를 import합니다.

``` javascript
import Signup from "./containers/Signup";
```

이제 브라우저로 전환하여 가입 페이지로 이동하면 새로 생성된 양식을 볼 수 있습니다. 이 양식은 왠지 단순 정보를 입력만 받는 것 같지만, 이메일, 암호 및 확인 코드를 입력해 사용자들이 가입하는 페이지입니다. 일단 Cognito와 연결하면 이 양식이 어떻게 작동하는지 알 수 있습니다.

![가입 페이지 스크린 샷 추가](/assets/signup-page-added.png)

다음으로 가입 양식을 Amazon Cognito에 연결해 보겠습니다.
