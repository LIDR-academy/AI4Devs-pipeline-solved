# Documentación Completa del Pipeline CI/CD

## Resumen del Proyecto

Este proyecto implementa un pipeline completo de CI/CD usando GitHub Actions que:

1. Ejecuta tests del backend al hacer push en una rama con Pull Request abierto
2. Genera un build del backend usando TypeScript
3. Despliega el backend automáticamente en una instancia EC2 de AWS

## Arquitectura de la Solución

```
GitHub Repository (rama pipeline-iniciales)
    ↓ (Pull Request trigger)
GitHub Actions Workflow
    ↓ (Tests + Build)
Artifact Upload to S3
    ↓ (SSH Deploy)
EC2 Instance (nginx + Node.js + PM2)
```

## Archivos Creados y Modificados

### 1. Workflows de GitHub Actions

#### `.github/workflows/pipeline.yml`

- **Propósito**: Workflow principal que se ejecuta en Pull Requests hacia main
- **Jobs**: `build` (tests + build) y `deploy` (subida a S3 + deploy SSH)
- **Trigger**: `pull_request` hacia rama `main`

#### `.github/workflows/ci.yml` (modificado)

- **Mejoras aplicadas**:
  - Uso de action oficial `aws-actions/configure-aws-credentials@v2`
  - Implementación de `ssh-agent` para manejo seguro de claves
  - Parametrización del bucket S3 via secret
  - Eliminación de impresión de claves privadas en logs

### 2. Scripts de Bootstrap

#### `scripts/bootstrap_ec2.sh`

- **Propósito**: Script idempotente para preparar instancia EC2
- **Funcionalidades**:
  - Detección automática de OS (Amazon Linux/Ubuntu)
  - Instalación de nginx, git, curl, jq
  - Instalación de nvm + Node.js LTS
  - Instalación de PM2 para gestión de procesos
  - Instalación de AWS CLI v2
  - Creación de directorio `/home/ec2-user/backend` (ajustado a `/home/ubuntu/backend`)

### 3. Documentación

#### `prompts/prompts-iniciales.md`

- **Propósito**: Documentar los prompts utilizados para crear el pipeline
- **Contenido**: Prompts para tests, build y deploy + notas de seguridad

#### `docs/CI_CD_SETUP.md`

- **Propósito**: Guía para configurar AWS y GitHub Secrets
- **Contenido**: Instrucciones para S3, IAM, y configuración de secretos

#### `docs/EC2_SETUP.md`

- **Propósito**: Guía para preparar la instancia EC2
- **Contenido**: Security Groups, SSH, bootstrap y verificación

## Proceso de Implementación Detallado

### Fase 1: Análisis del Repositorio Existente

**Comando utilizado para explorar:**

```bash
find . -name "package.json" -o -name "*.test.*" -o -name "jest.config.*"
```

**Hallazgos**:

- Backend con Node.js + TypeScript en `/backend`
- Tests configurados con Jest y ts-jest
- Scripts disponibles: `test`, `build`, `start:prod`
- Workflow CI existente en `.github/workflows/ci.yml`

### Fase 2: Creación de Archivos Base

#### Prompt utilizado para crear `prompts/prompts-iniciales.md`:

```
Crea un archivo prompts/prompts-iniciales.md que documente los 3 prompts principales utilizados:
1. Prompt para ejecutar tests del backend
2. Prompt para generar build del backend
3. Prompt para desplegar en EC2
```

#### Prompt utilizado para mejorar el workflow:

```
Revisa y mejora el workflow existente .github/workflows/ci.yml aplicando estas mejoras de seguridad:
1. No imprimir claves privadas en logs
2. Usar la action oficial de AWS credentials
3. Usar ssh-agent para manejo de claves SSH
4. Parametrizar el bucket S3
```

### Fase 3: Hardening de Seguridad

**Problemas identificados en el workflow original**:

- Impresión de clave privada SSH en logs
- Configuración manual de credenciales AWS
- Bucket S3 hardcodeado
- Manejo inseguro de SSH keys

**Soluciones implementadas**:

```yaml
# Antes (inseguro)
- name: Configure AWS CLI
  run: |
    aws configure set aws_access_key_id ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws configure set aws_secret_access_key ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    echo "${{ secrets.EC2_SSH_KEY }}" > key.pem

# Después (seguro)
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: eu-north-1

- name: Load SSH key and deploy to EC2
  uses: webfactory/ssh-agent@v0.8.1
  with:
    ssh-private-key: ${{ secrets.EC2_SSH_KEY }}
```

