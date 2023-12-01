---
layout: post
title: Para quem é este guia?
date: 2016-12-21 00:00:00
lang: pt
ref: who-is-this-guide-for
context: true
comments_id: who-is-this-guide-for/96
---

Esse guia foi feito para desenvolvedores full-stack ou desenvolvedores que desejam criar aplicativos por completo com a tecnologia Serverless. Com um guia passo a passo tanto para os desenvolvedores backend quanto para os frontend, nós tentaremos abordar todos os aspectos da criação de aplicações Serverless. Existem vários outros tutoriais na internet mas nós acreditamos que vale a pena ter em algum lugar algo referenciando todos os pontos do processo. Esse guia servirá para ensinar como construir e fazer deploy de aplicações Serverless e não trazer as melhores práticas e convenções para fazer isso.

Talvez você seja um desenvolvedor backend querendo aprender mais sobre a parte frontend de aplicações Serverless, ou um desenvolvedor frontend que gostaria de aprender mais sobre backend. Esse guia servirá para ambos os casos.

Pessoalmente, a ideia do Serverless foi uma enorme revelação para nós e isso nos fez criar um guia com qual poderíamos compartilhar o que aprendemos. Você pode saber mais sobre nós [**aqui**]({% link about/index.html %}). E [veja alguns exemplos de pessoas que construíram aplicações com SST clicando aqui]({% link showcase.md %})

Por hora, apenas vamos abordar o desenvolvimento com JavaScript/TypeScript. Futuramente talvez abordemos outras linguagens e ambientes. Porém, para começar, nós achamos muito benéfico para um desenvolvedor full-stack utilizar apenas uma linguagem (TypeScript) e ambiente (Node.js) para a construção de uma aplicação completa.

### Por que TypeScript

Nós usamos TypeScript desde o frontend, backend e até a criação da nossa infraestrutura. Se você não estiver familiar com TypeScript talvez você esteja pensando por que tipagem estática importa.

Uma grande vantagem em usar tipagem estática em todo o código é que seu editor de código consegue autocompletar e mostrar opções inválidas no seu código. Isso é muito útil quando você esta começando. Porém, isso também pode ser útil quando você está configurando sua infraestrutura através de código.

Deixando toda essa benevolência do autocomplete de lado, tipagem estática acaba sendo um ponto crítico para ajudar na manutenibilidade de um projeto. Isso importa muito se você pretende trabalhar no mesmo projeto, com o mesmo código, por anos.

Deve ser fácil para você e seu time fazer modificações em partes do seu projeto após muito tempo sem mexer nele. TypeScript permite que você faça isso! Seu projeto não vai ser mais tão _frágil_ e você não terá medo de fazer modificações.

#### TypeScript do jeito fácil

Se você não está acostumado com TypeScript, você deve estar pensando _"Então eu vou ter que escrever todos esses tipos extras para minhas coisas?"_ ou _"Toda essa tipagem não vai deixar meu código verboso e assustador?"_.

Essas preocupações são válidas. Mas acontece que, se as bibliotecas que você está usando são feitas para o uso junto ao TypeScript, você não irá ter tantas tipagens extras no seu código. Na verdade, como você vai ver nesse tutorial, você vai ter todos os benefícios de um projeto tipado com um código que quase parece com o JavaScript normal.

Além disso, o TypeScript pode ser adotado gradativamente. Isso significa que você pode usar o nosso projeto base de TypeScript e adicionar JavaScript a ele. Fazer isso não é recomendável, porém isso pode ser uma opção.

Vamos começar dando uma olhada sobre o que vamos contemplar nesse guia a seguir.