---
layout: post
title: Handle 404s
date: 2017-01-12 00:00:00
lang: ko
ref: handle-404s
description: React.js 앱에서 React Router v6를 사용하여 404를 처리하려면 Switch 블록 하단에 모든 경로에 대한 감지 설정을 해야합니다. 모든 경로 감지에는 경로 속성 없이 모든 경로에 응답합니다.
context: true
comments_id: handle-404s/75
---

지금까지 기본 경로를 처리하는 방법을 알아봤습니다. 이제 React Router로 404를 처리하는 방법을 살펴 보겠습니다.

### 컴포넌트 만들기

404를 처리하는 컴포넌트를 만드는 것으로 시작하겠습니다.

{%change%} `src/containers/NotFound.js` 이름으로 새로운 컴포넌트를 만듭니다. 그리고 다음 내용을 추가합니다.

```coffee
import React from "react";
import "./NotFound.css";

export default () =>
  <div className="NotFound">
    <h3>Sorry, page not found!</h3>
  </div>;
```

이 컴포넌트는 간단한 메시지를 출력합니다.

{%change%} `src/containers/NotFound.css`에 몇 가지 스타일을 추가합니다.

```css
.NotFound {
  padding-top: 100px;
  text-align: center;
}
```

### 모든 경로에 대한 감지 추가하기

이제 모든 경로에서 404 처리를 위해 위 컴포넌트를 추가합니다.

{%change%} `src/Routes.js`에서 `<Switch>` 블록을 찾아 해당 블록 마지막 줄에 다음 내용을 추가합니다.

```coffee
{ /* 최종적으로 일치하지 않는 모든 경로를 감지합니다. */ }
<Route component={NotFound} />
```

항상 `<Route>` 블록의 마지막 줄에 위치해야합니다. 그래야 다른 경로들에 대한 요청 실패 전에 이를 처리하는 경로라고 생각할 수 있습니다.

{%change%} 그리고 `NotFound` 컴포넌트를 import하기 위해 헤더 부분에 다음 내용을 추가합니다:

```js
import NotFound from "./containers/NotFound";
```

완성됐습니다! 이제 브라우저로 전환하여 탐색기의 로그인 또는 가입 버튼을 클릭하면 404 메시지가 표시됩니다.

![라우터 404 페이지 화면](/assets/router-404-page.png)

다음으로 백엔드 자원에 대한 정보를 가지고 앱 구성을 살펴 보겠습니다.
