---
layout: post
title: Login with AWS Cognito
date: 2017-01-14 00:00:00
lang: ko
ref: login-with-aws-cognito
description: 사용자가 React.js 앱에서 Amazon Cognito를 사용하여 로그인 할 수있게하려면 AWS Amplify를 사용합니다. Cognito 사용자 풀 ID와 앱 클라이언트 ID가 필요합니다. AWS Amplify에서 Auth.signIn() 메소드를 호출하여 로그인합니다.
context: true
comments_id: login-with-aws-cognito/129
---

AWS Amplify를 사용하여 Amazon Cognito 설정에 로그인합니다. 가져 오기부터 시작하겠습니다.

### AWS Amplify에서 Auth 가져 오기

<img class="code-marker" src="/assets/s.png" />`src/containers/Login.js`에 있는 Login 컨테이너의 헤더에 다음을 추가하십시오.

``` coffee
import { Auth } from "aws-amplify";
```

### Amazon Cognito 로그인하기

로그인 코드 자체는 비교적 간단합니다.

<img class="code-marker" src="/assets/s.png" />`src/containers/Login.js` 파일의 `handleSubmit` 메소드를 다음과 같이 바꾸기만 하면 됩니다.

``` javascript
handleSubmit = async event => {
  event.preventDefault();

  try {
    await Auth.signIn(this.state.email, this.state.password);
    alert("Logged in");
  } catch (e) {
    alert(e.message);
  }
}
```

여기서는 두 가지를 처리하고 있습니다.

1. `this.state`에서`email`과`password`를 가져 와서 Amplify의`Auth.signIn()` 메소드를 호출합니다. 이 메서드는 사용자를 비동기적으로 로깅하므로 promise를 반환합니다.

2. `await` 키워드를 사용하여 promise를 반환하는 Auth.signIn() 메소드를 호출합니다. 그리고 `handleSubmit` 메쏘드에 `async`라는 키워드를 붙일 필요가 있습니다.

이제 `admin@example.com` 사용자([Cognito 테스트 사용자 만들기]({% link _chapters/create-a-cognito-test-user.md %}) 챕터에서 작성한 사용자)로 로그인하면, 로그인이 성공했다는 브라우저 경고가 표시됩니다.

![로그인 성공 스크린 샷](/assets/login-success.png)

다음으로 앱에 로그인 상태를 저장하는 방법을 살펴 보겠습니다.
