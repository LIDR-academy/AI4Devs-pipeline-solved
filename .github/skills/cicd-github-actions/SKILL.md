# CI/CD GitHub Actions Skill

## Description
Creates and maintains GitHub Actions workflows for CI/CD pipelines.

## When to Use
- User asks to create or modify a GitHub Actions workflow
- User asks about pipeline configuration
- User wants to add jobs, steps, or triggers to workflows
- User mentions CI/CD, continuous integration, or continuous deployment

## Instructions

### Context Gathering
1. Read `.github/workflows/pipeline.yml` for current pipeline config
2. Read `backend/package.json` for available scripts
3. Read `docker-compose.yml` for service definitions
4. Check `tf/main.tf` for infrastructure context

### GitHub Actions Best Practices
- Use specific action versions (e.g., `actions/checkout@v4` not `@latest`)
- Cache dependencies with `actions/cache` or setup action cache options
- Use `needs:` for job dependencies
- Never hardcode secrets — use `${{ secrets.NAME }}`
- Use environments for deployment approvals
- Add concurrency groups to prevent duplicate runs
- Use matrix strategies for multi-version testing

### Workflow Template
```yaml
name: Pipeline Name
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      - run: cd backend && npm ci
      - run: cd backend && npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/checkout@v4
      # deployment steps
```

### Validation
- Verify YAML syntax is valid
- Ensure all referenced secrets exist (document required secrets)
- Test workflow logic with `act` tool if available
