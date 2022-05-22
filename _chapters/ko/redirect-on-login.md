---
layout: post
title: Redirect on Login
date: 2017-02-04 00:00:00
lang: ko
description: React.js가 로그인 한 후 사용자를 올바른 페이지로 리디렉션하도록하려면 React Router v6 Redirect 컴포넌트를 사용합니다.
context: true
comments_id: redirect-on-login/24
ref: redirect-on-login
---

사용자 인증이 필요한 페이지는 사용자가 로그인하지 않았을 때 로그인 페이지로 리디렉션하고 원래 페이지로의 참조를 보냅니다. 로그인한 후 다시 리디렉션하려면 몇 가지 작업을 수행해야합니다. 현재 `Login` 컴포넌트는 사용자가 로그인한 후에 리디렉션을 합니다. 우리는 이것을 새로 생성된 `UnauthenticatedRoute` 컴포넌트로 옮길 것입니다.

URL의 쿼리 문자열에서 `redirect`를 읽는 메소드를 추가해 보겠습니다.

{%change%} `src/components/UnauthenticatedRoute.js`의 import 구문 밑에 다음 메소드를 추가합니다.

```coffee
function querystring(name, url = window.location.href) {
  name = name.replace(/[[]]/g, "\\$&");

  const regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)", "i");
  const results = regex.exec(url);

  if (!results) {
    return null;
  }
  if (!results[2]) {
    return "";
  }

  return decodeURIComponent(results[2].replace(/\+/g, " "));
}
```

이 메소드는 읽으려는 쿼리 문자열의 파라미터를 가져 와서 반환합니다.

이제 리디렉션 할 때이 매개 변수를 사용하도록 컴포넌트를 업데이트 해 보겠습니다.

{%change%} 현재 `export default ({ component: C, props: cProps, ...rest }) =>` 메소드를 아래와 같이 수정합니다.

```coffee
export default ({ component: C, props: cProps, ...rest }) => {
  const redirect = querystring("redirect");
  return (
    <Route
      {...rest}
      render={props =>
        !cProps.isAuthenticated
          ? <C {...props} {...cProps} />
          : <Navigate
              to={redirect === "" || redirect === null ? "/" : redirect}
            />}
    />
  );
};
```

{%change%} `src/containers/Login.js`의 `handleSubmit` 메소드에서 다음을 삭제합니다. .

```coffee
this.props.nav("/");
```

이제 로그인 페이지가 리디렉션되어야합니다.

이제 모두 완성되었습니다. 우리의 앱은 곧바로 사용할 준비가 되었습니다. Severless 설정을 사용하여 어떻게 배포 할 것인지 살펴 보겠습니다.
