---
layout: post
title: Deploy the APIs
date: 2017-01-05 00:00:00
description: Tutorial on how to deploy your entire Serverless project or a single function to AWS Lambda and API Gateway.
code: backend_full
comments_id: 28
---

Now that our APIs are complete, let's deploy them.

### Deploy

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Run the following in your working directory.

``` bash
$ serverless deploy
```

Near the bottom of the output for this command, you will find the `Service Information`. This has a list of the endpoints of the APIs that were created. Make a note of these endpoints as we are going to use them later while creating our frontend. We are also going to quickly test these endpoints next.

``` bash
Service Information
service: notes-app-api
stage: prod
region: us-east-1
api keys:
  None
endpoints:
  POST - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes
  GET - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  GET - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes
  PUT - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  DELETE - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
functions:
  notes-app-api-prod-create
  notes-app-api-prod-get
  notes-app-api-prod-list
  notes-app-api-prod-update
  notes-app-api-prod-delete
```

<!--
### Deploy a Single Function

There are going to be cases where you might want to deploy just a single API as opposed to all of them. The `serverless deploy function` command deploys an individual function without going through the entire deployment cycle. This is a much faster way of deploying the changes we make.

For example, to deploy the list function again, we can run the following.

``` bash
$ serverless deploy function -f list
```
-->

### Test

Now let's test the API we just deployed. Because the API is authenticated via the Cognito User Pool, we need to obtain an identity token to include in the API request Authorization header.

First let's generate the identity token. Replace **YOUR_COGNITO_USER_POOL_ID** and **YOUR_COGNITO_APP_CLIENT_ID** with the values from the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter. Also use the username and password of the user created in the [Create a Cognito test user]({% link _chapters/create-a-cognito-test-user.md %}) chapter.

And run the following.

``` bash
aws cognito-idp admin-initiate-auth \
  --region us-east-1 \
  --user-pool-id YOUR_COGNITO_USER_POOL_ID \
  --client-id YOUR_COGNITO_APP_CLIENT_ID \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME=admin@example.com,PASSWORD=Passw0rd!
```

The identity token can be found in the `IdToken` field of the response.

