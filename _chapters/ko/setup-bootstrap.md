---
layout: post
title: Set up Bootstrap
date: 2017-01-09 00:00:00
lang: ko 
ref: set-up-bootstrap
description: 부트스트랩은 일관된 반응형 웹 응용 프로그램을 쉽게 만들 수 있도록 도와주는 UI 프레임워크입니다. React-Bootstrap 라이브러리를 사용하여 React.js 프로젝트에서 Bootstrap을 사용할 것입니다. React-Bootstrap을 사용하면 표준 React 구성 요소의 형태로 부트스트랩을 사용할 수 있습니다. 
context: true
comments_id: set-up-bootstrap/118
---

웹 응용 프로그램을 작성하는 경우, 응용 프로그램의 인터페이스를 만드는데 도움이되는 UI Kit가 있습니다. 우리의 노트 작성 앱에 [부트 스트랩](http://getbootstrap.com)을 사용하려고 합니다. 부트스트랩은 React와 함께 직접 사용할 수도 있지만 가장 좋은 방법은 [React-Bootstrap](https://react-bootstrap.github.io) 패키지와 함께 사용하는 것입니다. 이럴 경우 마크업을 훨씬 쉽게 구현하고 이해할 수 있습니다.

### React Bootstrap 설치하기

{%change%} 작업 디렉토리에서 다음 명령을 실행하십시오.

``` bash
$ npm install react-bootstrap@0.32.4 --save
```

이렇게하면 NPM 패키지가 설치되고 `package.json`에 의존성이 추가됩니다.

### 부트스트랩 스타일 추가하기

{%change%} React Bootstrap은 표준 부트스트랩 v3 스타일을 사용합니다. 그래서 `public/index.html`에 다음 스타일을 추가하십시오.

``` html
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
```

또한 양식 필드의 스타일을 조정하여 모바일 브라우저가 포커스를 확대하지 않도록합니다. 확대/축소를 방지하려면 글꼴 크기를 최소 `16px`로 지정하면됩니다.

{%change%} 그러기 위해 `src/index.css`에 아래 내용을 추가합니다.

``` css
select.form-control,
textarea.form-control,
input.form-control {
  font-size: 16px;
}
input[type=file] {
  width: 100%;
}
```

모바일상의 페이지가 넘치거나 스크롤바가 생성되지 않도록 파일 유형 입력필드의 너비도 설정합니다.

이제 브라우저를 보면 스타일이 조금씩 바뀌었음을 알 수 있습니다. 이것은 부트스트랩이 [Normalize.css](http://necolas.github.io/normalize.css/)를 포함하여 브라우저에서 일관된 스타일을 유지하기 때문입니다.

다음으로 애플리케이션을 위한 몇 개의 Route를 만들고 React Router를 설정하겠습니다.
