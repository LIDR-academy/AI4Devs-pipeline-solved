# Prompt 1

Como experto en devops y terraform.
Estamos en una clase, y tenemos que resolver un ejercicio. Este ejercicio consiste en cumplir con unos requisitos técnicos usando Terraform que te explicaré a continuación:

Cuenta de servicio: Crea una cuenta de servicio que permita a la aplicación interactuar con los recursos de la nube. Esta cuenta debe tener permisos para:
- Crear y gestionar instancias.
- Configurar reglas de seguridad.
- Crear y gestionar buckets s3

Rol: Asigna un rol a la cuenta de servicio con los permisos necesarios para que la aplicación pueda:
- Acceder a buckets s3 que empiecen por lt.
- Gestionar logs de actividad.

Instancia: Lanza 2 instancias con las siguientes características:
- Sistema operativo: Ubuntu 22.04.
- Tamaño: Pequeño (small).
- Etiqueta: app=lti-recruiting-(backend/frontend) .

Security Group: Configura un grupo de seguridad que permita:
- Acceso SSH (puerto 22) solo desde tu IP.
- Acceso HTTP (puerto 80) desde cualquier lugar.


No tengo idea de Terraform, por lo que hazme todas las preguntas que consideres antes de empezar a escribir nada.
Vamos poco a poco. Primero confirma que sabes lo que hay que hacer, y vayamos construyéndolo paso a paso.

Este es el proyecto sobre el que vamos a trabajar @backend@README.md@package.json@docker-compose.yml . Si necesitas leer más archivos, pídemelo


# Prompt 2

1. Which AWS region should we deploy to?
eu-north-1

2. What's your public IP address for the SSH restriction?
Let's use 180.200.1.200

3. Do you have AWS credentials configured locally?
No, but in github

4. What instance type should we use for "small"? (t2.micro?)
yes, t2.micro

5. Do we need to set up an RDS instance for PostgreSQL, or will you continue using Docker?
yes, continue using docker

# Prompt 3

The AWS secrets are wrong. Read them in @README.md at the end of the document

# Prompt 4

Let's go. Create all the required files