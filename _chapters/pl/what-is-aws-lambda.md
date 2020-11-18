---
layout: post
title: Co to jest AWS Lambda?
date: 2020-10-29 18:00:00
lang: pl
ref: what-is-aws-lambda
description: AWS Lambda to usługa obliczeniowa serverless dostępna na Amazon Web Services. Uruchamia fragmenty kodu (zwane funkcjami Lambda) w kontenerach bezstanowych, które są wywoływane na żądanie, aby odpowiedzieć na zdarzenia (takie jak żądania HTTP). Po zakończeniu wykonywania funkcji kontenery są wyłączane. Użytkownicy ponoszą koszt jedynie za czas potrzebny do wykonania funkcji.
comments_id: what-is-aws-lambda/308
---

[AWS Lambda](https://aws.amazon.com/lambda/) (w skrócie Lambda) to usługa obliczeniowa serverless dostępna na AWS. W tym rozdziale będziemy używać Lambdy do budowy naszej aplikacji serverless. Mimo tego, że nie musimy się przejmować szczegółami działania usługi, ważne jest, aby mieć ogólne pojęcie o tym, jak będą wykonywane Twoje funkcje.

### Specyfikacja Lambdy

Zacznijmy od szybkiego przyjrzenia się specyfikacji technicznej usługi AWS Lambda. Lambda obsługuje następujące środowiska uruchomieniowe:

- Node.js 12.13.0, 10.16.3, 8.10
- Java 11, 8
- Python 3.8, 3.7, 3.6, 2.7
- .NET Core 2.1, 2.2, 3.0, 3.1
- Go 1.x
- Ruby 2.5
- Rust

Zwróć uwagę, że [wsparcie dla .NET Core 2.2 i 3.0 jest dostępne poprzez niestandardowe środowiska uruchomieniowe](https://aws.amazon.com/blogs/developer/announcing-amazon-lambda-runtimesupport/).

Każda funkcja działa w kontenerze z 64-bitowym AMI Amazon Linux. Środowisko wykonawcze posiada:

- Pamięć RAM: 128MB - 3008MB, dostępna w przyrostach 64 MB 
- Efemeryczny dysk: 512MB
- Maksymalny czas wykonania: 900 sekund
- Rozmiar skompresowanego pakietu: 50 MB
- Rozmiar nieskompresowanego pakietu: 250 MB

Możliwe, że zauważyłeś, że procesor nie jest wymieniony jako część specyfikacji kontenera, z uwagi na to, że nie jest możliwa bezpośrednia kontrola nad nim. Wraz ze zwiększeniem pamięci RAM zwiększa się również ilość procesorów. 

Przestrzeń na dysku efemerycznym jest dostępna w postaci katalogu `/tmp`. Możesz go używać jedynie do tymczasowego przechowywania, ponieważ kolejne wywołania nie będą miały do niego dostępu. W dalszej części powiemy nieco więcej na temat bezstanowej natury funkcji Lambda.

Określony czas wykonania wskazuje na to, że funkcja Lambda może działać maksymalnie przez 900 sekund, tzn. 15 minut. Co za tym idzie - Lambda nie jest przeznaczona do długotrwałych procesów.  

Rozmiar pakietu odnosi się do całego kodu niezbędnego do uruchomienia funkcji. Obejmuje to również wszelkie zależności (w przypadku Node.js jest to katalog `node_modules/'), które Twoja funkcja potrzebuje zaimportować. Maksymalny rozmiar pakietu nieskompresowanego to 250 MB i 50 MB po skompresowaniu. Poniżej przyjrzymy się procesowi pakowania.

### Funkcje Lambda

A więc, tak wygląda funkcja Lambda (wersja Node.js).

![Anatomia funkcji Lambda obraz](/assets/anatomy-of-a-lambda-function.png)

Tutaj `myHandler` jest nazwą naszej funkcji Lambda. Obiekt `event` zawiera wszystkie informacje o zdarzeniu, które wywołało tę Lambdę. W przypadku żądania HTTP będzie to informacja o konkretnym żądaniu HTTP. Obiekt `context` zawiera informacje o środowisku uruchomieniowym, w którym nasza funkcja Lambda jest wykonywana. Po wykonaniu całego kodu zdefiniowanego wewnatrz funkcji Lambda wywoływana jest funkcja `callback` z otrzymanym wynikiem (lub błędem), którym to AWS odpowie na żądanie HTTP.

### Pakowanie funkcji

Funkcje Lambda należy spakować i przesłać do AWS. Oznacza to zwykle proces kompresji funkcji i wszystkich jej zależności oraz przesłania ich do wiadra S3. Należy również powiadomić AWS, że chcesz użyć tego pakietu, gdy ma miejsce określone zdarzenie. Aby ułatwić cały ten proces, używamy [frameworka Serverless] (https://serverless.com). Omówimy to szczegółowo w dalszej części tego przewodnika.

### Model wykonawczy

Kontener (i wykorzystywane przez niego zasoby), w którym działa nasza funkcja, jest w całości zarządzany przez AWS. Jest wywoływany, gdy ma miejsce zdarzenie i wyłączany, jeśli nie jest używany. Jeśli podczas obsługi jednego zdarzenia wysyłane są nowe żądania, do ich obsługi zostanie przydzielony nowy kontener. Oznacza to, że jeśli mamy do czynienia z gwałtownym wzrostem liczby żądań, dostawca chmury zwyczajnie utworzy wiele kontenerów z naszą funkcją, aby móc obsłużyć te żadania.

Ma to pewne interesujące konsekwencje. Po pierwsze, nasze funkcje są bezstanowe. Po drugie, każde żądanie (lub zdarzenie) jest obsługiwane przez jedną instancję funkcji Lambda. Oznacza to, że nie możesz obsługiwać jednoczesnych żądań w swoim kodzie. AWS tworzy kontener w momencie gdy pojawia się nowe żądanie, niemniej jednak dokonuje tu pewnej optymalizacji. Kontener pozostaje aktywny przez kilka minut (5 - 15 minut w zależności od obciążenia), dzięki czemu może odpowiadać na kolejne żądania bez cold startu.

### Funkcje bezstanowe 

Opisany powyżej model wykonawczy sprawia, że funkcje Lambda są faktycznie bezstanowe. Oznacza to, że za każdym razem, gdy funkcja Lambda jest wyzwalana przez zdarzenie, jest ona wywoływana w zupełnie nowym środowisku. Nie mamy dostępu do kontekstu wykonawczego poprzedniego zdarzenia.

Jednak ze względu na wspomnianą powyżej optymalizację, kompletny kod Lambdy wykonywany jest jedynie podczas tworzenia nowego kontenera. Pamiętaj, że nasze funkcje działają w kontenerach, tak więc kiedy funkcja jest wywoływana po raz pierwszy, zostanie wykonany kompletny zadany kod źródłowy, łącznie z właściwą funkcją (handlerem). Jeśli kontener jest nadal dostępny dla kolejnych żądań, zostanie wywołany jedynie handler, a kod wokół niego zostanie pominięty.

Posługując się przykładem, poniższa metoda `createNewDbConnection` jest wywoływana jedynie podczas tworzenia nowego kontenera, a nie za każdym razem, gdy wywoływana jest funkcja Lambda. Z kolei funkcja `myHandler` jest wywoływana przy każdym wywołaniu.

``` javascript
var dbConnection = createNewDbConnection();

exports.myHandler = function(event, context, callback) {
  var result = dbConnection.makeQuery();
  callback(null, result);
};
```

Ten efekt cache'owania kontenerów dotyczy również katalogu `/tmp`, o którym wspomnialiśmy powyżej. Będzie on dostępny tak długo, jak długo kontener pozostanie aktywny.

Jak zapewne się domyślasz, nie jest to niezawodny sposób na uczynienie naszych funkcji Lambda stanowymi. Powodem jest fakt, że zwyczajnie nie mamy kontroli nad procesem wywoływania Lambdy oraz cache'owania jej kontenerów.

### Stawki

Na koniec, funkcje Lambda są rozliczane tylko za czas potrzebny do wykonania funkcji. Czas jest liczony od momentu rozpoczęcia wykonywania do momentu otrzymania wyniku lub przerwania, oraz jest zaokrąglany w górę do najbliższych 100 ms.

Zwróć uwagę, że mimo tego, że AWS może zachować kontener z funkcją Lambda po zakończeniu jej wykonania nie zostaniesz za to obciążony.

Lambda ma spory pakiet darmowy, dlatego też jest mało prawdopodobne, że przekroczysz jego limit podczas pracy z tym przewodnikiem.

Bezpłatny pakiet Lambdy obejmuje 1 mln żądań miesięcznie i 400 000 GB-sekund czasu obliczeniowego miesięcznie. Po przekroczeniu limitu kosztuje 0,20 USD za 1 milion żądań i 0,00001667 USD za każdą GB-sekundę. Liczba GB-sekund zależy od zużycia pamięci przez funkcję Lambda. Więcej informacji możesz znaleźć na [stronie z cennikiem Lambdy] (https://aws.amazon.com/lambda/pricing/). 

Z doświadczenia wiemy, że koszty związane z wykorzystaniem Lambdy stanowią zwykle najmniejszą cześć kosztów naszej infrastruktury. 

Następnie przyjrzyjmy się dokładniej zaletom modelu serverless, w tym całkowitemu kosztowi uruchomienia naszej aplikacji demo.
