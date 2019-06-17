---
layout: post
title: Use the Redirect Routes
date: 2017-02-03 00:00:00
lang: ko 
redirect_from: /chapters/use-the-hoc-in-the-routes.html
description: React.js 앱에서 우리는 보안이 필요한 경로 대신 AuthenticatedRoute 및 UnauthenticatedRoute를 사용할 수 있습니다. React Router v4의 스위치 컴포넌트에서 이 작업을 수행 할 것입니다.
context: true
comments_id: use-the-redirect-routes/152
ref: use-the-redirect-routes
---

지난 챕터에서`AuthenticatedRoute` 와 `UnauthenticatedRoute`을 만들었으니, 우리가 원하는 컨테이너에서 사용하도록합시다.

<img class="code-marker" src="/assets/s.png" />먼저 `src/Routes.js`의 헤더에 앞서 만든 컴포넌트를 import합니다.

``` javascript
import AuthenticatedRoute from "./components/AuthenticatedRoute";
import UnauthenticatedRoute from "./components/UnauthenticatedRoute";
```

다음으로 새로운 리디렉션 경로로 전환하면됩니다.

그래서 `src/Routes.js`의 다음 경로들이 영향을 받습니다.

``` coffee
<AppliedRoute path="/login" exact component={Login} props={childProps} />
<AppliedRoute path="/signup" exact component={Signup} props={childProps} />
<AppliedRoute path="/notes/new" exact component={NewNote} props={childProps} />
<AppliedRoute path="/notes/:id" exact component={Notes} props={childProps} />
```

<img class="code-marker" src="/assets/s.png" />위 컴포넌트들 대신 다음과 같이 바뀌어야 합니다:

``` coffee
<UnauthenticatedRoute path="/login" exact component={Login} props={childProps} />
<UnauthenticatedRoute path="/signup" exact component={Signup} props={childProps} />
<AuthenticatedRoute path="/notes/new" exact component={NewNote} props={childProps} />
<AuthenticatedRoute path="/notes/:id" exact component={Notes} props={childProps} />
```

로그인하지 않은 상태에서 노트 페이지를 로드하려고 하면 노트 페이지를 참조하여 로그인 페이지로 리디렉션됩니다.

![로그인 스크린 샷으로 리디렉션 된 노트 페이지](/assets/note-page-redirected-to-login.png)

다음으로, 우리는 로그인 후 바로 노트 페이지로 리디렉션하는 참조를 사용해 보겠습니다.

