### Prompts usados para generar el pipeline (pasos principales)

1) Prompt para los tests de backend

```
Eres un Senior DevOps Engineer. Crea un paso en un workflow de GitHub Actions que instale dependencias en la carpeta `backend` y ejecute los tests de backend usando `npm test`. El job debe usar `actions/checkout` y `actions/setup-node@v2` con Node 16. Incluye cache de npm si es posible. El paso debe fallar si los tests fallan.
```

2) Prompt para la generación del build del backend

```
Eres un Senior DevOps Engineer. Añade un paso al workflow que construya el backend usando `npm run build` en la carpeta `backend` y que prepare los artefactos de salida (`dist/`). Asegúrate de ejecutar `npm install` antes de `npm run build`.
```

3) Prompt para el despliegue en EC2

```
Eres un Senior DevOps Engineer. Crea un job de despliegue que, tras pasar el job de build, suba el contenido de `backend/` a un bucket S3 y luego haga SSH a una instancia EC2 para descargar desde S3, instalar dependencias, ejecutar `npm run build` y arrancar la aplicación con `pm2`. Usa secretos de GitHub para las credenciales AWS (`AWS_ACCESS_ID`, `AWS_ACCESS_KEY`) y para la clave SSH (`EC2_SSH_PRIVATE_KEY`) y la dirección de la instancia (`EC2_INSTANCE`). No imprimas la clave privada en los logs. Parametriza el bucket S3 mediante la variable `S3_BUCKET`. Maneja el caso donde la AMI puede ser Amazon Linux o Ubuntu (comprueba `apt`/`yum`).
```

Notas:
- No imprimir claves privadas en logs.
- Documentar en el README los secretos necesarios: `AWS_ACCESS_ID`, `AWS_ACCESS_KEY`, `EC2_SSH_PRIVATE_KEY`, `EC2_INSTANCE`, `S3_BUCKET`, `AWS_REGION`.
