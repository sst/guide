---
layout: post
title: Clear the Session on Logout
date: 2017-01-16 00:00:00
lang: ko
ref: clear-the-session-on-logout
description: 사용자가 로그아웃 할 때 React.js 앱에서 로그인 한 사용자의 Amazon Cognito 세션을 삭제해야합니다. AWS Amplify의 Auth.signOut() 메소드를 사용하여 이를 수행 할 수 있습니다. 
context: true
comments_id: clear-the-session-on-logout/70
---

현재 우리는 앱 세션 state에서만 사용자 세션을 제거하고 있습니다. 그러나 페이지를 새로 고침 할 때 브라우저의 로컬 저장소(Amplify가 사용하는)에서 사용자 세션을 불러와 다시 로그인합니다.

AWS Amplify에는 Auth.signOut() 메소드가 있습니다.

<img class="code-marker" src="/assets/s.png"/>`src/App.js`의 `handleLogout` 메쏘드를 다음과 같이 바꿉니다: 

``` javascript
handleLogout = async event => {
  await Auth.signOut();

  this.userHasAuthenticated(false);
}
```

이제 브라우저로 가서 로그아웃 한 다음, 페이지를 새로 고침하십시오. 완전히 로그아웃되어야합니다.

처음부터 전체 로그인 흐름을 시험해 보면 알 수 있겠지만 우리는 전체 프로세스를 통해 로그인 페이지에만 계속 머물러 있습니다. 다음으로, 우리는 페이지 리디렉션을 통해 로그인하고 로그아웃하는 흐름을 보다 명확하게 만들겠습니다.

