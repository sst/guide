---
layout: post
title: API එකක් සෑදීම සඳහා
date: 2017-01-23 00:00:00
lang: si
ref: call-the-create-api
description: අපගේ පරිශීලකයින්ට අපගේ React.js යෙදුමේ සටහනක් සෑදීමට ඉඩ දීම සඳහා, අපි අපගේ පෝරමය serverless API backend සමඟ සම්බන්ධ කළ යුතුයි. මේ සඳහා අපි භාවිතා කිරීමට යන්නේ AWS Amplify's API මොඩියුලය.
comments_id: call-the-create-api/124
---

දැන් අපේ මූලික නිර්‍මාණ සටහන් පත්‍රය ක්‍රියාත්මක වන බැවින් එය අපේ API වෙත සම්බන්ධ කරමු. අපි ටික වේලාවකට පසු S3 වෙත උඩුගත කරමු. AWS IAM භාවිතා කර අපේ APIs ආරක්‍ෂා කර ඇති අතර අපගේ සත්‍යාපන සපයන්නා වන්නේ Cognito User Pool. ස්තූතිවන්ත වන්නට, ලොග් වී ඇති පරිශීලක සැසිය භාවිතා කිරීමෙන් Amplify අප වෙනුවෙන් මෙය රැකබලා ගනී.

{%change%} පහත දැක්වෙන දේ `src/containers/NewNote.js` හි header ට එකතු කිරීමෙන් `API` මොඩියුලය ඇතුළත් කරමු.

``` javascript
import { API } from "aws-amplify";
```

{%change%} තවද අපගේ `handleSubmit` function ය පහත සඳහන් දෑ සමඟ ප්‍රතිස්ථාපනය කරන්න.

``` javascript
async function handleSubmit(event) {
  event.preventDefault();

  if (file.current && file.current.size > config.MAX_ATTACHMENT_SIZE) {
    alert(
      `Please pick a file smaller than ${config.MAX_ATTACHMENT_SIZE /
        1000000} MB.`
    );
    return;
  }

  setIsLoading(true);

  try {
    await createNote({ content });
    history.push("/");
  } catch (e) {
    onError(e);
    setIsLoading(false);
  }
}

function createNote(note) {
  return API.post("notes", "/notes", {
    body: note
  });
}
```

This does a couple of simple things.

1. We make our create call in `createNote` by making a POST request to `/notes` and passing in our note object. Notice that the first two arguments to the `API.post()` method are `notes` and `/notes`. This is because back in the [Configure AWS Amplify]({% link _chapters/configure-aws-amplify.md %}) chapter we called these set of APIs by the name `notes`.

2. For now the note object is simply the content of the note. We are creating these notes without an attachment for now.

3. Finally, after the note is created we redirect to our homepage.

And that's it; if you switch over to your browser and try submitting your form, it should successfully navigate over to our homepage.

![New note created screenshot](/assets/new-note-created.png)

Next let's upload our file to S3 and add an attachment to our note.
