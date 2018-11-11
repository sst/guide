---
layout: post
title: Was ist Serverless?
date: 2016-12-23 12:00:00
lang: de
ref: what-is-serverless
description: Serverlos bezieht sich auf Anwendungen, bei denen die Verwaltung und Zuordnung von Servern und Ressourcen vollständig vom Cloud-Anbieter verwaltet wird. Die Abrechnung basiert auf dem tatsächlichen Verbrauch dieser Ressourcen.
comments_id: what-is-serverless/27
---

Traditionell haben wir Webanwendungen entwickelt und bereitgestellt, bei denen wir die HTTP-Anforderungen, die an unseren Server gesendet werden, in gewissem Umfang kontrollieren können. Unsere Anwendung läuft auf diesem Server und wir sind für die Bereitstellung und Verwaltung der Ressourcen dafür verantwortlich. Hier gibt es einige Probleme.

1. Das Aufrechterhalten des Servers ist selbst dann kostenpflichtig, wenn wir keine Anfragen versenden.

2. Wir sind für die Verfügbarkeit und Wartung des Servers und aller seiner Ressourcen verantwortlich.

3. Wir sind auch dafür verantwortlich, die entsprechenden Sicherheitsupdates auf den Server anzuwenden.

4. Als unsere Nutzungsskalen müssen wir auch die Server-Skalierung verwalten. Wenn Sie also nicht so viel verwenden, können Sie die Skalierung reduzieren.

Für kleinere Unternehmen und einzelne Entwickler kann dies eine Menge sein. Dies lenkt am Ende von der wichtigeren Arbeit ab, die wir haben. Aufbau und Pflege der eigentlichen Anwendung. In größeren Organisationen wird dies vom Infrastrukturteam erledigt, und normalerweise liegt es nicht in der Verantwortung des einzelnen Entwicklers. Die dazu erforderlichen Prozesse können jedoch die Entwicklungszeiten verlangsamen. Sie können Ihre Anwendung nicht einfach weiterentwickeln, ohne mit dem Infrastruktur-Team zusammenzuarbeiten, um Sie bei der Inbetriebnahme zu unterstützen. Als Entwickler haben wir nach einer Lösung für diese Probleme gesucht, und hier setzt serverlos an.

### Serverless Computing

Serverless Computing (kurz Serverless Computing) ist ein Ausführungsmodell, bei dem der Cloud-Anbieter (AWS, Azure oder Google Cloud) für die Ausführung eines Codes verantwortlich ist, indem er die Ressourcen dynamisch zuweist. Und nur für die Menge an Ressourcen, die zur Ausführung des Codes verwendet werden. Der Code wird normalerweise in stateless Containern ausgeführt, die durch eine Vielzahl von Ereignissen ausgelöst werden können, z. B. HTTP-Anforderungen, Datenbankereignisse, Warteschlangendienste, Überwachungsalarme, Dateiuploads, geplante Ereignisse (Cron-Jobs) usw. Der Code, der an die Cloud gesendet wird Anbieter für die Ausführung ist in der Regel in Form einer Funktion. Serverlos wird daher manchmal als _"Funktionen als Dienst"_ oder _"FaaS"_ bezeichnet. Nachfolgend die FaaS-Angebote der großen Cloud-Anbieter:

- AWS: [AWS Lambda](https://aws.amazon.com/lambda/)
- Microsoft Azure: [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)
- Google Cloud: [Cloud Functions](https://cloud.google.com/functions/)

Während serverlos die zugrunde liegende Infrastruktur vom Entwickler abstrahiert, sind Server immer noch an der Ausführung unserer Funktionen beteiligt.

Da Ihr Code als einzelne Funktionen ausgeführt wird, müssen wir einige Dinge beachten.

### Microservices

Die größte Änderung, der wir uns beim Übergang in eine Server-freie Welt gegenübersehen, besteht darin, dass unsere Anwendung in Form von Funktionen gestaltet werden muss. Sie können es gewohnt sein, Ihre Anwendung als einzelne Rails- oder Express-Monolith-App bereitzustellen. In der Welt ohne Server ist es jedoch normalerweise erforderlich, eine auf Microservice basierende Architektur zu implementieren. Sie können dies umgehen, indem Sie Ihre gesamte Anwendung in einer einzigen Funktion als Monolith ausführen und das Routing selbst übernehmen. Dies wird jedoch nicht empfohlen, da es besser ist, die Größe Ihrer Funktionen zu reduzieren. Wir werden weiter unten darüber sprechen.

### Zustandslose Funktionen

Ihre Funktionen werden normalerweise in sicheren (fast) zustandslosen Containern ausgeführt. Dies bedeutet, dass Sie in Ihrem Anwendungsserver keinen Code ausführen können, der lange ausgeführt wird, nachdem ein Ereignis abgeschlossen wurde oder einen vorherigen Ausführungskontext für die Bearbeitung einer Anforderung verwendet. Sie müssen effektiv davon ausgehen, dass Ihre Funktion jedes Mal neu aufgerufen wird.

Dazu gibt es einige Feinheiten und wir werden im [Kapitel Was ist AWS Lambda]({% link _chapters/what-is-aws-lambda.md %}) beschrieben.

### Kaltstart

Da Ihre Funktionen in einem Container ausgeführt werden, der bei Bedarf aufgerufen wird, um auf ein Ereignis zu reagieren, besteht eine gewisse Latenz. Dies wird als _Cold Start_ bezeichnet. Ihr Container wird möglicherweise eine Weile in der Umgebung aufbewahrt, nachdem die Ausführung der Funktion abgeschlossen ist. Wenn während dieser Zeit ein anderes Ereignis ausgelöst wird, reagiert es viel schneller und dies wird normalerweise als _Warm Start_ bezeichnet.

Die Dauer des Kaltstarts hängt von der Implementierung des jeweiligen Cloud-Anbieters ab. Bei AWS Lambda kann es zwischen einigen hundert Millisekunden und einigen Sekunden liegen. Dies kann von der verwendeten Laufzeit (oder Sprache), der Größe der Funktion (als Paket) und natürlich vom jeweiligen Cloud-Anbieter abhängen. Der Kaltstart hat sich im Laufe der Jahre drastisch verbessert, da Cloud-Anbieter die Optimierung der Latenzzeiten deutlich verbessert haben.

Neben der Optimierung Ihrer Funktionen können Sie einfache Tricks wie eine separate geplante Funktion verwenden, um Ihre Funktion alle paar Minuten aufzurufen, um sie warm zu halten. [Das Serverless Framework](https://serverless.com), das wir in diesem Tutorial verwenden werden, enthält einige Plugins, [mit denen Sie Ihre Funktionen warmhalten können](https://github.com/FidelLimited/serverless-plugin-warmup).

Nun, da wir eine gute Vorstellung von Serverless Computing haben, wollen wir uns genauer ansehen, was eine Lambda-Funktion ist und wie Ihr Code ausgeführt wird.
