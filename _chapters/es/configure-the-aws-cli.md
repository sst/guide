---
layout: post
title: Configurar AWS CLI
date: 2019-01-11 13:40:00
lang: es
ref: configure-the-aws-cli
description: Para interactuar con AWS utilizando la línea de comandos, necesitamos instalar la interfaz de línea de comandos de AWS (o AWS CLI). También debe configurarse con nuestra clave de acceso de usuario IAM y clave de acceso secreto desde la consola de AWS.
context: true
comments_id: configure-the-aws-cli/86
---

Para facilitar el trabajo con muchos de los servicios de AWS, usaremos [CLI de AWS](https://aws.amazon.com/cli/).

### Instalar la CLI de AWS

AWS CLI necesita Python 2 versión 2.6.5+ o Python 3 versión 3.3+ y [Pip](https://pypi.python.org/pypi/pip). Usa lo siguiente si necesitas ayuda para instalar Python o Pip.

- [Instalar Python](https://www.python.org/downloads/)
- [Instalar Pip](https://pip.pypa.io/en/stable/installing/)

<img class="code-marker" src="/assets/s.png" />Ahora utilizando Pip puedes instalar la CLI de AWS (en Linux, macOS o Unix) ejecutando:

``` bash
$ sudo pip install awscli
```

O usando [Homebrew](https://brew.sh) en macOS:

``` bash
$ brew install awscli
```

Si tienes problemas para instalar la CLI de AWS o necesitas instrucciones de instalación en Windows, consulta las [instrucciones de instalación completas](http://docs.aws.amazon.com/cli/latest/userguide/installing.html).

### Agregua tu clave de acceso a AWS CLI

Ahora debemos decirle a AWS CLI que use las claves de acceso del capítulo anterior.

Debería verse algo como esto:

- ID de clave de acceso **AKIAIOSFODNN7EXAMPLE**
- Clave de acceso secreta **wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY**

<img class="code-marker" src="/assets/s.png" />Simplemente ejecuta lo siguiente con tu ID de clave secreta y tu clave de acceso.

``` bash
$ aws configure
```

Puedes dejar el **Nombre de región predeterminado** y **Formato de salida predeterminado** tal como están.

A continuación, comencemos con la configuración de nuestro backend.
