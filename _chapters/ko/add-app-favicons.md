---
layout: post
title: Add App Favicons
date: 2017-01-07 00:00:00
lang: ko 
ref: add-app-favicons
description: React.js 앱에 대한 앱 아이콘과 favicon을 생성하기 위해 Realfavicongenerator.net 서비스를 사용합니다. 이 서비스는 Create React App과 함께 제공되는 기본 favicon을 대체합니다. 
context: true
comments_id: add-app-favicons/155
---

Create React App은 앱에 대한 간단한 favicon을 생성하고`public/favicon.ico`에 저장할 수 있습니다. 그러나 모든 브라우저와 모바일 플랫폼에서 작동하도록 favicon을 가져 오려면 조금 더 많은 작업이 필요합니다. 몇 가지 요구 사항과 사이즈가 있는데, 이러한 내용은 앱의`public/` 디렉토리에 파일을 포함시키는 법을 배울 좋은 기회입니다.

예를 들어, 간단한 이미지로 시작하여 다양한 이미지를 생성 할 것입니다.

**다음 이미지를 다운로드하려면 마우스 오른쪽 버튼을 클릭하십시오**.

<img alt="App Icon" width="130" height="130" src="/assets/scratch-icon.png" />

대부분의 타겟 플랫폼에서 아이콘이 작동하도록하기 위해 [Favicon Generator](http://realfavicongenerator.net)라는 서비스를 사용합니다.

**Favicon 사진 선택**을 클릭하여 앞에서 다운로드한 아이콘을 업로드하십시오.

![Realfavicongenerator.net 화면](/assets/realfavicongenerator.png)

아이콘을 업로드하면 다양한 플랫폼에서 아이콘 미리보기가 표시됩니다. 페이지를 아래로 스크롤하고 **Favicon 및 HTML 코드 생성** 버튼을 클릭하십시오.

![Realfavicongenerator.net 화면](/assets/realfavicongenerator-generate.png)

이렇게하면 favicon 패키지와 함께 제공되는 코드가 생성됩니다.


{%change%} **Favicon 패키지**를 클릭하여 생성 된 favicon을 다운로드하십시오. 그리고 모든 파일을 `public/` 디렉토리에 복사하십시오.

![Realfavicongenerator.net 완성 화면](/assets/realfavicongenerator-completed.png)

{%change%} 그런 다음 `public/manifest.json`의 내용을 다음으로 대체하십시오:

``` json
{
  "short_name": "Scratch",
  "name": "Scratch Note Taking App",
  "icons": [
    {
      "src": "android-chrome-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "android-chrome-256x256.png",
      "sizes": "256x256",
      "type": "image/png"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#ffffff",
  "background_color": "#ffffff"
}
```

`public/` 디렉토리에있는 파일을 HTML에 포함 시키려면 React Create App에 `%PUBLIC_URL%` 접두사가 있어야합니다.

{%change%} 아래 내용을 `public/index.html`에 추가하십시오.

``` html
<link rel="apple-touch-icon" sizes="180x180" href="%PUBLIC_URL%/apple-touch-icon.png">
<link rel="icon" type="image/png" href="%PUBLIC_URL%/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="%PUBLIC_URL%/favicon-16x16.png" sizes="16x16">
<link rel="mask-icon" href="%PUBLIC_URL%/safari-pinned-tab.svg" color="#5bbad5">
<meta name="theme-color" content="#ffffff">
```

{%change%} 원래의 favicon 및 테마 색상을 참조하는 다음 줄을 **제거합니다**.

``` html
<meta name="theme-color" content="#000000">
<link rel="shortcut icon" href="%PUBLIC_URL%/favicon.ico">
```
마지막으로 브라우저로 가서 입력된 주소 뒤에 `/favicon-32x32.png`을 입력해서 파일이 올바르게 추가되었는지 확인하십시오.

다음으로 앱에서 맞춤 글꼴을 설정하는 방법을 살펴 보겠습니다.

