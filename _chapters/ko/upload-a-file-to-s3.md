---
layout: post
title: Upload a File to S3
date: 2017-01-24 00:00:00
lang: ko
ref: upload-a-file-to-s3
description: 사용자가 React.js 앱에 파일을 업로드하고 노트에 첨부 파일을 추가하려고 합니다. React.js 앱에서 직접 S3에 파일을 업로드하려면 AWS Amplify의 Storage.put() 메소드를 사용하십시오.
context: true
comments_id: comments-for-upload-a-file-to-s3/123
---

이제 메모에 첨부 파일을 추가해 보겠습니다. 우리가 사용하는 절차는 매우 간단합니다.

1. 사용자가 업로드 할 파일을 선택합니다.
2. 파일이 s3의 사용자 폴더에 업로드되고 키가 반환됩니다.
3. 파일 키가 첨부된 노트를 작성하십시오.

AWS Amplify의 스토리지 모듈을 사용할 예정입니다. [Cognito 자격증명 풀 만들기]({% link _chapters/create-a-cognito-identity-pool.md %}) 챕터를 보면 로그인 한 사용자는 S3 버킷에 있는 폴더에 액세스할 수 있습니다 . AWS Amplify는 파일을 _본인만 볼 수 있도록_ 저장하려면 이 폴더에 직접 저장합니다.

그리고 노트를 새로 작성해서 저장하거나 기존 노트를 편집해서 저장할 경우에만 파일이 업로드됩니다. 따라서 이를 위해 쉽고 편리한 방법을 만들어 보겠습니다.

### S3에 업로드하기

{%change%} 이를 위해 `src/libs/` 디렉토리를 만듭니다.

```bash
$ mkdir src/libs/
```

{%change%} `src/libs/awsLib.js` 파일을 만들고 아래 내용을 작성합니다.

```coffee
import { Storage } from "aws-amplify";

export async function s3Upload(file) {
  const filename = `${Date.now()}-${file.name}`;

  const stored = await Storage.vault.put(filename, file, {
    contentType: file.type
  });

  return stored.key;
}
```

위의 내용은 아래와 같은 몇 가지 작업을 수행합니다.

1. 파일 오브젝트를 매개 변수로 취합니다.

2. 현재 시각(`Date.now()`)을 사용하여 고유한 파일 이름을 생성합니다. 물론 앱을 많이 사용하는 경우, 사실 고유한 파일 이름을 만드는 가장 좋은 방법은 아닙니다. 하지만 여기서는 괜찮을 것 같습니다.

3. `Storage.vault.put()` 객체를 사용하여 S3의 사용자 폴더에 파일을 업로드하십시오. 또는 공개적으로 업로드하는 경우 `Storage.put()` 메소드를 사용할 수 있습니다.

4. 저장된 객체의 키를 반환합니다.

### 노트를 생성하기 전에 업로드하기

업로드 메소드가 준비되었으므로 노트 작성 메소드에서 호출해 보겠습니다.

{%change%} `src/containers/NewNote.js` 파일에서 `handleSubmit` 메소드를 다음 내용으로 바꿉니다.

```js
handleSubmit = async (event) => {
  event.preventDefault();

  if (this.file && this.file.size > config.MAX_ATTACHMENT_SIZE) {
    alert(
      `Please pick a file smaller than ${
        config.MAX_ATTACHMENT_SIZE / 1000000
      } MB.`
    );
    return;
  }

  this.setState({ isLoading: true });

  try {
    const attachment = this.file ? await s3Upload(this.file) : null;

    await this.createNote({
      attachment,
      content: this.state.content,
    });
    this.props.nav("/");
  } catch (e) {
    alert(e);
    this.setState({ isLoading: false });
  }
};
```

{%change%} 그리고 `src/containers/NewNote.js` 헤더에 다음과 같이 `s3Upload`를 추가합니다.

```js
import { s3Upload } from "../libs/awsLib";
```

`handleSubmit`에서 우리가 수정한 내용은 다음과 같습니다 :

1. `s3Upload` 메소드를 사용하여 파일을 업로드합니다.

2. 반환된 키를 사용하여 노트를 만들때 노트 개체에 추가합니다.

이제 브라우저로 전환하고 업로드된 파일로 양식을 제출하면 노트가 성공적으로 만들어졌는지 확인합니다. 그리고 앱이 홈페이지로 리디렉션됩니다.

다음으로 우리는 사용자가 작성한 노트 목록을 볼 수 있도록 합니다.
