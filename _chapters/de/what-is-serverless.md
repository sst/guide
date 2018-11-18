---
layout: post
title: Was ist Serverless?
date: 2016-12-23 12:00:00
lang: de
ref: what-is-serverless
description: Serverlos bezieht sich auf Anwendungen, bei denen die Verwaltung und Zuordnung von Servern und Ressourcen vollständig vom Cloud-Anbieter verwaltet wird. Die Abrechnung basiert auf dem tatsächlichen Verbrauch dieser Ressourcen.
comments_id: what-is-serverless/27
---

Web-Apps wurden traditionell so entwickelt, dass du als Entwickler ein gewisses Maß an Kontrolle über die HTTP-Anfragen hat, die an den Server gemacht werden. Die App läuft auf diesem Server und die Entwickler sind ebenfalls für die Bereitstellung, Wartung und Verwaltung von dessen Resourcen verantwortlich. Bei diesem Modell gibt es mehrere Probleme:

1. Es entstehen selbst dann Kosten, wenn der Server keine Anfragen erfüllt.

2. Du bist für die Verfügbarkeit und Wartung des Servers verantwortlich, inklusive aller seiner Ressourcen.

3. Du bist auch dafür verantwortlich, dass dein Server immer die aktuellsten Sicherheits-Updates hat.

4. Wenn die Anforderungen an deinen Server mehr werden, musst du den Server dementsprechend selbst skalieren. Daraus resultierend musst du dich auch darum kümmern den Server wieder runterzuskalieren, wenn er nicht viel Verkehr bekommt.

Für kleinere Unternehmen und einzelne Entwickler kann das sehr viel Aufwand bedeuten. Das lenkt am Ende nur von der wichtigsten Arbeit ab, die wir als Entwickler haben: Die eigentliche App bauen. In größeren Organisationen werden die oben genannten Probleme von einem Infrastrukturteam erledigt und es liegt normalerweise nicht in der Verantwortung des einzelnen Entwicklers. Trotzdem verlangsamen die benötigten Prozesse für ein Infrastruktur-Team in den meisten Fällen die Entwicklungszeiten. Anstatt einfach mit deiner App loszulegen, musst du dann mit hilfe des Infrastruktur-Teams alles aufsetzen und musst dich von der eigentlichen entwicklung der App abwenden. Als Entwickler haben wir nach einer Lösung für diese Probleme gesucht, und genau da setzt _serverless_ an.

### Serverless Computing

_Serverless_ (zu Deutsch: Serverlos, ohne Server) ist ein Ausführungsmodell, bei dem der Cloud-Anbieter (AWS, Azure oder Google Cloud) für die Ausführung von Code verantwortlich ist, indem er die Ressourcen dynamisch zuweist. Es werden nur Kosten für die Zeit verrechnet, die der Code auch tatsächlich zum Ausführen braucht. Der Code wird normalerweise in sogenannten _stateless containern_ (zu Deutsch: Programmhüllen ohne Langzeitspeicher) ausgeführt, die durch eine Vielzahl von Events ausgelöst werden können, z.B. HTTP-Anfragen, Datenbank-Events, Warteschlangendienste, Überwachungsalarme, Datei-Uploads, geplante Ereignisse (Cron-Jobs) usw. Der Code, der an die Cloud-Anbieter gesendet wird ist in der Regel in der Form einer Funktion. _Serverless_ wird daher manchmal als _Functions as a Service_ (zu Deutsch: _"Funktionen als Dienstleistung"_) oder _"FaaS"_ bezeichnet. Hier sind ein paar der FaaS-Angebote der großen Cloud-Anbieter:

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

Obwohl _serverless_ die dahinterliegende Infrastruktur vom Entwickler wegabstrahiert, sind trotzdem noch Server involviert, um dessen Funktionen auszuführen.

Da dein Code als einzelne Funktionen ausgeführt wird, müssen einige Dinge beachten werden.

### Microservices

Die größte Änderung, der Entwickler beim Übergang in das Serverlose-Paradigma gegenübersehen, besteht darin, dass die Anwendungen in Form von Funktionen gestaltet werden müssen. Als Entwickler kann man es gewohnt sein, seine Anwendung als einzelne Rails- oder Express-Monolith-App bereitzustellen. In der Welt ohne Server ist es jedoch normalerweise erforderlich, eine auf Microservice basierende Architektur zu implementieren. Man kann das umgehen, indem die gesamte Anwendung in einer einzigen Funktion als Monolith ausgeführt und das Routing selbst übernommen wird. Dies wird jedoch nicht empfohlen, da es besser ist, die Größe der Funktionen zu reduzieren. Wir werden weiter unten darüber sprechen.

### Zustandslose Funktionen

Funktionen werden normalerweise in sicheren (fast) zustandslosen Containern ausgeführt. Das bedeutet, dass man in einem Anwendungsserver keinen Code ausführen kann, der lange nach einem Ereignis ausgeführt wird oder einen vorherigen Ausführungskontext für die Bearbeitung einer Anforderung verwendet. Du musst effektiv davon ausgehen, dass die Funktion jedes Mal neu aufgerufen wird.

Dazu gibt es einige Feinheiten und wir werden im [Kapitel Was ist AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}) uns dem widmen.

### Kaltstart

Da die Funktionen in einem Container ausgeführt werden, der bei Bedarf aufgerufen wird um auf ein Ereignis zu reagieren, besteht eine gewisse Latenz. Dies wird als _Cold Start_ (zu Deutsch: kalter Start, Start ohne Vorbereitung) bezeichnet. Dein Container wird möglicherweise eine Weile in der Umgebung aufbewahrt, nachdem die Ausführung der Funktion abgeschlossen ist. Wenn während dieser Zeit ein anderes Ereignis ausgelöst wird, reagiert es viel schneller und dies wird normalerweise als _Warm Start_ bezeichnet.

Die Dauer des Kaltstarts hängt von der Implementierung des jeweiligen Cloud-Anbieters ab. Bei AWS Lambda kann es zwischen einigen hundert Millisekunden und einigen Sekunden liegen. Dies kann von der verwendeten Laufzeit (oder Sprache), der Größe der Funktion (als Bündel) und natürlich vom jeweiligen Cloud-Anbieter abhängen. Kaltstarts haben sich im Laufe der Jahre drastisch verbessert, da Cloud-Anbieter besser darin geworden sind die Latenzzeiten zu optimieren.

Neben der Optimierung Ihrer Funktionen können Sie einfache Tricks verwenden, wie z.B. eine Funktion, die regelmäßig ausgeführt wird, um sie warm zu halten. [Das Serverless Framework](https://serverless.com), das wir in diesem Tutorial verwenden werden, enthält einige Plugins, [mit denen du deine Funktionen warmhalten kannst](https://github.com/FidelLimited/serverless-plugin-warmup).

Nun, da wir eine gute Vorstellung von Serverless Computing haben, wollen wir uns genauer ansehen, was eine Lambda-Funktion ist und wie ihr Code ausgeführt wird.
