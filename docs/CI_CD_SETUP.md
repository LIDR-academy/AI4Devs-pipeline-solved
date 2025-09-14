# CI/CD Setup (GitHub Actions -> EC2)

Este documento recoge los pasos para preparar AWS y GitHub para que el workflow `CI/CD Pipeline` funcione correctamente.

Requisitos previos
- Tener AWS CLI configurado localmente (opcional si se hace todo desde consola web).
- Tener permisos para crear buckets S3 e IAM users.

1) Crear bucket S3

Desde AWS CLI (usar `eu-north-1` - Estocolmo en este caso):

```powershell
aws s3 mb s3://cursolidr --region eu-north-1
```

2) Crear usuario IAM con permisos a S3 (policy mínima)

Policy JSON (reemplaza el nombre del bucket):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject","s3:GetObject","s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::mi-backend-artifacts-<tu-nombre>-YYYYMMDD",
        "arn:aws:s3:::mi-backend-artifacts-<tu-nombre>-YYYYMMDD/*"
      ]
    }
  ]
}
```

3) Añadir secretos en GitHub (Settings → Secrets and variables → Actions)

- `AWS_ACCESS_ID` = Access Key ID del usuario IAM
- `AWS_ACCESS_KEY` = Secret Access Key
- `S3_BUCKET` = nombre del bucket S3 a usar (por defecto `cursolidr` si no defines el secreto)
- `EC2_HOST` = IP pública o DNS de la EC2
- `EC2_USER` = usuario SSH en la EC2 (ej.: `ec2-user` o `ubuntu`)
- `EC2_SSH_KEY` = Contenido de tu private key PEM (subir como secreto en GitHub)
- `AWS_REGION` = `us-east-1` (o la que uses)

4) Preparar EC2

- Asegura que el grupo de seguridad permite 22 (SSH), 80 (HTTP) y 8080 (o que Nginx proxy a 8080).
- Añade la clave pública correspondiente a `EC2_SSH_PRIVATE_KEY` en `~/.ssh/authorized_keys` del usuario `ec2-user`.

5) Probar

- Crea PR desde la rama `pipeline-iniciales` hacia `main` en GitHub.
- Monitorea Actions > CI/CD Pipeline. Revisa logs y corrige permisos si algo falla.

Logs y debugging
- Para comprobar archivos subidos a S3:

```powershell
aws s3 ls s3://mi-backend-artifacts-<tu-nombre>-YYYYMMDD/backend/ --recursive
```

- Para probar SSH localmente:

```powershell
ssh -i path\to\private_key.pem ec2-user@EC2_PUBLIC_IP
```
