# Local Kubernetes Deployment on Kind

Deploy the frontend, backend, and database to a local Kubernetes cluster using Kind and verify it via localhost port-forwarding.

## Proposed Changes

### Spec Documentation
- Save spec documentation to `agent-os/specs/2026-06-16-1958-local-k8s-deployment/`

### Backend Dockerization
- Create `backend/Dockerfile` (TypeScript Node app)

### Frontend Dockerization
- Create `frontend/Dockerfile` (React static build served via Nginx)

### Kubernetes Manifests
- Create `k8s/db.yaml` (PostgreSQL Deployment + Service)
- Create `k8s/backend.yaml` (Express Deployment + Service on 3010 -> 8080)
- Create `k8s/frontend.yaml` (React Deployment + Service on 80)

---

## Verification Plan

### Automated Tests
- Run `kubectl get pods` and check for `Running` status.

### Manual Verification
1. Create a Kind cluster: `kind create cluster --name local-k8s`
2. Build Docker images:
   - `docker build -t backend:latest ./backend`
   - `docker build -t frontend:latest ./frontend`
3. Load images into Kind:
   - `kind load docker-image backend:latest --name local-k8s`
   - `kind load docker-image frontend:latest --name local-k8s`
4. Apply the Kubernetes manifests: `kubectl apply -f k8s/`
5. Run database migrations: `kubectl exec -it <backend-pod-name> -- npx prisma db push`
6. Start port-forwarding:
   - `kubectl port-forward svc/backend 3010:8080`
   - `kubectl port-forward svc/frontend 4000:80`
7. Verify access to frontend at `http://localhost:4000`.
