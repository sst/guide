---
layout: post
title: Co to jest serverless?
date: 2020-10-23 11:00:00
lang: pl
ref: what-is-serverless
description: Serverless odnosi się do aplikacji, w których zarządzanie oraz alokacja serwerów i zasobów jest całkowicie zarządzana przez dostawcę chmury. Rozliczenie kosztów opiera się na rzeczywistym zużyciu zasobów.
comments_id: what-is-serverless/27
---

Zazwyczaj budujemy i wdrażamy aplikacje webowe, w których mamy pewien stopień kontroli nad żądaniami HTTP kierowanymi do serwera. Aplikacja działa na naszym serwerze, a my odpowiadamy za zapewnienie niezbędnych zasobów i zarządzanie nimi. Z tym podejściem wiąże się kilka problemów.

1. Jesteśmy obciążani kosztami utrzymania serwera nawet wtedy, gdy nie obsługujemy żadnych żądań. 

2. Jesteśmy odpowiedzialni za dostępność i utrzymanie serwera oraz wszystkich jego zasobów.

3. Jesteśmy również odpowiedzialni za stosowanie odpowiednich aktualizacji zabezpieczeń na serwerze. 

4. Wraz ze wzrostem obciążenia musimy zarządzać skalowaniem naszego serwera w górę. A co za tym idzie, musimy zarządzać skalowaniem w dół, gdy nie mamy tak dużego obciążenia.

W przypadku mniejszych firm i indywidualnych deweloperów może to się okazać trudne do wykonania. W rezultacie nie skupiamy się na zadaniach ważniejszych: budowaniu i utrzymaniu aplikacji. W większych organizacjach zajmuje się tym zespół ds. infrastruktury i zwykle nie jest to obowiązkiem samego dewelopera. Procesy związane z zarządzaniem serwerami mogą niestety spowolnić prace nad aplikacją, ponieważ nie możesz po prostu zbudować aplikacji bez współpracy z zespołem ds. infrastruktury, który pomoże Ci rozpocząć pracę. Jako deweloperzy szukaliśmy rozwiązania tego problemu, i właśnie tu pojawia się technologia serverless.

### Serverless computing

Serverless computing (w skrócie serverless) to model, w którym dostawca chmury (AWS, Azure, czy Google Cloud) jest odpowiedzialny za wykonanie fragmentu kodu poprzez dynamiczną alokację zasobów. Naliczanie opłat odbywa się jedynie za zasoby faktycznie wykorzystane do uruchomienia kodu. Kod jest zwykle uruchamiany w kontenerach bezstanowych, które mogą być wyzwalane przez różne zdarzenia, w tym żądania http, wydarzenia z bazy danych, usługi kolejkowania, alarmy monitorowania, ładowanie plików, zaplanowane zdarzenia (zadania cron) itp. Kod do wykonania wysyłany do dostawcy chmury ma zwykle postać funkcji. Stąd serverless jest czasami określane jako _„Functions as a Service”_ lub _„FaaS”_. Poniżej przedstawiono ofertę FaaS głównych dostawców chmury:

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

Pomimo że infrastruktura w serverless jest niewidoczna dla dewelopera, serwery nadal są wykorzystywane do wykonywania naszych funkcji. 

Jako, że Twój kod będzie wykonywany właśnie w ramach pojedynczych funkcji, jest kilka pojęć, które musimy wyjaśnić.

### Mikroserwisy

Największą zmianą, przed którą stoimy przechodząc do świata serverless, jest to, że architektura naszej aplikacji musi mieć postać funkcji. Być może jesteś przyzwyczajony do wdrażania aplikacji jako pojedynczej monolitycznej aplikacji Rails lub Express. Tymczasem w świecie serverless zazwyczaj wymagane jest przyjęcie architektury opartej na mikrousługach. Możesz obejść ten wymóg, uruchamiając całą aplikację za pomocą jednej funkcji jako monolit i samodzielnie obsługując routing. Niemniej jednak, nie jest to zalecane, ponieważ znacznie lepiej jest tworzyć funkcje o małych rozmiarach. Wyjaśnimy to poniżej.

### Funkcje bezstanowe

Twoje funkcje są uruchamiane w bezpiecznych, (prawie) bezstanowych kontenerach. Oznacza to, że nie będziesz w stanie wykonać kodu na serwerze aplikacji długo po zakończeniu zdarzenia wyzwalającego, lub używając kontekstu poprzedniego wykonania do obsługi nowego żądania. Musisz założyć, że Twoja funkcja jest wywoływana za każdym razem w nowym kontenerze. 

Istnieją jednak pewne niuanse z tym związane; omówimy je w rozdziale [Co to jest AWS Lambda?]({% link _chapters / what-is-aws-lambda.md%}).

### Cold start

Z uwagi na to, że funkcje uruchamiane są w kontenerze, który jest tworzony na żądanie, aby odpowiedzieć na zdarzenie, wiąże się z tym pewne opóźnienie. Jest to tzw. _cold start_ (zimny start). Twój kontener może być aktywny jeszcze przez chwilę po zakończeniu wykonywania funkcji. Jeśli w tym czasie zostanie wyzwolone inne zdarzenie, funkcja zareaguje znacznie szybciej; jest to tzw. _warm start_ (ciepły start).

Czas trwania cold startu zależy od implementacji danego dostawcy chmury. W przypadku AWS Lambda może wynieść od kilkuset milisekund do kilku sekund. Czas może się różnić w zależności od używanego środowiska uruchomieniowego (lub języka), rozmiaru funkcji (jako pakietu) i oczywiście od danego dostawcy chmury. Cold starty znacznie się poprawiły na przestrzeni lat, jako że dostawcom usług w chmurze udało się zoptymalizować czasy opóźnienia przesyłu.

Oprócz optymalizacji funkcji możesz wykorzystać proste tricki, jak na przykład pomocniczą, zaplanowaną funkcję, która będzie wywoływać Twoje właściwe funkcje co kilka minut, i tym samym utrzyma je w trybie rozgrzanym. [Framework Serverless](https://serverless.com), którego będziemy używać w tym samouczku, ma kilka wtyczek, które [pomagają utrzymać funkcje w trybie rozgrzanym](https://github.com/FidelLimited/serverless-plugin-warmup).

Teraz, gdy mamy lepsze pojęcie o serverless, przyjrzyjmy się dokładniej czym jest funkcja Lambda i w jaki sposób będzie wykonywany Twój kod.
