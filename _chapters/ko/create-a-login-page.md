layout: post
title: Create a Login Page
date: 2017-01-13 00:00:00
lang: ko
ref: create-a-login-page
description: React.js 앱에 로그인 페이지를 추가합니다. 로그인 양식을 만들기 위해서 FormGroup과 FormControl React-Bootstrap 컴포넌트들을 사용합니다.
context: true
comments_id: create-a-login-page/71
---

사용자가 자격 증명으로 로그인할 수 있는 페이지를 만들어 보겠습니다. 사용자가 로그인하거나 회원 가입시에 사용자 이름으로 이메일을 등록 할 수 있도록 이미 앞선 챕터에서 사용자 풀을 만들어 처리해 두었습니다. 나중에 가입 양식을 만들 때에도 다시 언급하겠습니다.

먼저 사용자의 이메일(사용자 이름)과 비밀번호를 입력받기 위한 기본 양식을 만들어 보겠습니다.

### 컨테이너 추가하기 

{%change%} `src/containers/Login.js` 파일을 만들고 다음 내용을 추가합니다.

``` coffee
import React, { Component } from "react";
import { Button, FormGroup, FormControl, FormLabel } from "react-bootstrap";
import "./Login.css";

export default class Login extends Component {
  constructor(props) {
    super(props);

    this.state = {
      email: "",
      password: ""
    };
  }

  validateForm() {
    return this.state.email.length > 0 && this.state.password.length > 0;
  }

  handleChange = event => {
    this.setState({
      [event.target.id]: event.target.value
    });
  }

  handleSubmit = event => {
    event.preventDefault();
  }

  render() {
    return (
      <div className="Login">
        <form onSubmit={this.handleSubmit}>
          <FormGroup controlId="email" bsSize="large">
            <FormLabel>Email</FormLabel>
            <FormControl
              autoFocus
              type="email"
              value={this.state.email}
              onChange={this.handleChange}
            />
          </FormGroup>
          <FormGroup controlId="password" bsSize="large">
            <FormLabel>Password</FormLabel>
            <FormControl
              value={this.state.password}
              onChange={this.handleChange}
              type="password"
            />
          </FormGroup>
          <Button
            block
            bsSize="large"
            disabled={!this.validateForm()}
            type="submit"
          >
            Login
          </Button>
        </form>
      </div>
    );
  }
}
```

우리는 여기에 몇 가지 새로운 개념을 도입하려고 합니다.

1. 컴포넌트의 생성자에서 상태 객체를 만듭니다. 이것은 사용자가 양식에 입력 한 내용을 저장할 위치입니다.

2. 그런 다음 입력 필드에서 `this.state.email` 과 `this.state.password`를 `value`로 설정하여 양식의 두 필드에 상태를 연결합니다. 즉, 상태가 변경되면 React는 업데이트 된 값으로 이러한 구성 요소를 다시 렌더링합니다.

3. 그러나 사용자가 이 필드에 어떤 값을 입력 할 때마다 상태를 바로바로 업데이트하려면 handleChange라는 핸들 함수를 호출합니다. 이 함수는 변경되는 필드의 `id`(`<FormGroup>`에 대한`controlId`로 설정)를 가져오고 그 상태를 사용자가 타이핑하는 값으로 즉시 업데이트합니다. 또한 `this` 키워드를 통해 `handleChange` 안의 익명 함수에 대한 참조를 저장합니다: `handleChange = (event) => {}`.

4. 이메일 필드에 대한 autoFocus 플래그를 설정하여 양식이 로드 될 때 이 필드에 포커스를 설정합니다.

5. 또한 validateForm이라는 validate 함수를 사용하여 submit 버튼을 상태 정보와 연결합니다. 여기서는 이렇게 필드가 비어 있는지 여부만 확인하면 되지만 나중에 더 복잡한 작업을 쉽게 수행 할 수 있습니다.

6. 마지막으로 양식이 제출 될 때 콜백 `handleSubmit` 함수를 트리거합니다. 지금은 양식 제출시 브라우저의 기본 동작을 막아놨지만 나중에 이와 관련해서 더 자세히 설명하겠습니다.

{%change%} `src/containers/Login.css` 파일 안에 몇 가지 스타일을 추가해 보겠습니다.

``` css
@media all and (min-width: 480px) {
  .Login {
    padding: 60px 0;
  }

  .Login form {
    margin: 0 auto;
    max-width: 320px;
  }
}
```

이 스타일은 대략 스마트폰을 제외한 화면 크기를 타겟팅합니다.

### Add the Route

{%change%} 이제 `src/Routes.js`의 `<Route>` 바로 아래에 다음 줄(`반드시 <Route component={NotFound} />` 보다는 위에 줄)을 추가하여 이 컨테이너를 나머지 응용 프로그램과 연결합니다.

``` coffee
<Route path="/login" exact component={Login} />
```

{%change%} 그리고 헤더 부분에 컴포넌트를 추가합니다.

``` javascript
import Login from "./containers/Login";
```

이제 브라우저로 전환하여 로그인 페이지로 이동하면 새로 작성된 양식이 표시됩니다.

![로그인 양식이 추가된 화면](/assets/login-page-added.png)

다음은 여기서 만든 로그인 양식을 AWS Cognito 설정에 연결해보겠습니다.
