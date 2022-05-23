---
layout: post
title: Call the Create API
date: 2017-01-23 00:00:00
lang: ko
ref: call-the-create-api
description: 사용자가 React.js 앱에서 노트를 만들려면 양식을 Serverless의 백앤드 API에 연결해야합니다.이를 위해 AWS Amplify의 API 모듈을 사용합니다.
context: true
comments_id: call-the-create-api/124
---

이제 기본적인 작성 노트 양식을 사용할 수 있으니 API에 연결해 보겠습니다. 잠시 후에 S3에 업로드를 수행 할 것입니다. 사용할 API는 AWS IAM을 사용하여 보안 설정되며 Cognito User Pool은 인증 공급자입니다. 고맙게도 Amplify는 로그인 한 사용자의 세션을 사용하여 이 문제를 처리합니다.

AWS Amplify가 가지고있는`API` 모듈을 사용할 필요가 있습니다.

{%change%} `src/containers/NewNote.js` 헤더에 다음을 추가하여 API 모듈을 포함 시키십시오.

```js
import { API } from "aws-amplify";
```

{%change%} 그리고 `handleSubmit` 함수를 아래와 같이 바꾸십시오.

```js
handleSubmit = async event => {
  event.preventDefault();

  if (this.file && this.file.size > config.MAX_ATTACHMENT_SIZE) {
    alert(`Please pick a file smaller than ${config.MAX_ATTACHMENT_SIZE/1000000} MB.`);
    return;
  }

  this.setState({ isLoading: true });

  try {
    await this.createNote({
      content: this.state.content
    });
    this.props.nav("/");
  } catch (e) {
    alert(e);
    this.setState({ isLoading: false });
  }
}

createNote(note) {
  return API.post("notes", "/notes", {
    body: note
  });
}
```

위 내용은 몇 가지 간단한 일을 처리합니다.

1. `/notes`에 POST 요청을 하면서 노트 객체를 전달함으로써 `createNote`를 호출을 합니다. `API.post()` 메쏘드의 처음 두 인자는`notes` 와 `/notes`입니다. 이것은 [AWS Amplify 설정하기]({% link _chapters/configure-aws-amplify.md %}) 챕터에서 우리가 `notes`라는 이름으로 API 세트를 호출했기 때문입니다.

2. 현재 노트 오브젝트는 단순한 노트의 내용뿐입니다. 일단 첨부 파일없이 노트를 작성하겠습니다.

3. 마지막으로 노트를 작성한 후에는 홈페이지로 리디렉션됩니다.(로그아웃 상태에서는 에러가 발생)

이제 브라우저로 전환하여 작성된 양식을 전송하면 홈페이지로 성공적으로 이동해야합니다.

![새 노트 작성 스크린 샷](/assets/new-note-created.png)

다음으로 파일을 S3에 업로드하고 첨부 파일을 노트에 추가해 봅시다.
