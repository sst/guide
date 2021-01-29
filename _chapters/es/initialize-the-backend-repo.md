---
layout: post
title: Inicializando el repositorio backend
date: 2016-12-29 18:00:00
lang: es
description: Para esta guia vamos a enviar nuestra aplicación Serverless Framework a un repositorio Git. Hacemos esto para, más tarde, poder automatizar nuestros despliegues con tan solo enviarlo (`pushing`) a Git.
code: backend
ref: initialize-the-backend-repo
comments_id: initialize-the-backend-repo/159
---

Antes de comenzar a trabajar en nuestra app, vamos a crear un repositorio Git para este proyecto. Es una gran forma de guardar nuestro código y usaremos este repositorio más tarde para automatizar el proceso de despliegue de nuestra aplicación.

### Creando un nuevo repositorio GitHub

Vayamos a [GitHub](https://github.com). Asegurate que has ingresado y da click en  **Nuevo repositorio** (`**New repository**`).

![Captura de pantalla - Creando un nuevo repositorio GitHub](/assets/part2/create-new-github-repository.png)

Nombra tu repositorio, en nuestro caso lo hemos llamado `serverless-stack-api`. Luego da click en **Crear repositorio** (`**Create repository**`).

![Captura de pantalla - Nombrando el nuevo repositorio GitHub](/assets/part2/name-new-github-repository.png)

Una vez que tu repositorio se ha creado, copia la URL del repositorio. Lo necesitaremos a continuación.

![Captura de pantalla - Copiando la url del repositorio GitHub](/assets/part2/copy-new-github-repo-url.png)

En nuestro caso la URL es:

``` txt
https://github.com/jayair/serverless-stack-api.git
```

### Inicializando tu nuevo repositorio

{%change%} Ahora regresa a tu proyecto y usa el siguiente comando para inicializar tu nuevo repositorio.

``` bash
$ git init
```

{%change%} Agrega los archivos existentes.

``` bash
$ git add .
```

{%change%} Crea tu primer commit.

``` bash
$ git commit -m "Mi primer commit"
```

{%change%} Únelo al repositorio que acabas de crear en GitHub.

``` bash
$ git remote add origin REPO_URL
```

Aquí `REPO_URL` es la URL que copiamos de GitHub en los pasos anteriores. Puedes verificar que ha sido configurado correctamente haciendo lo siguiente.

``` bash
$ git remote -v
```

{%change%} Finalmente, vamos a enviar (`push`) nuestro primer commit a GitHub usando:

``` bash
$ git push -u origin master
```

Ahora estamos listos para construir nuestro backend!
