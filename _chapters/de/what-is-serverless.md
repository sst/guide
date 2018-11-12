---
layout: post
title: Was ist Serverless?
date: 2016-12-23 12:00:00
lang: de
ref: what-is-serverless
description: Serverlos bezieht sich auf Anwendungen, bei denen die Verwaltung und Zuordnung von Servern und Ressourcen vollständig vom Cloud-Anbieter verwaltet wird. Die Abrechnung basiert auf dem tatsächlichen Verbrauch dieser Ressourcen.
comments_id: what-is-serverless/27
---

Web-Apps wurden traditionell so entwickelt, dass wir - die Entwickler - ein gewisses Maß an Kontrolle über die HTTP-Anfragen, die an unseren Server gemacht werden, haben. Unsere App läuft auf diesem Server und wir sind ebenfalls für die Bereitstellung, Wartung und Verwaltung dessen Resourcen verantwortlich. Bei diesem Modell gibt es mehrere Probleme:

1. Wir haben Kosten selbst dann, wenn der Server keine Anfragen erfüllt.

2. Wir sind für die Verfügbarkeit und Wartung des Servers inklusive aller seiner Ressourcen verantwortlich.

3. Wir sind auch dafür verantwortlich, immer die aktuellsten Sicherheits-Updates auf den Server anuwenden.

4. Wenn die Anforderungen an unseren Server mehr werden, müssen wir den Server dementsprechend selbst skalieren. Daraus resultierend müssen wir uns auch darum kümmern, das wir den Server runter-skalieren, wenn er nicht viel Verkehr bekommt.

Für kleinere Unternehmen und einzelne Entwickler kann das sehr viel Aufwand bedeuten. Das lenkt am Ende von der wichtigeren Arbeit ab, die wir haben: Den Aufbau und die Verwaltung der eigentlichen App. In größeren Organisationen wird dies von einem Infrastrukturteam erledigt, und normalerweise liegt es nicht in der Verantwortung des einzelnen Entwicklers. Die dazu erforderlichen Prozesse können jedoch die Entwicklungszeiten verlangsamen. Du musst dich von der eigentlichen entwicklung der App abwenden, damit das Infrastruktur-Team dir hilft alles aufzusetzen. Als Entwickler haben wir nach einer Lösung für diese Probleme gesucht, und genau da setzt _serverless_ an.

### Serverless Computing

_Serverless_ (zu Deutsch: Serverlos, ohne Server) ist ein Ausführungsmodell, bei dem der Cloud-Anbieter (AWS, Azure oder Google Cloud) für die Ausführung von Code verantwortlich ist, indem er die Ressourcen dynamisch zuweist. Es werden nur Kosten verrechnet, für die Zeit und Ressourcen die der Code tatsächlich zum ausführen gebraucht hat. Der Code wird normalerweise in _stateless containerns_ (zu Deutsch: Hüllen ohne Speicher) ausgeführt, die durch eine Vielzahl von Events ausgelöst werden können, z. B. HTTP-Anfragen, Datenbank-Events, Warteschlangendienste, Überwachungsalarme, Datei-Uploads, geplante Ereignisse (Cron-Jobs) usw. Der Code, der an die Cloud-Anbieter gesendet wird ist in der Regel in der Form einer Funktion. _Serverless_ wird daher manchmal als _Functions as a Service_ (zu Deutsch: _"Funktionen als Dienstleistung"_) oder _"FaaS"_ bezeichnet. Hier sind ein paar der FaaS-Angebote der großen Cloud-Anbieter:

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

Obwohl _serverless_ die dahinterliegende Infrastruktur vom Entwickler wegabstrahiert, sind trotzdem noch Server involviert, um unsere Funktionen auszuführen.

Da dein Code als einzelne Funktionen ausgeführt wird, müssen wir einige Dinge beachten.

### Microservices

Die größte Änderung, der wir uns beim Übergang in das _serverless_-Paradigma gegenübersehen, besteht darin, dass unsere Anwendung in Form von Funktionen gestaltet werden muss. Sie können es gewohnt sein, Ihre Anwendung als einzelne Rails- oder Express-Monolith-App bereitzustellen. In der Welt ohne Server ist es jedoch normalerweise erforderlich, eine auf Microservice basierende Architektur zu implementieren. Sie können dies umgehen, indem Sie Ihre gesamte Anwendung in einer einzigen Funktion als Monolith ausführen und das Routing selbst übernehmen. Dies wird jedoch nicht empfohlen, da es besser ist, die Größe Ihrer Funktionen zu reduzieren. Wir werden weiter unten darüber sprechen.

### Zustandslose Funktionen

Ihre Funktionen werden normalerweise in sicheren (fast) zustandslosen Containern ausgeführt. Dies bedeutet, dass Sie in Ihrem Anwendungsserver keinen Code ausführen können, der lange ausgeführt wird, nachdem ein Ereignis abgeschlossen wurde oder einen vorherigen Ausführungskontext für die Bearbeitung einer Anforderung verwendet. Sie müssen effektiv davon ausgehen, dass Ihre Funktion jedes Mal neu aufgerufen wird.

Dazu gibt es einige Feinheiten und wir werden im [Kapitel Was ist AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}) beschrieben.

### Kaltstart

Da Ihre Funktionen in einem Container ausgeführt werden, der bei Bedarf aufgerufen wird, um auf ein Ereignis zu reagieren, besteht eine gewisse Latenz. Dies wird als _Cold Start_ bezeichnet. Ihr Container wird möglicherweise eine Weile in der Umgebung aufbewahrt, nachdem die Ausführung der Funktion abgeschlossen ist. Wenn während dieser Zeit ein anderes Ereignis ausgelöst wird, reagiert es viel schneller und dies wird normalerweise als _Warm Start_ bezeichnet.

Die Dauer des Kaltstarts hängt von der Implementierung des jeweiligen Cloud-Anbieters ab. Bei AWS Lambda kann es zwischen einigen hundert Millisekunden und einigen Sekunden liegen. Dies kann von der verwendeten Laufzeit (oder Sprache), der Größe der Funktion (als Paket) und natürlich vom jeweiligen Cloud-Anbieter abhängen. Der Kaltstart hat sich im Laufe der Jahre drastisch verbessert, da Cloud-Anbieter die Optimierung der Latenzzeiten deutlich verbessert haben.

Neben der Optimierung Ihrer Funktionen können Sie einfache Tricks wie eine separate geplante Funktion verwenden, um Ihre Funktion alle paar Minuten aufzurufen, um sie warm zu halten. [Das Serverless Framework](https://serverless.com), das wir in diesem Tutorial verwenden werden, enthält einige Plugins, [mit denen Sie Ihre Funktionen warmhalten können](https://github.com/FidelLimited/serverless-plugin-warmup).

Nun, da wir eine gute Vorstellung von Serverless Computing haben, wollen wir uns genauer ansehen, was eine Lambda-Funktion ist und wie Ihr Code ausgeführt wird.
