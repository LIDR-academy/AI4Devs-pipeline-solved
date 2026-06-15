# Master Plan - CI/CD Pipeline con AWS EC2

## Objetivo
Pipeline en GitHub Actions que al hacer push a una rama con PR abierto hacia main:
1. Ejecute tests de backend
2. Genere build del backend
3. Despliegue el backend en EC2

---

## Checklist General

### 1. Infraestructura AWS
- [ ] Cuenta AWS activa
- [ ] Instancia EC2 creada (Ubuntu 24.04 LTS, t2.micro)
- [ ] Security Group configurado (puertos 22, 80, 443, 8080)
- [ ] Key Pair (.pem) generado y descargado
- [ ] Bucket S3 creado: `mi-ec2-con-github-actions`
- [ ] IAM User creado con permisos S3
- [ ] Elastic IP asignada (recomendado)

### 2. Configuración EC2
- [ ] Node.js 20 LTS instalado
- [ ] PM2 instalado globalmente
- [ ] AWS CLI configurado
- [ ] Directorio `/app/backend` creado
- [ ] PostgreSQL accesible (Docker o RDS)
- [ ] Variables de entorno (.env) configuradas (DB_PASSWORD, DB_USER, DB_NAME, DB_PORT)
- [ ] Nginx configurado como reverse proxy (80 → 8080)

### 3. GitHub Repository
- [ ] Secret `AWS_ACCESS_ID` configurado
- [ ] Secret `AWS_ACCESS_KEY` configurado
- [ ] Secret `EC2_INSTANCE` configurado (IP pública)
- [ ] Secret `EC2_SSH_PRIVATE_KEY` configurado (contenido .pem)
- [ ] Pipeline en `.github/workflows/pipeline.yml` válido

### 4. Pipeline (3 Jobs)
- [ ] **test**: Instala deps, ejecuta `npm test`
- [ ] **build**: Compila TypeScript, sube artefactos a S3
- [ ] **deploy**: SSH a EC2, sync S3, instala deps, migra DB, reinicia app
- [ ] Health check post-deploy funcional

### 5. Código
- [ ] No hay secrets hardcodeados
- [ ] Tests pasan localmente
- [ ] Build compila sin errores
- [ ] `.env` en `.gitignore`

---

## Paso a Paso: Crear Instancia EC2 y Obtener Keys

### Paso 1: Crear Key Pair

1. AWS Console → **EC2 → Key Pairs → Create key pair**
2. Name: `ai4devs-pipeline-key`, Type: RSA, Format: `.pem`
3. Se descarga automáticamente
4. Terminal local:
   ```bash
   chmod 400 ai4devs-pipeline-key.pem
   ```

### Paso 2: Crear Security Group

Al lanzar la instancia, AWS crea automáticamente `launch-wizard-1`. Selecciona:
- ✅ SSH desde cualquier lugar (0.0.0.0/0)
- ✅ HTTP desde Internet
- ✅ HTTPS desde Internet

Después de crear la instancia, edita el security group y agrega:

| Type | Port | Source | Descripción |
|------|------|--------|-------------|
| SSH | 22 | 0.0.0.0/0 | Acceso SSH para deploy |
| HTTP | 80 | 0.0.0.0/0 | Nginx reverse proxy |
| HTTPS | 443 | 0.0.0.0/0 | Tráfico seguro |
| Custom TCP | 8080 | 0.0.0.0/0 | Backend Node.js (directo) |

### Paso 3: Lanzar EC2

1. EC2 → **Launch instance**
2. AMI: Ubuntu Server 24.04 LTS (Free tier eligible)
3. Type: `t2.micro`
4. Key pair: `ai4devs-pipeline-key` (crear en el wizard si no existe)
5. Security group: `launch-wizard-1` (con SSH, HTTP, HTTPS habilitados)
6. Storage: 20 GB gp3
7. Anotar **Public IPv4**

### Paso 4: Configurar EC2

```bash
ssh -i ai4devs-pipeline-key.pem ubuntu@<IP>

# Instalar dependencias
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs nginx
sudo npm install -g pm2

# Crear directorio app
sudo mkdir -p /app/backend
sudo chown ubuntu:ubuntu /app/backend
```

### Paso 5: Crear IAM User

1. IAM → **Users → Create**: `github-actions-deployer`
2. Policy: `AmazonS3FullAccess`
3. Security credentials → **Create access key**
4. Guardar Access Key ID y Secret Access Key

### Paso 6: Crear Bucket S3

```bash
aws s3 mb s3://mi-ec2-con-github-actions --region us-east-2
```

### Paso 7: Configurar GitHub Secrets

Repo → Settings → **Secrets and variables → Actions**:

| Secret | Valor |
|--------|-------|
| `AWS_ACCESS_ID` | Access Key ID |
| `AWS_ACCESS_KEY` | Secret Access Key |
| `EC2_INSTANCE` | IP pública EC2 |
| `EC2_SSH_PRIVATE_KEY` | Contenido completo del .pem |

### Paso 8: Verificar

1. Crear rama feature, hacer push
2. Abrir PR hacia `main`
3. El pipeline se ejecuta automáticamente
4. Verificar los 3 jobs: test → build → deploy
5. Confirmar app respondiendo en `http://<IP>:8080` (directo) o `http://<IP>` (via Nginx)

---

## Estructura del Pipeline

```
push a rama con PR abierto
       │
       ▼
┌─────────────┐
│  Job: test  │  npm ci → npm test
└──────┬──────┘
       │ needs: test
       ▼
┌─────────────┐
│ Job: build  │  npm ci → tsc → s3 sync
└──────┬──────┘
       │ needs: build
       ▼
┌─────────────┐
│ Job: deploy │  SSH → s3 sync → npm ci → prisma migrate → pm2 restart
└─────────────┘
```
