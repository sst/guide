---
layout: post
title: Create a Billing Form
date: 2018-03-23 00:00:00
lang: ko
description: Stripe React SDK를 사용하여 React 앱에 청구 양식을 작성합니다. CardElement를 사용하여 사용자가 신용 카드 세부 정보를 입력하도록하고 createToken 메소드를 호출하여 serverless billing API에 전달할 수있는 토큰을 생성합니다. 
context: true
comments_id: create-a-billing-form/186
ref: create-a-billing-form
---

이제 설정 페이지에는 사용자의 신용 카드 정보를 가져 와서 Stripe 토큰을 받고 결제 API를 호출하는 양식을 추가합니다. Stripe React SDK를 프로젝트에 추가해 보겠습니다.

<img class="code-marker" src="/assets/s.png" />프로젝트 루트에서 다음을 실행합니다.

``` bash
$ npm install --save react-stripe-elements
```

다음으로 청구서 양식 컴포넌트를 생성합니다.

<img class="code-marker" src="/assets/s.png" />아래 내용을 추가한 `src/components/BillingForm.js`파일을 생성합니다.

{% raw %}
``` coffee
import React, { Component } from "react";
import { FormGroup, FormControl, ControlLabel } from "react-bootstrap";
import { CardElement, injectStripe } from "react-stripe-elements";
import LoaderButton from "./LoaderButton";
import "./BillingForm.css";

class BillingForm extends Component {
  constructor(props) {
    super(props);

    this.state = {
      name: "",
      storage: "",
      isProcessing: false,
      isCardComplete: false
    };
  }

  validateForm() {
    return (
      this.state.name !== "" &&
      this.state.storage !== "" &&
      this.state.isCardComplete
    );
  }

  handleFieldChange = event => {
    this.setState({
      [event.target.id]: event.target.value
    });
  }

  handleCardFieldChange = event => {
    this.setState({
      isCardComplete: event.complete
    });
  }

  handleSubmitClick = async event => {
    event.preventDefault();

    const { name } = this.state;

    this.setState({ isProcessing: true });

    const { token, error } = await this.props.stripe.createToken({ name });

    this.setState({ isProcessing: false });

    this.props.onSubmit(this.state.storage, { token, error });
  }

  render() {
    const loading = this.state.isProcessing || this.props.loading;

    return (
      <form className="BillingForm" onSubmit={this.handleSubmitClick}>
        <FormGroup bsSize="large" controlId="storage">
          <ControlLabel>Storage</ControlLabel>
          <FormControl
            min="0"
            type="number"
            value={this.state.storage}
            onChange={this.handleFieldChange}
            placeholder="Number of notes to store"
          />
        </FormGroup>
        <hr />
        <FormGroup bsSize="large" controlId="name">
          <ControlLabel>Cardholder&apos;s name</ControlLabel>
          <FormControl
            type="text"
            value={this.state.name}
            onChange={this.handleFieldChange}
            placeholder="Name on the card"
          />
        </FormGroup>
        <ControlLabel>Credit Card Info</ControlLabel>
        <CardElement
          className="card-field"
          onChange={this.handleCardFieldChange}
          style={{
            base: { fontSize: "18px", fontFamily: '"Open Sans", sans-serif' }
          }}
        />
        <LoaderButton
          block
          bsSize="large"
          type="submit"
          text="Purchase"
          isLoading={loading}
          loadingText="Purchasing…"
          disabled={!this.validateForm()}
        />
      </form>
    );
  }
}

export default injectStripe(BillingForm);
```
{% endraw %}

우리가 여기서 뭘하고 있는지 빨리 알아 보겠습니다.

- 먼저 우리는 `injectStripe` HOC를 사용하여 Stripe 모듈로 컴포넌트를 만들어서 사용할 것입니다. 그리고 이 컴포넌트가 `this.props.stripe.createToken` 메소드에 접근할 수 있게합니다.

- 양식의 필드는 사용자가 저장할 노트 수를 입력할 수있는 `number` 타입의 입력 필드가 있습니다. 또한 신용카드상의 이름을 사용합니다. 이것들은 `this.handleFieldChange` 메서드를 통해 state에 저장됩니다.

- 신용카드 번호 양식은 헤더에서 가져 오는 `CardElement` 구성 요소를 통해 Stripe React SDK에 의해 제공됩니다.

- 전송 버튼에는 Stripe을 호출하여 토큰을 얻고 결제 API를 호출할 때 로딩 상태를 true로 설정합니다. 그러나 Setting 컨테이너가 결제 API를 호출하므로 `this.props.loading`을 사용하여 버튼의 상태를 Setting 컨테이너에서 설정합니다.

- 또한 이름, 노트 수 및 카드 세부 사항이 완료되었는지 확인하여이 양식의 유효성을 검사합니다. 카드의 세부 사항을 위해 우리는 CardElement의 onChange 메소드를 사용합니다.

- 마지막으로 사용자가 양식을 완성하고 제출하면 신용 카드 이름과 신용 카드 세부 정보(Stripe SDK에서 처리)를 전달하여 Stripe에 요청합니다. 우리는 `this.props.stripe.createToken` 메소드를 호출하고 리턴 값으로 토큰이나 에러를 반환합니다. 이 값과 notes 수를 `this.props.onSubmit` 메소드를 통해 Setting 페이지에 저장하면됩니다. 곧 바로 이것을 설정해보겠습니다.

[여기에서 React Stripe Elements](https://github.com/stripe/react-stripe-elements) 사용 방법에 대한 자세한 내용을 볼 수 있습니다.

또한 신용카드 필드에 스타일을 추가하여 나머지 UI와 일치하도록하십시오.

<img class="code-marker" src="/assets/s.png" />아래 내용으로 `src/components/BillingForm.css` 파일을 생성합니다.

``` css
.BillingForm .card-field {
  margin-bottom: 15px;
  background-color: white;
  padding: 11px 16px;
  border-radius: 6px;
  border: 1px solid #CCC;
  box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
  line-height: 1.3333333;
}

.BillingForm .card-field.StripeElement--focus {
  box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 8px rgba(102, 175, 233, .6);
  border-color: #66AFE9;
}
```

### 변경 사항 커밋

<img class="code-marker" src="/assets/s.png" />Git에 변경 사항을 빠르게 커밋합니다.

``` bash
$ git add .
$ git commit -m "Adding a billing form"
```

다음으로 작성한 양식을 Setting 페이지에 연결하겠습니다.
