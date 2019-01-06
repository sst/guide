---
layout: post
title: Crear un usuario de IAM
date: 2019-01-02 18:00:00
lang: es
ref: create-an-iam-user
description: Para interactuar con AWS utilizando algunas herramientas de línea de comandos, necesitamos crear un usuario de IAM a través de la consola de AWS.
context: true
comments_id: create-an-iam-user/92
---

Amazon IAM (Identity and Access Management) te permite administrar usuarios y permisos de usuario en AWS. Puedes crear uno o más usuarios de IAM en tu cuenta de AWS. Puedes crear un usuario de IAM para alguien que necesite acceder a tu consola de AWS, o cuando tengas una nueva aplicación que necesite hacer llamadas API a AWS. Esto es para agregar una capa adicional de seguridad a tu cuenta de AWS.

En este capítulo, vamos a crear un nuevo usuario de IAM para algunas de las herramientas relacionadas con AWS que usaremos más adelante.

### Crear usuario

Primero, inicia sesión en tu [Consola de AWS](https://console.aws.amazon.com) y selecciona IAM en la lista de servicios.

![Captura: seleccionar el servicio IAM](/assets/es/iam-user/select-iam-service.png)

Selecciona **Usuarios**.

![Captura: seleccionar usuarios de IAM](/assets/es/iam-user/select-iam-users.png)

Selecciona **Añadir usuario(s)**.

![Captura: añadir usuario de IAM](/assets/es/iam-user/add-iam-user.png)

Ingresa un **nombre de usuario** y da clic en **Acceso mediante programación**, luego seleciona **Siguiente: Permisos**.

Esta cuenta será usada por [AWS CLI](https://aws.amazon.com/cli/) y [Serverless Framework](https://serverless.com). Estarán conectados directamente al API de AWS y no usarán la Consola de Administración.

![Captura: llenar información de usuario IAM](/assets/es/iam-user/fill-in-iam-user-info.png)

Selecciona **Añadir directamente las políticas existentes**.

![Captura: añadir políticas de usuario IAM](/assets/es/iam-user/add-iam-user-policy.png)

Busca **AdministratorAccess** y selecciona la política, luego selecciona **Siguiente: Etiquetas**.

Podemos proporcionar una política más detallada aquí y lo cubriremos más adelante en el capitulo [Personalizar la política de Serverless IAM]({% link _chapters/customize-the-serverless-iam-policy.md %}). Pero por ahora, continuemos con esto.

![Captura: política de administración añadida](/assets/es/iam-user/added-admin-policy.png)

Este paso es opcional, aquí puedes agregar las etiquetas que creas necesarias al nuevo usuario de IAM, para organizar, seguir o controlar el acceso de los usuarios, por ejemplo, la etiqueta _Application_ tiene el valor _Serverless Stack Guide_ para saber que este usuario fue creado para esta aplicación específica. Luego selecciona **Siguiente: Revisar**.

![Captura: agregar etiquetas a usuario de IAM](/assets/es/iam-user/add-iam-user-tags.png)

Selecciona **Crear un usuario**.

![Captura: revisar usuario de IAM](/assets/es/iam-user/review-iam-user.png)

Selecciona **Mostrar** para ver la **Clave de acceso secreta**.

![Captura: Usuario de IAM añadido](/assets/es/iam-user/added-iam-user.png)

Toma nota del **ID de clave de acceso** y **Clave de acceso secreta**. Lo necesitaremos más adelante.

![Caputura: credenciales para el usuario de IAM](/assets/es/iam-user/iam-user-credentials.png)

El concepto de IAM aparece con mucha frecuencia cuando se trabaja con los servicios de AWS. Por lo tanto, vale la pena analizar mejor qué es IAM y cómo puede ayudarnos a asegurar nuestra configuración serverless.
