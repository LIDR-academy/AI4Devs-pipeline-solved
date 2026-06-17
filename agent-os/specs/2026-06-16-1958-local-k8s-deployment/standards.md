# Standards for Local Kubernetes Deployment

The following standards apply to this work.

---

## frontend/api-configuration

# API Endpoint Configuration

Ensure backend API base URLs are configurable and not hardcoded inside component or service source files.

## Guidelines

- **Environment Variables**:
  - Retrieve the backend API base URL from the `REACT_APP_API_URL` environment variable.
- **Fallback URL**:
  - If the environment variable is not defined, default / fallback to `http://localhost:3010` during local development.
- **No Hardcoded URLs**:
  - Never hardcode the host (`localhost`, IPs, or production domains) directly inside services or components.
  
### Code Example

**Bad**:
```javascript
const response = await axios.post('http://localhost:3010/candidates', data);
```

**Good**:
```javascript
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3010';

const response = await axios.post(`${API_BASE_URL}/candidates`, data);
```

---

## cicd/secrets-security

# CI/CD Secrets & Security

Ensure sensitive credentials, private keys, and API tokens are handled securely without any exposure in logs or code repositories.

## Guidelines

- **No Logging of Sensitive Data**:
  - Never print, echo, or log secrets, private keys, or certificates in build logs (e.g., avoid command patterns like `cat private_key.pem` or `echo $SECRET`).
- **Secrets Management**:
  - Store all credentials (AWS keys, SSH keys, server IPs) in GitHub Secrets.
  - Inject them as environment variables or parameters only when needed by specific steps.
- **SSH Key Handling**:
  - Use standard SSH authentication actions (such as `webfactory/ssh-agent`) to manage SSH keys in memory, rather than writing private keys to files manually and altering file permissions.
  
### Code Example

**Bad (Leaking Key in Logs)**:
```yaml
- name: Deploy
  run: |
    echo "${{ secrets.SSH_KEY }}" > key.pem
    cat key.pem # DANGER: prints private key to public logs!
    ssh -i key.pem user@host "command"
```

**Good (Using ssh-agent)**:
```yaml
- name: Set up SSH Agent
  uses: webfactory/ssh-agent@v0.5.4
  with:
    ssh-private-key: ${{ secrets.EC2_SSH_PRIVATE_KEY }}

- name: Deploy
  run: |
    ssh -o StrictHostKeyChecking=no ec2-user@${{ secrets.EC2_INSTANCE }} "command"
```

---

## cicd/local-testing

# Local CI/CD Testing with act

Run GitHub Actions workflows locally using `act` to validate and debug pipeline changes before pushing commits to GitHub.

## Guidelines

- **Dry-Run Validation**:
  - Run `act -n` to validate the syntax and step structure of the workflow without launching Docker containers.
- **Running Specific Jobs**:
  - Target specific jobs (such as `build`) using the `-j` flag (e.g. `act -j build`) to test code compilation, dependencies, and unit testing locally without executing deployment jobs.
- **Apple Silicon Compatibility**:
  - On Apple Silicon (M-series) Macs, **always** include the `--container-architecture linux/amd64` flag to prevent image compatibility and resolution failures.
- **Handling Mock Secrets**:
  - Store mock environment secrets in a `.secrets` file located at the project root.
  - **Security Rule**: The `.secrets` file **must** be added to your `.gitignore` file to ensure it is never committed to git.
  - Run jobs requiring secrets using the `--secret-file` flag.

### Command Examples

**Run Build Job on Apple Silicon**:
```bash
act -j build --container-architecture linux/amd64
```

**Run Deploy Job with Mock Secrets**:
```bash
act -j deploy --secret-file .secrets --container-architecture linux/amd64
```
