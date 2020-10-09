---
layout: post
title: Delete a Note
date: 2017-01-31 00:00:00
lang: ko 
description: 사용자가 React.js 앱에서 노트를 삭제할 수 있습니다. 이를 위해 AWS Amplify를 사용하여 serverless 백앤드 API에 DELETE 요청을 할 것입니다. 
context: true
comments_id: comments-for-delete-a-note/137
ref: delete-a-note
---

노트 페이지에서 마지막으로 해야할 일은 사용자가 노트를 삭제할 수 있게하는 것입니다. 버튼은 이미 설정되어 있습니다. API에 연결해서 마무리할 일만 남았습니다.

{%change%}  `src/containers/Notes.js`에서 `handleDelete` 메소드를 대체합니다.

``` coffee
deleteNote() {
  return API.del("notes", `/notes/${this.props.match.params.id}`);
}

handleDelete = async event => {
  event.preventDefault();

  const confirmed = window.confirm(
    "Are you sure you want to delete this note?"
  );

  if (!confirmed) {
    return;
  }

  this.setState({ isDeleting: true });

  try {
    await this.deleteNote();
    this.props.history.push("/");
  } catch (e) {
    alert(e);
    this.setState({ isDeleting: false });
  }
}
```

`this.props.match.params.id`에서 `id`를 얻어 `/notes/:id`에 단순히`DELETE` 요청을 하겠습니다. AWS Amplify의 `API.del` 메소드를 사용합니다. 이 API는 delete API를 호출하고 성공하면 홈페이지로 리디렉션됩니다.

이제 브라우저로 전환 한 다음 노트를 삭제한 후, 확인 버튼을 누르면 삭제가 된 것을 확인할 수 있습니다.

![노트 페이지 삭제하기 화면](/assets/note-page-deleting.png)

다시 말씀드리지만 노트를 삭제할 때 첨부 파일을 삭제하지는 않을 것입니다. 역시 모든 것을 단순하게 유지하기 위해 여러분에게 맡기겠습니다. S3에서 파일을 삭제하는 방법은 [AWS Amplify API Docs](https://aws.github.io/aws-amplify/api/classes/storageclass.html#remove)에서 확인하십시오.

앱이 거의 완료되어 갑니다. 이제 로그인이 필요한 몇 개의 앱 페이지에 대해 인증을 요청하는 방법을 살펴 보겠습니다. 현재 로그 아웃 상태에서 노트 페이지를 방문하면 별로 예쁘지 않은 오류가 발생합니다.

![로그 아웃 상태에서 노트 페이지 에러 화면](/assets/note-page-logged-out-error.png)

대신에, 로그인 페이지로 리디렉션 한 다음 로그인 한 후에 다시 요청한 페이지로 리디렉션하고 싶습니다. 다음에 그 방법을 살펴 보겠습니다. 