``` json
{
    "AuthenticationResult": {
        "ExpiresIn": 3600, 
        "IdToken": "eyJraWQiOiIxeVVnNXQ3NWY3YzlzYlpnNURZZWFDVWhGMVhEOEdUUEpNXC9zQVhDZEhFbz0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI3MDM4MDg1Mi1iZGNiLTQ5NzAtOTU2Zi1kZTZkMGFjODBjODUiLCJhdWQiOiIxMnNyNTBwZzF1ZjAwNDRhajYzZTRoc2g2aSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE0ODc1NDUzNzUsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX1dkSEVHQWk4TyIsImNvZ25pdG86dXNlcm5hbWUiOiJmcmFuayIsImV4cCI6MTQ4NzU0ODk3NSwiaWF0IjoxNDg3NTQ1Mzc1LCJlbWFpbCI6IndhbmdmYW5qaWVAZ21haWwuY29tIn0.d7HRBs2QegvQsGwQhJfpJBWYdh9N6CwoQFhmC91ugJ0YFxVdRhHUFQl4uoLplrOJO90PjTrjmxR7az17MfRlfu8v-ij3s31oaQqz8IdWECuhWW63xCNfGMN8lAbnUBwlHISer9CIGmdf8iF-xar2uyHeH8WHhIjI3gbJw15ORCC6Fo43CuKJ6k2zWaOywMkNr7oT2U7Etk93b2pDwIgeZ4V6uGbHgv3IRJYXYvMdIqsemoF8tLpx3XD58Iq8hNJlw_gOpOp8dlpDA3AK9-vjyXYDjJ_0zZa6alf6j0XEgwCVm08IIcYhF8ntg7ju0ZVBbQwYrdgzBCBhxtfzz1elVg", 
        "RefreshToken": "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.LHH4qcesrzfF5mRi3wuykgn_1Kw-rwYjiaP459Lcingf86LkYX-zL9ZZ-jKMFELbyjnXr83P7VDdNIlZCMIFOX4djp4rVU22N3tu02-xunaACSaS6oa_5j-UTcH_2dTFN5yWYkk8VyG5UQUvDYRsmblrTrLshuG9gGhwkQRVYqTP631Zt3N5TqE-YseC211_JcEcGtN_UTxq4Rjc_b2Hh7lQVZrPIKX-7ZTfcQB1QrCTseNRI2aXl6DZFqdBGSRsfpZG4lVyjCWGELT23MreX5kp8rbRhIJzPJMGSD41GdvRjzD24fOqWAp4hg1lYsJKvN1NmCjPUfsrQOohZooOiQ.FXMEC5WtcKW1Sa2h.gfvDrbzFhUboXLhKnqjIBmoTb3YkqdRc8VJuCRsNTMXGr_R5_IgTlwagesd_2ARA50DibEEX5HdfOy8sugE0QnLiGc-DLhSPmvlgTKUiz8Dbm158vBZpK8-Ps5iSp7wiZvkZvW0GzhR8v3Toyp6I_gapDlIqV3RTj34AXTbX3-3jNPitB374Pvy3yVibkhO9WPuUmFDw3AP0x1xcWjw3j8gDY_l3Hs_HyVf4con0gk17DYOqNJIgCV5dR38n2MNNY718MXmivqpFTevg4Kx0AaFPNBbixRNLlIhGbKURo3KPirUGdS_bmU4fC3p_y1xPT8qs8l-2mXT_t1XEpMQDyAF_uRKGQwNifyz-GyeuXE8hNr_32zMJEDDKRD6cP5JvfCAt--gGKIWlYfbt2e3KbG7KMnbflCTdHFvGWNa0G49Y7LUU7IebfTbuX2R8XJLi5uE3GkSSuSp3FL4aqdA1qnBOQnN7ui37BMI9vsZMRQvyYTVynQJk5wBAD59QPVPiKQocknGqeEBTKhg84vNemL9ArZYTQcxnOg-kN6Wsi9wlWoU5Q8kpsHnuEEIqRyTROcXZ4z-6Fx_S3nFVA2VBcNKA4gH9ZzsWz1N1hswFmTaeDR12PkKNVgZgXdepGoT7D8Xe3AmLtEK4Szaen1PeYEcK0VjVpglLFYMOv49a25JxU-PjcT4rA35FQ-vrSau4FHYZRDoaUi_vcZL87pjwd1OLo7pFTzJf45k_sVTl3KPasOGaHdxdC1Q6aGr9m1vTNrgy2_unqH1u4Zgrv_vyj3KlcwWkUvNlBohE-GBh4LCgeq9Piz-rq0pUOuIRheCHKgLWOu64u128pXvjvtPu-uvFwHZ9dsRQNOYEwABTI9uKgZd4hpYLVzrTSm0Y3-DS0MCnfCq5fq25PBFUfTu5XdbDt1hkCubKyw-MRHalVgZ7xlQ8HO-z7UdqHrc-JGJU40cUv6MUAq4UFdZcXkSeZdEtFj3Ww7Ck1fawNIDULzoc4ioBXJIHa7ibIVdNICU5Vv6I6d2GgAtbx5imxXXxqfvW3jqAdsTxBc9Y5c13MhTLmCrBUH33_Hya85pMqZak1uY9DQ8jgzbhSvlTZxp5rRf9p2dhPUSdr2MphN7VFOMm7cD5Fn2dseaQSjZI2wDw7A.sDAeL_Qo_PygnfFZsrk7JQ", 
        "TokenType": "Bearer", 
        "AccessToken": "eyJraWQiOiJlXC9DY3dwSjdOeWZFdk9OWXZhMmttQzdycENqRG9Rb1NKYXFaNURraldMdz0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI3MDM4MDg1Mi1iZGNiLTQ5NzAtOTU2Zi1kZTZkMGFjODBjODUiLCJ0b2tlbl91c2UiOiJhY2Nlc3MiLCJzY29wZSI6ImF3cy5jb2duaXRvLnNpZ25pbi51c2VyLmFkbWluIiwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLnVzLWVhc3QtMS5hbWF6b25hd3MuY29tXC91cy1lYXN0LTFfV2RIRUdBaThPIiwiZXhwIjoxNDg3NTQ4OTc1LCJpYXQiOjE0ODc1NDUzNzUsImp0aSI6ImVjNjcxNzBlLTUwNzUtNDg4Yi04ZDhkLTdlNGYwYzkzMjcyOSIsImNsaWVudF9pZCI6IjEyc3I1MHBnMXVmMDA0NGFqNjNlNGhzaDZpIiwidXNlcm5hbWUiOiJmcmFuayJ9.GOcqDC2PMJdoIdCcvaG8a7GinZWGM-LwRKs98Ck-iLGkdxx3hfHK7AfaxTAE8QeP3MXoLJ0A-EwhNUofEJRhHA-R0cAsTBCmHUuIP2VLoBKSnUBFLnFojCkBoQDHE30aJ-HwIlxM9ExACDAnt6c58T3t8ALihdevUxstjRutBGJgYc-xQhXBJAqEZ0Ov7gu6-js4i070pnIEaS-NxfDIGNDqfE5tvQkglXN_RBezsnufrwFKYTqTRMeCweJE287X6-UCcTgZY16GZw8SVqik9LqbXfO9lufo3W6vkDU-fEwNat1Q-S2iKXwK-Ew2e6mQZHOHxHcw2RQ709Z_iDv3mw"
    }, 
    "ChallengeParameters": {}
}
```

