---
layout: post
title: Signup with AWS Cognito
date: 2017-01-21 00:00:00
lang: ko
ref: signup-with-aws-cognito
description: Amazon Cognito를 사용하여 React.js 앱에 가입 양식을 구현하기 위해 AWS Amplify를 사용하려고합니다. 우리는 Auth.signUp() 메서드를 호출하여 사용자를 서명하고 인증 코드를 사용하여 Auth.confirmSignUp() 메서드를 호출하여 프로세스를 완료합니다.
context: true
comments_id: signup-with-aws-cognito/130
---

이제 `handleSubmit` 과 `handleConfirmationSubmit` 메소드를 구현해서 AWS Cognito 설정과 연결해 보겠습니다.

{%change%} `src/containers/Signup.js` 파일에서 `handleSubmit` 과 `handleConfirmationSubmit` 메소드를 아래 내용으로 변경합니다.

```js
handleSubmit = async (event) => {
  event.preventDefault();

  this.setState({ isLoading: true });

  try {
    const newUser = await Auth.signUp({
      username: this.state.email,
      password: this.state.password,
    });
    this.setState({
      newUser,
    });
  } catch (e) {
    alert(e.message);
  }

  this.setState({ isLoading: false });
};

handleConfirmationSubmit = async (event) => {
  event.preventDefault();

  this.setState({ isLoading: true });

  try {
    await Auth.confirmSignUp(this.state.email, this.state.confirmationCode);
    await Auth.signIn(this.state.email, this.state.password);

    this.props.userHasAuthenticated(true);
    this.props.nav("/");
  } catch (e) {
    alert(e.message);
    this.setState({ isLoading: false });
  }
};
```

{%change%} 그리고 Amplify의 Auth를 헤더에 추가합니다.

```js
import { Auth } from "aws-amplify";
```

여기서의 흐름은 매우 간단합니다.

1. `handleSubmit`에서는 사용자를 등록하기 위한 호출을 처리합니다. 이렇게하면 새 사용자 객체가 만들어집니다.

2. 그 사용자 객체를 `newUser` 상태로 저장하십시오.

3. `handleConfirmationSubmit`에서 확인 코드를 사용하여 사용자를 확인합니다.

4. 이제 사용자가 확인되면 Cognito는 앱에 로그인 할 수있는 새로운 사용자로 추가됩니다.

5. 이메일과 비밀번호를 사용하여 로그인 페이지에서와 똑같은 방식으로 인증하십시오.

6. `userHasAuthenticated` 메소드를 사용하여 App state를 업데이트합니다.

7. 마지막으로 홈페이지로 리디렉션합니다.

이제 브라우저로 전환하여 위 순서대로 새로운 계정을 신청할 경우, 성공적으로 완료된 후에 홈페이지로 리디렉션되어야합니다.

![가입 후 홈페이지 이동하기 화면](/assets/redirect-home-after-signup.png)

가입 절차에 대한 핵심 내용을 짧게 정리했습니다. 그런데 만일 사용자가 확인 단계에서 페이지를 새로 고침하게되면 다시 돌아와 해당 계정을 확인할 수 없습니다. 그 대신 새로운 계정을 만들도록 강요할겁니다. 사실 가입 절차를 일부러 단순하게 유지하려했기 때문에 발생한 문제지만 이런 상황을 해결하는 방법에 대해 몇 가지 힌트를 정리합니다.

1. `handleSubmit` 메소드의 `catch` 블록에서 `UsernameExistsException`을 확인하십시오.

2. 사용자가 이전에 확인되지 않은 경우, Auth.resendSignUp() 메소드를 사용하여 코드를 다시 보냅니다. 다음은 [Amplify API docs](https://aws.github.io/aws-amplify/api/classes/authclass.html#resendsignup)에 대한 링크입니다.

3. 이전에 했던 것처럼 코드를 확인하십시오.

이 문제에 관해서 질문이 있다면 언제든지 의견을 주십시오.

이제 인증되지 않은 사용자를 수동으로 확인해야 하는 경우가 발생할 수 있습니다. 다음 명령을 사용하여 AWS CLI로이를 수행 할 수 있습니다.

```bash
aws cognito-idp admin-confirm-sign-up \
   --region YOUR_COGNITO_REGION \
   --user-pool-id YOUR_COGNITO_USER_POOL_ID \
   --username YOUR_USER_EMAIL
```

Cognito 사용자 풀 ID와 계정을 만드는 데 사용한 이메일을 사용하십시오.

사용자가 이메일 또는 암호를 변경할 수 있도록 허용하려면 [Extra Credit series of chapters on user management]({% link _chapters/manage-user-accounts-in-aws-amplify.md %}) 챔터를 참조하십시오.

다음으로 첫 번째 노트를 작성해 보겠습니다.
