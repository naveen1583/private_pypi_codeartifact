# Troubleshooting: private-pypi-proxy

## Common Issues

### 401 Unauthorized

- Check that the CodeArtifact token is valid and not expired.
- Ensure the IAM role attached to the server has `codeartifact:GetAuthorizationToken` permissions.
- Confirm the Nginx config is updated with the latest token (see `scripts/update-token.sh`).

### 502 Bad Gateway

- Check network connectivity to AWS CodeArtifact endpoints.
- Ensure VPC endpoints are set up if in a private subnet.
- Verify Nginx is running and the proxy_pass URL is correct.

### SSL Handshake Errors

- Make sure the client trusts the self-signed certificate (`proxy.crt`).
- Check that the certificate matches the DNS name used by clients.

### Token Not Updating

- Check cron logs (`/var/log/token.log`) for errors.
- Ensure `aws` CLI is installed and configured.
- Make sure `scripts/update-token.sh` is executable and paths are correct.

### Nginx Not Reloading

- Check for syntax errors: `sudo nginx -t`
- Review Nginx logs: `/var/log/nginx/error.log`

---

If you encounter other issues, please open an issue or pull request!
