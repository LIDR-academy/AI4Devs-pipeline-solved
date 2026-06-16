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