Now we can use that as the `Authorization` header to make a request to our API (at the POST endpoint returned after running `serverless deploy` above) using the following.

``` bash
$ curl https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes \
  -H "Authorization:eyJraWQiOiIxeVVnNXQ3NWY3YzlzYlpnNURZZWFDVWhGMVhEOEdUUEpNXC9zQVhDZEhFbz0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI3MDM4MDg1Mi1iZGNiLTQ5NzAtOTU2Zi1kZTZkMGFjODBjODUiLCJhdWQiOiIxMnNyNTBwZzF1ZjAwNDRhajYzZTRoc2g2aSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE0ODc1NDUzNzUsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX1dkSEVHQWk4TyIsImNvZ25pdG86dXNlcm5hbWUiOiJmcmFuayIsImV4cCI6MTQ4NzU0ODk3NSwiaWF0IjoxNDg3NTQ1Mzc1LCJlbWFpbCI6IndhbmdmYW5qaWVAZ21haWwuY29tIn0.d7HRBs2QegvQsGwQhJfpJBWYdh9N6CwoQFhmC91ugJ0YFxVdRhHUFQl4uoLplrOJO90PjTrjmxR7az17MfRlfu8v-ij3s31oaQqz8IdWECuhWW63xCNfGMN8lAbnUBwlHISer9CIGmdf8iF-xar2uyHeH8WHhIjI3gbJw15ORCC6Fo43CuKJ6k2zWaOywMkNr7oT2U7Etk93b2pDwIgeZ4V6uGbHgv3IRJYXYvMdIqsemoF8tLpx3XD58Iq8hNJlw_gOpOp8dlpDA3AK9-vjyXYDjJ_0zZa6alf6j0XEgwCVm08IIcYhF8ntg7ju0ZVBbQwYrdgzBCBhxtfzz1elVg" \
  -d "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}"
```

If the curl command is successful, the response will look similar to this.

``` bash
{
  "userId": "2aa71372-f926-451b-a05b-cf714e800c8e",
  "noteId": "578eb840-f70f-11e6-9d1a-1359b3b22944",
  "content": "hello world",
  "attachment": "hello.jpg",
  "createdAt": 1487555594691
}
```

And that's it for the backend! Next we are going to move on to creating the frontend of our app.
