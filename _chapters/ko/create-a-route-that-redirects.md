---
layout: post
title: Create a Route That Redirects
date: 2017-02-02 00:00:00
lang: ko 
redirect_from: /chapters/create-a-hoc-that-checks-auth.html
description: React.js 앱에서는 로그인하지 않은 사용자를 로그인 페이지로 리디렉션하고 로그인한 사용자는 로그인 페이지가 아닌 곳으로 리디렉션하려고합니다. 이렇게하려면 React Router v4의 Redirect 컴포넌트를 사용합니다. 
context: true
comments_id: create-a-route-that-redirects/47
ref: create-a-route-that-redirects
---

먼저 사용자가 라우팅하기 전에 로그인했는지 확인하는 경로를 만들어 보겠습니다.

<img class="code-marker" src="/assets/s.png" />`src/components/AuthenticatedRoute.js`에 다음을 추가합니다.

``` coffee
import React from "react";
import { Route, Redirect } from "react-router-dom";

export default ({ component: C, props: cProps, ...rest }) =>
  <Route
    {...rest}
    render={props =>
      cProps.isAuthenticated
        ? <C {...props} {...cProps} />
        : <Redirect
            to={`/login?redirect=${props.location.pathname}${props.location
              .search}`}
          />}
  />;
```

이 컴포넌트는 [세션을 상태에 추가하기] ({% link _chapters/add-the-session-to-the-state.md %}) 챕터에서 작성한`AppliedRoute` 컴포넌트와 유사합니다. 가장 큰 차이점은 사용자가 인증되었는지 확인하기 위해 전달된 속성을 살펴 보는 것입니다. 사용자가 인증되면 전달된 컴포넌트를 단순히 렌더링합니다. 그리고 사용자가 인증되지 않았으면 `Redirect` React Router v4 컴포넌트를 사용하여 사용자를 로그인 페이지로 리디렉션합니다. 또한 현재 로그인 경로를 전달합니다(쿼리 문자열의 `redirect`). 이것을 이용해 사용자가 로그인한 후에 바로 다시 리디렉션 할 것입니다.

사용자가 인증되지 않았음을 보장하기 위한 검증에서도 비슷한 방법을 사용할 것입니다.

<img class="code-marker" src="/assets/s.png" />`src/components/UnauthenticatedRoute.js`에 다음 내용을 추가합니다.

``` coffee
import React from "react";
import { Route, Redirect } from "react-router-dom";

export default ({ component: C, props: cProps, ...rest }) =>
  <Route
    {...rest}
    render={props =>
      !cProps.isAuthenticated
        ? <C {...props} {...cProps} />
        : <Redirect to="/" />}
  />;
```

여기에서는 전달된 컴포넌트를 렌더링하기 전에 사용자가 인증되지 않았는지 확인합니다. 그리고 사용자가 인증된 경우에는 `Redirect` 컴포넌트를 사용하여 사용자를 홈페이지로 보냅니다.

다음으로,  응용 프로그램에서 이 컴포넌트들을 사용해 보겠습니다.
