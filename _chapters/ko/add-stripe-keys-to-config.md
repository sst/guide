---
layout: post
title: Add Stripe Keys to Config
date: 2018-03-22 00:00:00
lang: ko
description: Create React App에서 Stripe React JS SDK를 사용할 것입니다. 이를 위해 React app config에 Stripe Publishable API 키를 저장하려고합니다. 
comments_id: add-stripe-keys-to-config/185
ref: add-stripe-keys-to-config
---

[Stripe 계정 설정]({% link _chapters/setup-a-stripe-account.md %}) 챕터에서 Stripe 콘솔에 두 개의 키가 있다고 했습니다. 백엔드에서 사용한 **비밀 키** 및 **Publishable 키** 말이죠. **Publishable 키**는 프론트 엔드에서 사용하기 위한 것입니다.

그때 Stripe 계정 설정은 완료되지 않았으므로 이 키의 운영 버전은 아직 없습니다. 지금은 동일한 키의 두 가지 버전이 있다고 가정합니다.

<img class="code-marker" src="/assets/s.png" />`src/config.js`의 `dev` 블럭에 다음 내용을 추가합니다.

```
STRIPE_KEY: "YOUR_STRIPE_DEV_PUBLIC_KEY",
```

<img class="code-marker" src="/assets/s.png" />`src/config.js`의 `prod` 블럭에 다음 내용을 추가합니다.

```
STRIPE_KEY: "YOUR_STRIPE_PROD_PUBLIC_KEY",
```

[Stripe 계정 설정]({% link _chapters/setup-a-stripe-account.md %}) 챕터에서 **Publishable 키**로 `YOUR_STRIPE_DEV_PUBLIC_KEY` 및 `YOUR_STRIPE_PROD_PUBLIC_KEY`를 대체해야합니다. 여기에서는 똑같습니다. Stripe 계정을 완전히 구성 할 때 `prod` 블럭에서 운영 버전을 사용해야합니다.

### 변경 사항 커밋 

<img class="code-marker" src="/assets/s.png" />Git에 빠르게 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding Stripe keys to config"
```

다음으로, 청구서 양식을 작성하겠습니다.
