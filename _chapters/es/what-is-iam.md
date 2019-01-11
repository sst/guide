---
layout: post
title: ¿Qué es IAM?
date: 2019-01-08 20:40:00
lang: es
ref: what-is-iam
description: AWS Identity and Access Management (o IAM) es un servicio que te ayuda a controlar de manera segura el acceso a los recursos de AWS. Puedes crear usuarios de IAM y aplicarles políticas de IAM. Una política de IAM es una regla o conjunto de reglas que definen las operaciones permitidas / denegadas para realizarse en un recurso. Una función de IAM es muy similar a la de un usuario de IAM, ya que es una identidad con permisos, pero a diferencia de un usuario, no tiene credenciales relacionadas. En contraste, cualquier usuario o recurso que necesite temporalmente esos permisos puede asumir un rol de IAM.
context: true
comments_id: what-is-iam/23
---

En el último capítulo, creamos un usuario de IAM para que nuestra CLI de AWS pueda operar en nuestra cuenta sin usar la Consola de AWS. Pero el concepto de IAM se utiliza con mucha frecuencia cuando se trata de la seguridad de los servicios de AWS, por lo que vale la pena entenderlo con más detalle. Desafortunadamente, IAM se compone de muchas partes diferentes y puede ser muy confuso para las personas que lo conocen por primera vez. En este capítulo vamos a echar un vistazo a IAM y sus conceptos con un poco más de detalle.

Vamos a empezar con la definición oficial de IAM.

> AWS Identity and Access Management (IAM) es un servicio web que ayuda a controlar de forma segura el acceso a los recursos de AWS para tus usuarios. Utiliza IAM para controlar quién puede usar tus recursos de AWS (autenticación) y qué recursos pueden usar y de qué manera (autorización).

Lo primero que hay que notar aquí es que IAM es un servicio al igual que todos los otros servicios que tiene AWS. Pero de alguna manera ayuda a reunirlos a todos de una forma segura. IAM se compone de algunas partes diferentes, así que comencemos mirando la primera y la más básica.

### ¿Qué es un usuario de IAM?

Cuando creas una cuenta de AWS por primera vez, tu eres el usuario Raíz. La dirección de correo electrónico y la contraseña que utilizaste para crear la cuenta se denominan credenciales de la cuenta Raíz. Puedes utilizarlos para iniciar sesión en la Consola de administración de AWS. Cuando lo hagas, tendrás acceso completo y sin restricciones a todos los recursos en tu cuenta de AWS, incluido el acceso a tu información de facturación y la posibilidad de cambiar tu contraseña.

![Diagrama de usuario Raíz de IAM](/assets/es/iam/iam-root-user.png)

Aunque no es una buena práctica acceder regularmente a tu cuenta con este nivel de acceso, no es un problema cuando eres la única persona que trabaja en tu cuenta. Sin embargo, cuando otra persona necesita acceder y administrar tu cuenta de AWS, definitivamente no querrás dar tus credenciales Raíz. En su lugar, creas un usuario IAM.

Un usuario de IAM consta de un nombre, una contraseña para iniciar sesión en la Consola de administración de AWS y hasta dos claves de acceso que se pueden usar con la API o la CLI.

![Diagrama de usuario de IAM](/assets/es/iam/iam-user.png)

Por defecto, los usuarios no pueden acceder a nada en tu cuenta. Para otorgar permisos a un usuario, debes crear una política y adjuntarla al usuario. Puedes otorgar una o más de estas políticas para restringir lo que el usuario puede y no puede acceder.

### ¿Qué es una política de IAM?

Una política de IAM es una regla o un conjunto de reglas que definen las operaciones permitidas / denegadas para realizarse en un recurso de AWS.

Las políticas pueden ser otorgadas de varias maneras:

- Adjuntando una *política gestionada*. AWS proporciona una lista de políticas predefinidas como *AmazonS3ReadOnlyAccess*.
- Adjuntando una *política en línea*. Una política en línea es una política personalizada creada a mano.
- Agregando al usuario a un grupo que tenga las políticas de permisos apropiadas adjuntas. Veremos los grupos en detalle a continuación.
- Clonando el permiso de un usuario IAM existente.

![Diagrama de política de IAM](/assets/es/iam/iam-policy.png)

Como ejemplo, aquí hay una política que otorga todas las operaciones a todos los buckets de S3.

``` json
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "s3:*",
    "Resource": "*"
  }
}
```

Y aquí hay una política que otorga un acceso más granular, y sólo permite la recuperación de archivos con el prefijo de la cadena `Bobs-` en el grupo llamado `Hello-bucket`.

