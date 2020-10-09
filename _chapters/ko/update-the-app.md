---
layout: post
title: Update the App
date: 2017-02-13 00:00:00
lang: ko 
description: React.js 단일 페이지 응용 프로그램을 변경하는 방법에 대한 자습서.
comments_id: comments-for-update-the-app/43
ref: update-the-app
---

앱의 업데이트를 배포하는 프로세스를 테스트하기 위해 몇 가지 빠른 변경을 수행해 보겠습니다.

우리는 첫 페이지에 로그인 및 가입 버튼을 추가하여 사용자에게 명확한 가이드를 제공할 것입니다.

{%change%} `src/containers/Home.js`의 `renderLander` 메소드를 다음과 같이 변경합니다.

``` coffee
renderLander() {
  return (
    <div className="lander">
      <h1>Scratch</h1>
      <p>A simple note taking app</p>
      <div>
        <Link to="/login" className="btn btn-info btn-lg">
          Login
        </Link>
        <Link to="/signup" className="btn btn-success btn-lg">
          Signup
        </Link>
      </div>
    </div>
  );
}
```

{%change%} 그리고 React-Router 헤더에서 `Link` 컴포넌트를 import합니다.

``` javascript
import { Link } from "react-router-dom";
```

{%change%} 또한 `src/containers/Home.css`에 몇 가지 스타일을 추가합니다.

``` css
.Home .lander div {
  padding-top: 20px;
}
.Home .lander div a:first-child {
  margin-right: 20px;
}
```

그럼 첫 페이지가 다음과 같이 보여야합니다.

![앱 첫페이지 업데이트 화면](/assets/app-updated-lander.png)

다음으로 변경 사항을 배포해보겠습니다.
