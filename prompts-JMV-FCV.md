# Conversación sobre Infraestructura como Código AWS con Terraform

## Solicitud del Usuario

Eres un experto DevOps Engineer y necesitamos que crees una infraestructura en la nube de AWS. Tiene que ser de tipo Infrastructure as Code usando terraform para reutilizar. Puedes añadir todo lo que necesites en el archivo @main.tf .

Los requisitos técnicos son los siguientes:

# Cuenta de servicio: Crea una cuenta de servicio que permita a la aplicación interactuar con los recursos de la nube. Esta cuenta debe tener permisos para:
- Crear y gestionar instancias.
- Configurar reglas de seguridad.
- Crear y gestionar buckets s3

# Rol: Asigna un rol a la cuenta de servicio con los permisos necesarios para que la aplicación pueda:
- Acceder a buckets s3 que empiecen port lt.
- Gestionar logs de actividad.

# Instancia: Lanza 2 instancias con las siguientes características:
- Sistema operativo: Ubuntu 22.04.
- Tamaño: Pequeño (small).
- Etiqueta: app=lti-recruiting-(backend/frontend) .

# Security Group: Configura un grupo de seguridad que permita:
- Acceso SSH (puerto 22) solo desde tu IP.
- Acceso HTTP (puerto 80) desde cualquier lugar.

Intenta dividir el código que generes agrupandolo en diferentes archivos por recurso. Si añades comentarios que sean en Inglés.

Además de realizar esto necesito que añadas toda nuestra conversación en un archivo en formato MD con el nombre prompts-JMV-FCV.md

## Respuesta del Asistente

Voy a crear la infraestructura como código usando Terraform según tus requisitos.

He creado los siguientes archivos:

1. `main.tf` - Configuración principal de Terraform y proveedor AWS
2. `variables.tf` - Variables para personalizar la infraestructura
3. `iam.tf` - Configuración de la cuenta de servicio, roles y políticas
4. `security.tf` - Grupo de seguridad con las reglas solicitadas
5. `instances.tf` - Definición de las instancias EC2 para backend y frontend
6. `outputs.tf` - Outputs importantes después del despliegue
7. `prompts-JMV-FCV.md` - Este archivo con nuestra conversación

La infraestructura incluye:
- Una cuenta de servicio (IAM User) con permisos para gestionar instancias EC2, grupos de seguridad y buckets S3
- Un rol con permisos para acceder a buckets S3 que empiecen con "lt" y gestionar logs de CloudWatch
- Dos instancias EC2 con Ubuntu 22.04, tamaño t2.small, etiquetadas como lti-recruiting-backend y lti-recruiting-frontend
- Un grupo de seguridad que permite SSH desde la IP del administrador y HTTP desde cualquier lugar

Para desplegar esta infraestructura, necesitas ejecutar:

```
terraform init
terraform plan
terraform apply
```

Recuerda ajustar el valor de la variable `admin_ip` en `variables.tf` con tu dirección IP real para restringir adecuadamente el acceso SSH. 