``` json
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": ["s3:GetObject"],
    "Resource": "arn:aws:s3:::Hello-bucket/*",
    "Condition": {"StringEquals": {"s3:prefix": "Bobs-"}}
}
```

Estamos usando recursos S3 en los ejemplos anteriores. Pero una política es similar para cualquiera de los servicios de AWS. Solo depende del recurso ARN para la propiedad `Resource`. Un ARN es un identificador para un recurso en AWS y lo veremos con más detalle en el siguiente capítulo. También agregamos las acciones de servicio y las claves de contexto de condición correspondientes en las propiedades `Action` y `Condition`. Puedes encontrar todas las acciones de AWS Service y las claves de contexto de condición para usar en Políticas IAM [aquí](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_actionsconditions.html). Además de adjuntar una política a un usuario, puedes adjuntarla a un rol o grupo.

### ¿Qué es un rol de IAM?

A veces, tus recursos de AWS necesitan acceder a otros recursos en tu cuenta. Por ejemplo, tienes una función Lambda que consulta tu DynamoDB para recuperar algunos datos, procesarlos y luego enviarlos a Bob en un correo electrónico con los resultados. En este caso, queremos que Lambda sólo pueda realizar consultas de lectura para que no cambie la base de datos por error. También queremos restringir a Lambda para que pueda enviarle un correo electrónico a Bob y no a un correo de otra persona. Si bien esto podría hacerse creando un usuario IAM y colocando las credenciales del usuario en la función Lambda o incrustando las credenciales en el código Lambda, esto no es seguro. Si alguien fuera a obtener estas credenciales, podría hacer esas llamadas en tu nombre. Aquí es donde entra en juego el rol de IAM.

Un rol de IAM es muy similar a un usuario, ya que es una *identidad* con políticas de permisos que determinan lo que la identidad puede y no puede hacer en AWS. Sin embargo, un rol no tiene credenciales (contraseña o claves de acceso) asociadas. En lugar de estar asociado de manera única con una persona, cualquier persona que lo necesite puede asumir un rol. En este caso, a la función Lambda se le asignará un rol para que tome temporalmente el permiso.

![Diagrama de servicio de AWS con rol de IAM](/assets/es/iam/service-as-iam-role.png)

Los roles también se pueden aplicar a los usuarios. En este caso, el usuario está tomando el conjunto de políticas para el rol de IAM. Esto es útil para los casos en que un usuario usa varios "sombreros" en la organización. Los roles lo facilitan, ya que solo necesitas crear estos roles una vez y se pueden reutilizar para cualquier persona que quiera asumirlos.

![Diagrama de usuario de IAM con rol de IAM](/assets/es/iam/iam-user-as-iam-role.png)

También puedes tener un rol vinculado a la ARN de un usuario de una organización diferente. Esto permite que el usuario externo asuma ese rol como parte de tu organización. Normalmente se usa cuando tienes un servicio de un tercero que actúa en tu Organización de AWS. Se te pedirá que crees una función IAM entre cuentas y que agregues al usuario externo como una *Relación de confianza*. La *Relación de confianza* le dice a AWS que el usuario externo especificado puede asumir este rol.

![Diagrama de usuario externo de IAM con rol de IAM](/assets/es/iam/external-user-with-iam-role.png)

### ¿Qué es un grupo de IAM?

Un grupo de IAM es simplemente una colección de usuarios de IAM. Puedes usar grupos para especificar permisos para una colección de usuarios, lo que puede hacer que esos permisos sean más fáciles de administrar para esos usuarios. Por ejemplo, podrías tener un grupo llamado Administradores y darle a ese grupo los tipos de permisos que los administradores normalmente necesitan. Cualquier usuario en ese grupo tiene automáticamente los permisos asignados al grupo. Si un nuevo usuario se une a tu organización y necesita tener privilegios de administrador, puedes asignar los permisos adecuados agregando el usuario a ese grupo. De manera similar, si una persona cambia de trabajo en tu organización, en lugar de editar los permisos de ese usuario, puedes eliminarlo de los grupos anteriores y agregarlo a nuevo grupo apropiado.

![Diagrama completo de grupo, rol, usuario y política de IAM](/assets/es/iam/complete-iam-concepts.png)

Esto debería darte una idea rápida de IAM y algunos de sus conceptos. Nos referiremos a algunos de estos en los próximos capítulos. A continuación, veamos rápidamente otro concepto de AWS: el ARN.
