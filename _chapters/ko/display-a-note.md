---
layout: post
title: Display a Note
date: 2017-01-28 00:00:00
lang: ko 
ref: display-a-note
description: React.js 앱에 URL의 ID를 기반으로 사용자 노트를 표시하는 페이지를 만들고 싶습니다. React Router v4 Route 구성 요소의 URL 매개 변수를 사용하여 ID를 가져옵니다. 이 ID를 사용하여 serverless 백엔드 API에서 노트를 요청할 것입니다. AWS Amplify의 Storage.vault.get() 메소드를 사용하여 첨부 파일을 다운로드하는 보안 링크를 얻을 수 있습니다. 
context: true
comments_id: display-a-note/112
ref: display-a-note
---

이제 노트의 목록을 만들었으므로 노트를 선택하고 사용자가 편집할 수 있도록 페이지를 만듭니다.

우리가 해야할 첫 번째 일은 컨테이너가 로드 될 때 노트를 불러오는 것입니다. 우리가 'Home' 컨테이너에서 했던 것과 마찬가지 방법으로 시작해 보겠습니다.

### 경로 추가하기 

노트 불러오기 화면의 경로를 추가 합니다.

<img class="code-marker" src="/assets/s.png" />`src/Routes.js` 파일의 `/notes/new` 경로 아래에 다음 행을 추가하십시오. 우리는 [세션을 상태에 추가하기]({% link _chapters/add-the-session-to-the-state.md %}) 챕터에서 작성한 `AppliedRoute` 컴포넌트를 사용하고 있습니다.

``` coffee
<AppliedRoute path="/notes/:id" exact component={Notes} props={childProps} />
```

URL에서 노트 ID를 추출하기 위해 패턴 매칭을 이용하는 부분으로 매우 중요합니다.

루트 경로 `/notes/:id`를 사용함으로써 우리는 라우터에게 해당되는 경로에 컴포넌트인 `Notes`를 설정합니다. 하지만 이것은 `/notes/new` 경로의 `new`의 `id`와 매칭 시킨 결과도 가져올 수 있습니다. 따라서 이를 방지하기 위해 `/notes/new` 경로의 뒤에 놓입니다.

<img class="code-marker" src="/assets/s.png" />그리고 헤더에 컴포넌트를 추가합니다.

``` javascript
import Notes from "./containers/Notes";
```

물론 아직 해당 컴포넌트는 없지만 이제 만들어 보겠습니다.

### 컨테이너 추가하기

<img class="code-marker" src="/assets/s.png" />`src/containers/Notes.js` 파일을 만들고 아래 내용을 추가합니다.

``` coffee
import React, { Component } from "react";
import { API, Storage } from "aws-amplify";

export default class Notes extends Component {
  constructor(props) {
    super(props);

    this.file = null;

    this.state = {
      note: null,
      content: "",
      attachmentURL: null
    };
  }

  async componentDidMount() {
    try {
      let attachmentURL;
      const note = await this.getNote();
      const { content, attachment } = note;

      if (attachment) {
        attachmentURL = await Storage.vault.get(attachment);
      }

      this.setState({
        note,
        content,
        attachmentURL
      });
    } catch (e) {
      alert(e);
    }
  }

  getNote() {
    return API.get("notes", `/notes/${this.props.match.params.id}`);
  }

  render() {
    return <div className="Notes"></div>;
  }
}
```

여기서는 두 가지 작업을 처리하고 있습니다.

1. `componentDidMount`에 노트를 로드하고 state에 저장합니다. 그리고 `this.props.match.params.id`에서 React-Router에 의해 자동으로 전달 된 속성을 사용하여 URL에서 노트의 `id`를 얻습니다. 키워드 `id`는 우리 경로(`/notes/:id`)에서 사용하는 패턴 매칭의 일부입니다.

2. 첨부 파일이 있는 경우 키를 사용하여 S3에 업로드 한 파일에 대한 암호화된 링크를 가져옵니다. 이것을 컴포넌트의 state인 `attachmentURL`에 저장합니다.

3. `content` 와 `attachmentURL`과 함께 state에 `note` 객체를 갖는 이유는 나중에 사용자가 메모를 편집 할 때 이를 사용할 것이기 때문입니다.

이제 브라우저로 전환하여 이전에 작성한 노트로 이동하면 페이지에서 빈 컨테이너가 렌더링됩니다.

![빈 노트 페이지 로딩 스크린샷](/assets/empty-notes-page-loaded.png)

다음으로, 방금 로드한 노트를 렌더링 하겠습니다.
