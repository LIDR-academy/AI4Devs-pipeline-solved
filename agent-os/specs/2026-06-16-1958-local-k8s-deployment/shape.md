# Local Kubernetes Deployment on Kind — Shaping Notes

## Scope

Deploy the frontend, backend, and PostgreSQL database to a local Kind Kubernetes cluster, ensuring that the backend and frontend are fully operational and accessible via localhost.

## Decisions

- **Scratch Build**: Dockerfiles and Kubernetes manifests will be written from scratch rather than copied.
- **Port Mapping**: 
  - Backend exposed on `3010:8080` (container port `8080` map to service port `3010`) to accommodate the frontend's hardcoded calls to `http://localhost:3010`.
  - Frontend exposed on `4000:80` to match the backend CORS setting which allows origins from `http://localhost:4000`.
- **Database Engine**: PostgreSQL, initialized and populated using Prisma CLI (`npx prisma db push`).

## Context

- **Visuals**: None.
- **References**: None (constructed from scratch).
- **Product alignment**: Aligns with React frontend, Node Express backend, and PostgreSQL database stack.

## Standards Applied

- **frontend/api-configuration**: Configurable endpoint management.
- **cicd/secrets-security**: Securing database passwords and access details.
- **cicd/local-testing**: Executing and validating deployments locally.
