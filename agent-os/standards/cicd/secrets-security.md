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