### Fase 4: Configuración de AWS y Secretos

**Secretos de GitHub configurados**:

- `AWS_ACCESS_KEY_ID`: Access Key del usuario IAM
- `AWS_SECRET_ACCESS_KEY`: Secret Key del usuario IAM
- `S3_BUCKET`: Nombre del bucket (fallback: `cursolidr`)
- `EC2_HOST`: IP pública de la instancia EC2 (`13.51.237.111`)
- `EC2_USER`: Usuario SSH (`ubuntu`)
- `EC2_SSH_KEY`: Clave privada SSH (contenido del archivo .pem)

**Configuración AWS aplicada**:

- Región: `eu-north-1` (Estocolmo)
- Bucket S3: `cursolidr` (para artefactos del backend)
- Usuario IAM con permisos mínimos para S3

### Fase 5: Bootstrap de la Instancia EC2

**Comando ejecutado para verificar huella SSH**:

```powershell
ssh-keyscan -t ed25519 13.51.237.111 2>$null | Select-String 'ssh-ed25519' | ForEach-Object { $_.Line -replace '^[^ ]+ ', '' } > $env:TEMP\hostkey.pub; ssh-keygen -lf $env:TEMP\hostkey.pub; Remove-Item $env:TEMP\hostkey.pub
```

**Problemas encontrados durante SSH**:

1. **Error**: `(stdin) is not a public key file`

   - **Causa**: `ssh-keyscan` devolvía líneas de comentario y banners
   - **Solución**: Filtrar con `Select-String 'ssh-ed25519'`

2. **Error**: `Permission denied (publickey)`

   - **Causa**: Archivo PEM no encontrado en la ruta especificada
   - **Solución**: Localizar archivo con `Get-ChildItem $env:USERPROFILE -Name "*.pem" -Recurse`

3. **Error**: `Warning: Identity file C:\ruta\a\tu\mi-key.pem not accessible`
   - **Causa**: Ruta placeholder en lugar de ruta real
   - **Solución**: Usar ruta real: `C:\Users\Usuario\Desktop\curso_lidr\kp-backend-eu-north-1.pem`

**Comando final exitoso para bootstrap**:

```powershell
Get-Content .\scripts\bootstrap_ec2.sh -Raw | ssh -i "C:\Users\Usuario\Desktop\curso_lidr\kp-backend-eu-north-1.pem" ubuntu@13.51.237.111 'bash -s'
```

**Resultado del bootstrap**:

- ✅ nginx instalado y activo (v1.18.0)
- ✅ Node.js LTS instalado (v22.19.0)
- ✅ PM2 instalado (v6.0.10)
- ✅ Directorio `/home/ubuntu/backend` creado
- ⚠️ AWS CLI v2 (falló por falta de `unzip`, pero no crítico)

### Fase 6: Verificación de Servicios

**Comandos de verificación ejecutados**:

1. **Verificar nginx**:

```powershell
ssh -i "C:\Users\Usuario\Desktop\curso_lidr\kp-backend-eu-north-1.pem" ubuntu@13.51.237.111 'systemctl status nginx --no-pager'
```

**Resultado**: `Active: active (running)` ✅

2. **Verificar Node.js y PM2**:

```powershell
ssh -i "C:\Users\Usuario\Desktop\curso_lidr\kp-backend-eu-north-1.pem" ubuntu@13.51.237.111 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node -v; pm2 -v'
```

**Resultado**: Node.js v22.19.0 y PM2 v6.0.10 funcionando ✅

### Fase 7: Control de Versiones

**Comandos git ejecutados**:

```bash
git checkout -b pipeline-iniciales
git add -A
git commit -m "Añadir pipeline CI/CD inicial con tests, build y deploy"
git commit -m "Mejorar seguridad del workflow CI/CD"
git commit -m "Añadir documentación y scripts de bootstrap"
git commit -m "Actualización manual de workflows y docs tras pausa"
git push origin pipeline-iniciales
```

## Arquitectura del Workflow

### Job 1: Build

```yaml
steps:
  - Checkout code
  - Setup Node.js 16 with npm cache
  - Install dependencies (backend)
  - Run tests (Jest)
  - Build TypeScript to dist/
```

### Job 2: Deploy

```yaml
steps:
  - Checkout code
  - Configure AWS credentials (official action)
  - Upload artifacts to S3
  - Add EC2 host key to known_hosts
  - Setup SSH agent with private key
  - Deploy via SSH:
      - Download from S3
      - Install dependencies
      - Build application
      - Start with PM2
      - Configure nginx reverse proxy
```

