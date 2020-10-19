---
layout: post
title: Co zawiera ten przewodnik?
date: 2020-10-16 00:00:00
lang: pl
ref: what-does-this-guide-cover
comments_id: what-does-this-guide-cover/83
---

Aby poruszyć główne kwestie związane z tworzeniem aplikacji internetowych, zamierzamy zbudować prostą aplikację do robienia notatek o nazwie [**Scratch**](https://demo2.serverless-stack.com). Jednak w przeciwieństwie do większości samouczków naszym celem jest zgłębienie się w szczegóły każdego z etapów tworzenia i wdrożenia full-stackowej aplikacji.

![Completed app desktop screenshot](/assets/completed-app-desktop.png)

<img alt="Completed app mobile screenshot" src="/assets/completed-app-mobile.png" width="432" />

Jest to aplikacja jednostronicowa obsługiwana przez bezserwerowe API, napisana w całości w języku JavaScript. Tutaj znajdziesz kompletny kod [backendowy]({{ site.backend_github_repo }}) i [frontendowy]({{ site.frontend_github_repo }}). Aplikacja jest stosunkowo prosta, niemniej jednak zamierzamy spełnić następujące wymagania:

- Aplikacja powinna umożliwiać użytkownikom rejestrację i logowanie do swoich kont 
- Użytkownicy powinni mieć możliwość tworzenia notatek z treścią
- Każda notatka może zawierać również załącznik, przesłany jako plik
- Zezwala użytkownikom na edytowanie ich notatek i załączników 
- Użytkownicy mogą również usuwać swoje notatki
- Aplikacja powinna mieć możliwość przetwarzania płatności kartą płatniczą
- Dostęp do aplikacji powinien być gwarantowany za pomocą HTTPS w domenie niestandardowej
- Interfejsy API muszą być zabezpieczone
- Aplikacja musi być responsywna
- Aplikacja powinna zostać wdrożona za pomocą git push
- Powinniśmy być w stanie monitorować i usuwać wszelkie błędy

Do tworzenia aplikacji będziemy używać platformy AWS. Możliwe, że w przyszłości rozszerzymy zakres przewodnika i uwzględnimy inne platformy. Nie mniej uznaliśmy, że platforma AWS będzie dobra na początek.

### Technologie i usługi 

Do stworzenia naszej aplikacji serverless użyjemy następujących usług i technologii:

- [Lambda][Lambda] i  [API Gateway][APIG] do bezserwerowych interfejsów API
- [DynamoDB][DynamoDB] jako bazy danych 
- [Cognito][Cognito] do uwierzytelniania użytkowników i zabezpieczania interfejsów API
- [S3][S3] do hostingu aplikacji i przesyłania plików
- [CloudFront][CF] do udostępniania aplikacji
- [Route 53][R53] do obsługi domeny
- [Certificate Manager][CM] do połączenia SSL
- [CloudWatch][CloudWatch] do monitorowania Lambdy i logów dostępu do API
- [React.js][React] do stworzenia aplikacji jednostronicowej
- [React Router][RR] do routingu 
- [Bootstrap][Bootstrap] do interfejsu użytkownika
- [Stripe][Stripe] do obsługi płatności kartą płatniczą
- [Seed][Seed] do automatyzacji wdrożeń serverless
- [Netlify][Netlify] do automatyzacji wdrożeń React
- [GitHub][GitHub] do hostingu repozytoriów naszego projektu
- [Sentry][Sentry] do zgłaszania błędów

Będziemy korzystać z **darmowych pakietów** powyższych usług, zatem powinieneś móc zarejestrować się do nich bez dodatkowych kosztów. Naturalnie, nie dotyczy to zakupu nowej domeny do hostingu twojej aplikacji. Dodatkowo, aby założyć konto AWS wymagane jest podanie karty płatniczej, więc jeśli stworzysz zasoby wykraczające poza to, co omówimy w tym samouczku, możesz zostać obciążony kosztami. 

Pomimo że powyższa lista może wydawać się zniechęcająca, chcemy mieć pewność, że po ukończeniu tego samouczka będziesz przygotowany, aby tworzyć **praktyczne**, **bezpieczne** i **w pełni funkcjonalne** aplikacje internetowe. Bez obaw, będziemy tu, aby pomóc!

### Wymagania

Do pracy z tym przewodnikiem potrzebujesz jedynie paru rzeczy: 
- [Node v8.10+ i NPM v5.5+](https://nodejs.org/en/) zainstalowane na Twoim komputerze.
- Darmowe [konto na GitHub](https://github.com/join).
- Oraz podstawową wiedzę na temat korzystania z wiersza poleceń.

### Struktura tego przewodnika

Przewodnik jest podzielony z grubsza na kilka części:
1. **Podstawy**

  Tutaj omawiamy jak zbudować Twoją pierwszą full-stackową aplikację serverless. Rozdziały są mniej więcej podzielone na backend (Serverless) i frontend (React). Omówimy również jak wdrożyć Twoją aplikację serverless i aplikację React w środowisku produkcyjnym. 
Ta część przewodnika została starannie opracowana, aby zrealizować ją od początku do końca. Szczegółowo omawiamy wszystkie kroki i prezentujemy mnóstwo zrzutów ekranu, które pomogą Ci stworzyć Twoją pierwszą aplikację. 

2. **Najlepsze praktyki**

  Na początku 2017 roku udostępniliśmy pierwszą wersję tego przewodnika, która obejmowała jedynie podstawy. Z biegiem czasu społeczność Serverless Stack rozrosła się i wielu naszych czytelników postanowiło wykorzystać konfigurację opisaną w tym przewodniku do stworzenia aplikacji, które napędzają ich biznes. W tej sekcji omówimy najlepsze praktyki związane z działaniem aplikacji w trybie produkcyjnym. Nabierają one wielkiego znaczenia, gdy baza kodu aplikacji się rozrasta lub gdy dodajesz więcej osób do swojego zespołu. Rozdziały w tej sekcji są stosunkowo niezależne i zwykle obracają się wokół określonych tematów. 

3. **Odsyłacze**

  Na koniec, mamy zbiór niezależnych rozdziałów na różne tematy. Odnosimy się do nich w przewodniku lub używamy ich do omówienia tematów, które niekoniecznie są powiązane z poprzednimi sekcjami. 

### Tworzenie Twojej pierwszej aplikacji serverless 

Pierwsza część tego przewodnika pomoże Ci zbudować aplikację do robienia notatek i wdrożyć ją w trybie produkcyjnym. Omówimy wszelkie podstawy. Każda usługa będzie tworzona ręcznie. Oto co omówimy po kolei: 

Backend: 

- Konfiguracja konta AWS
- Tworzenie bazy danych za pomocą DynamoDB
- Konfiguracja S3 do przesyłania plików
- Konfiguracja Cognito User Pools, aby zarządzać kontami użytkowników
- Konfiguracja Cognito Identity Pool, aby zabezpieczyć przesyłanie plików
- Konfiguracja Serverless Framework do pracy z Lambda i API Gateway
- Tworzenie backendowych interfejsów API 
- Praca z zewnętrznymi interfejsami API (Stripe)
- Wdrożenie aplikacji za pomocą wiersza poleceń

Frontend: 

- Konfiguracja projektu za pomocą aplikacji Create React App
- Dodanie favicon, czcionek i UI Kit za pomocą Bootstrap
- Konfiguracja ścieżek za pomocą React-Router
- Użycie AWS Cognito SDK do logowania i rejestracji użytkowników
- Wtyczka do backendowych interfejsów API, służąca do zarządzania notatkami
- Użycie AWS JS SDK do przesyłu plików
- Przyjmowanie płatności kartą płatniczą w React
- Środowiska w aplikacji Create React App
- Wdrożenie frontendu na produkcję przy użyciu Netlify
- Konfiguracja domeny niestandardowej za pomocą Netlify

Automatyzacja backendowych wdrożeń: 

- Konfiguracja DynamoDB za pomocą kodu
- Konfiguracja S3 za pomocą kodu
- Konfiguracja Cognito User Pool za pomocą kodu
- Konfiguracja Cognito Identity Pool za pomocą kodu
- Zmienne środowiskowe w Serverless Framework
- Praca z sekretami w Serverless Framework
- Testy jednostkowe w Serverless
- Automatyzacja wdrożeń za pomocą Seed
- Konfiguracja domen niestandardowych poprzez Seed

Monitorowanie i debugowanie aplikacji serverless:

- Konfiguracja raportowanie błędów w React za pomocą Sentry
- Konfiguracja Error Boundary w React
- Dodanie logowania błędów do interfejsów Serverless API
- Uwzględnienie praktyk debugowania dla typowych błędów Serverless

Uważamy, że zapewni Ci to dobre podstawy do budowania gotowych do pracy w środowisku produkcyjnym full-stackowych aplikacji serverless. Jeśli chciałbyś, abyśmy uwzględnili inne koncepcje lub technologie, daj nam znać na naszych [forach]({{ site.forum_url }}).

[Cognito]: https://aws.amazon.com/cognito/
[CM]: https://aws.amazon.com/certificate-manager
[R53]: https://aws.amazon.com/route53/
[CF]: https://aws.amazon.com/cloudfront/
[S3]: https://aws.amazon.com/s3/
[CloudWatch]: https://aws.amazon.com/cloudwatch/
[Bootstrap]: http://getbootstrap.com
[RR]: https://github.com/ReactTraining/react-router
[React]: https://facebook.github.io/react/
[DynamoDB]: https://aws.amazon.com/dynamodb/
[APIG]: https://aws.amazon.com/api-gateway/
[Lambda]: https://aws.amazon.com/lambda/
[Stripe]: https://stripe.com
[Seed]: https://seed.run
[Netlify]: https://netlify.com
[GitHub]: https://github.com
[Sentry]: https://sentry.io
