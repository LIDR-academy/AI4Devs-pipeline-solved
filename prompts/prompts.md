**gpt-5-mini**
**Prompt 1**

Eres un Senior DevSecOps Engineer y se te ha solicitado realizar un pipeline de CI/CD para la compañía. La estructura del pipeline debe seguir las siguientes especificaciones:

Utiliza un archivo YAML para definir el pipeline de GitHub Actions.

El pipeline debe ejecutarse cuando haya un pull_request en la rama main.

Define un job llamado build.

Agrega los siguientes pasos dentro del job build:

- Instalación de dependencias del backend y frontend dentro de sus carpetas utilizando npm install.
- Ejecución de tests del backend dentro de la carpeta backend utilizando npm test.
- Build del backend y frontend utilizando npm run build.
- Ejecución de migraciones con Prisma dentro de la carpeta backend utilizando npx prisma migrate deploy.
- Instalación de Docker en el entorno, asegurándose de que Docker esté listo para ser usado.
- Instalación de Docker Compose en el entorno.
- Levantamiento de servicios de la base de datos con Docker Compose utilizando docker-compose up -d.
- Ejecucion de frontend y backend.
- Ejecución de tests de Cypress.

Define un job llamado deploy que dependa del job build y que se ejecute solo si el evento es un pull_request.
Dentro del job deploy, incluye los siguientes pasos:

- Configuración de credenciales de AWS utilizando las variables de entorno AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, y AWS_REGION.
- Subir el backend a S3 utilizando aws s3 cp para copiar el contenido de la carpeta backend al bucket S3.

- Desplegar el backend en una instancia EC2:
  - Utiliza SSH para conectarte a la instancia EC2.
  - Descarga el código del backend desde S3, instala dependencias, realiza el build y levanta la aplicación.

** Prompt 2**
Puedes hacer los siguientes cambios basado en buenas practicas?

- Configura Nginx como proxy inverso para el backend que esta corriendo en el puerto 8080 y disponibilizalo en el puerto 80.
- Ejecuta en segundo plano el backend ya que esta quedandose corriendo indefinidamente.
- Los tests estan fallando, debes esperar a que la base de datos, frontend y backend estén listos para que Cypress pueda ejecutar los test.
