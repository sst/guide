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

මෙය සරල කරුණු කිහිපයක් කරයි.

1. `/notes` වෙත POST request කිරීමෙන් සහ අපගේ note object පාස් වීමෙන් අපි 'createNote' හි අපගේ create call ලබා දෙන්නෙමු. `API.post()` method සඳහා වන පළමු arguments දෙක `notes` සහ`/notes` බව සලකන්න. එයට හේතුව නම් [Configure AWS Amplify]({% link _chapters/configure-aws-amplify.md %}) පරිච්ඡේදයේ අපි මෙම API කට්ටලය `notes` නමින් හැඳින්වූ බැවිනි.

2. මේ වන විට note object සරලව note අන්තර්ගතයයි. අපි දැනට මෙම note නිර්මාණය කරන්නේ ඇමුණුමකින් තොරවය.

3. අවසාන වශයෙන්, note සෑදීමෙන් පසු අපි අපේ homepage හරවා යවමු.

එපමණයි; ඔබ ඔබේ බ්‍රව්සරය වෙත මාරු වී ඔබේ පෝරමය ඉදිරිපත් කිරීමට උත්සාහ කරන්නේ නම්, එය අපේ homepage සාර්ථකව යා යුතුය.

![New note created screenshot](/assets/new-note-created.png)

ඊළඟට අපි අපේ ගොනුව S3 වෙත උඩුගත කර අපේ note ට ඇමුණුමක් එකතු කරමු.
