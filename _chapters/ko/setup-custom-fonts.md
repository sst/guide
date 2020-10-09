---
layout: post
title: Set up Custom Fonts
date: 2017-01-08 00:00:00
lang: ko 
ref: set-up-custom-fonts
description: React.js 프로젝트에서 맞춤 글꼴을 사용하려면 Google 글꼴을 사용하고 public/index.html에 포함 시키십시오. 
context: true
comments_id: set-up-custom-fonts/81
---

사용자 정의 글꼴은 이제 모던 웹 애플리케이션의 거의 표준적인 부분입니다. [Google 글꼴](https://fonts.google.com)를 사용하여 작성된 노트를 위해 앱을 설정하려고 합니다.

이 부분도 React.js 앱의 구조를 탐색할 좋은 기회입니다.

### Google 글꼴 추가하기 

우리 프로젝트에서는 Serif ([PT Serif](https://fonts.google.com/specimen/PT+Serif))와 Sans-Serif ([Open Sans](https://fonts.google.com/specimen/Open+Sans)) 서체를 조합해서 사용하려고 합니다. 이들은 모두 Google 글꼴을 통해 제공되며 Google 글꼴을 우리들의 서버에 저장하지 않고도 직접 사용할 수 있습니다.

먼저 HTML에 포함시켜 보겠습니다. 우리의 React.js 앱은 하나의 HTML 파일을 사용하고 있습니다.

{%change%} `public/index.html`을 편집하고, 이 두 서체를 추가하기 위해 HTML의 `<head>` 섹션에 다음 행을 추가하십시오.

``` html
<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=PT+Serif|Open+Sans:300,400,600,700,800">
```

여기서 우리는 Open Sans 서체의 5 가지 다른 가중치 (300, 400, 600, 700 및 800)를 모두 참조합니다.

### 스타일에 글꼴 추가하기

이제 새로 추가된 글꼴을 스타일 시트에 추가할 준비가되었습니다. Create React App은 개별 컴포넌트의 스타일을 분리하는 데 도움이되며 `src/index.css`에 위치한 프로젝트의 마스터 스타일 시트를 가지고 있습니다.

{%change%} `body` 태그에 대한 `src/index.css`의 현재 글꼴을 다음과 같이 변경합니다.

``` css
body {
  margin: 0;
  padding: 0;
  font-family: "Open Sans", sans-serif;
  font-size: 16px;
  color: #333;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

{%change%} 그리고 css 파일에 아래 블록을 추가하여 헤더 태그의 글꼴을 새로운 Serif 글꼴로 변경해 봅시다.

``` css
h1, h2, h3, h4, h5, h6 {
  font-family: "PT Serif", serif;
}
```

이제 새롭게 반영된 앱을 보기 위해 브라우저로 넘어가면, 새 글꼴이 자동으로 업데이트됩니다. 라이브 리로딩 덕분입니다.

![맞춤 글꼴 업데이트 된 스크린 샷](/assets/custom-fonts-updated.png)

앞으로 앱을 빌드하는 동안 스타일을 추가하고 Bootstrap을 사용하도록 프로젝트를 설정하여 일관된 UI Kit을 사용할 예정입니다.