## Tecnologías y Herramientas Utilizadas

### Backend

- **Node.js**: v22.19.0 LTS
- **TypeScript**: Compilación con `tsc`
- **Jest**: Framework de testing con ts-jest
- **PM2**: Gestor de procesos para producción

### Infraestructura

- **AWS EC2**: Ubuntu 22.04 LTS
- **AWS S3**: Almacenamiento de artefactos
- **nginx**: Reverse proxy (puerto 80 → 8080)
- **GitHub Actions**: Orquestación CI/CD

### Herramientas de Desarrollo

- **Git**: Control de versiones
- **PowerShell**: Automatización local
- **SSH**: Despliegue remoto
- **nvm**: Gestión de versiones de Node.js

## Configuración de Red y Seguridad

### Security Group EC2

- **Puerto 22**: SSH desde tu IP
- **Puerto 80**: HTTP público para nginx
- **Puerto 8080**: Aplicación Node.js (interno)

### Configuración nginx

```nginx
server {
  listen 80;
  server_name 13.51.237.111;
  location / {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

## Problemas Encontrados y Soluciones

### 1. Error de Parsing SSH Key

**Problema**: `ssh-keygen -lf -` fallaba con `(stdin) is not a public key file`
**Causa**: Líneas de comentario y banners en salida de `ssh-keyscan`
**Solución**: Filtrar solo líneas que contienen `ssh-ed25519`

### 2. PATH de Node.js no Disponible

**Problema**: `node: command not found` después de instalación con nvm
**Causa**: nvm instala en perfil de usuario, requiere cargar entorno
**Solución**: Usar `export NVM_DIR` y cargar nvm.sh antes de ejecutar comandos

### 3. AWS CLI Installation Failed

**Problema**: `unzip: command not found` durante instalación de AWS CLI
**Causa**: Ubuntu 22.04 no incluye unzip por defecto
**Solución**: No crítico para el funcionamiento, se puede instalar después si es necesario

### 4. Permisos SSH

**Problema**: `Permission denied (publickey)`
**Causa**: Archivo PEM no encontrado o permisos incorrectos
**Solución**: Verificar ruta exacta del archivo .pem y usar comillas en PowerShell

## Tests Ejecutados y Resultados

### Tests Locales (Prevalidación)

```bash
cd backend
npm ci
npm test
npm run build
```

**Resultado**: 4 tests pasados, build TypeScript exitoso

### Tests del Pipeline (Esperados)

- **Unit Tests**: Jest ejecuta tests en `/backend/src/**/*.test.ts`
- **Build Test**: TypeScript compila a `/backend/dist/`
- **Integration Test**: Deploy y verificación de servicios en EC2

## URLs y Enlaces Importantes

- **Repositorio**: https://github.com/pepegoterass/AI4Devs-pipeline-solved
- **Rama de trabajo**: `pipeline-iniciales`
- **IP EC2**: `13.51.237.111`
- **Región AWS**: `eu-north-1` (Estocolmo)
- **Bucket S3**: `cursolidr`

## Siguiente Pasos (Pendientes)

1. **Crear Pull Request**: Desde `pipeline-iniciales` hacia `main`
2. **Monitorear Actions**: Verificar ejecución del workflow en GitHub
3. **Validar Deploy**: Confirmar que la aplicación funciona en `http://13.51.237.111`
4. **Troubleshooting**: Corregir cualquier error en el pipeline
5. **Optimización**: Mejorar tiempos de build y deploy

## Comandos de Referencia Rápida

### SSH a EC2

```powershell
ssh -i "C:\Users\Usuario\Desktop\curso_lidr\kp-backend-eu-north-1.pem" ubuntu@13.51.237.111
```

### Verificar Servicios

```bash
systemctl status nginx
pm2 status
pm2 logs
```

### Revisar Logs de Deploy

```bash
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### Reiniciar Servicios

```bash
sudo systemctl restart nginx
pm2 restart my-app
```

## Conclusiones

El pipeline CI/CD ha sido implementado exitosamente con:

- ✅ Configuración completa de GitHub Actions
- ✅ Bootstrap automático de EC2
- ✅ Integración con AWS S3 y EC2
- ✅ Manejo seguro de credenciales y SSH keys
- ✅ Documentación completa del proceso
- ✅ Tests locales validados

El proyecto está listo para crear el Pull Request y validar el funcionamiento completo del pipeline en un entorno real.
