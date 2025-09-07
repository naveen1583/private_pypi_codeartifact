<p align="center">
  <img src="https://raw.githubusercontent.com/naveen1583/private_pypi_codeartifact/main/images/CodeArtifact.png" alt="AWS CodeArtifact Logo" width="150"/>
</p>

# private-pip-repo (AWS CodeArtifact)

A simple, secure Nginx-based proxy for AWS CodeArtifact PyPI repositories, designed for use on internal servers (e.g., EC2 in private subnets) with no direct internet access. Includes automatic token refresh and SSL support.

## Features

- Proxies pip package downloads from AWS CodeArtifact
- Automatic CodeArtifact token refresh (via cron)
- Self-signed SSL support for secure connections
- Designed for private/internal networks (no internet required)

## Prerequisites

- AWS account with CodeArtifact domain and repository
- EC2 (Amazon Linux 2023) or internal Linux server with IAM role for `codeartifact:GetAuthorizationToken`
- DNS name pointing to the server (e.g., Route 53 private hosted zone)
- AWS CLI installed

## Setup Instructions

### 1. Launch and Configure EC2

- Launch an EC2 instance (t3.micro or similar) in a private subnet.
- Attach an IAM role with policies: `AWSCodeArtifactReadOnlyAccess` (or custom).
- SSH into the instance and install dependencies:

### 2. Generate Self-Signed SSL Certificate

Run the script in `scripts/generate-ssl.sh` (replace `<domain-name>`):

```sh
sudo bash scripts/generate-ssl.sh <domain-name>
```

### 3. Configure Nginx

- Copy `nginx-proxy.conf` to `/etc/nginx/conf.d/codeartifact-proxy.conf`
- Edit the config and replace:
  - `YOUR_CODEARTIFACT_DOMAIN`, `YOUR_REPO`, `YOUR_REGION`
  - `YOUR_BASE64_TOKEN_PLACEHOLDER` (will be auto-updated by the script)
- For caching, add the cache config to your `/etc/nginx/nginx.conf` http block if desired

Test and start:

```sh
sudo nginx -t && sudo systemctl start nginx
```

### 4. Set Up Token Refresh

- Edit `scripts/update-token.sh` and set your DOMAIN, REPO, REGION at the top
- Make executable:
  ```sh
  chmod +x scripts/update-token.sh
  ```
- Run manually:
  ```sh
  sudo bash scripts/update-token.sh
  ```
- Add to root's crontab for auto-refresh (every 10 hours):
  ```sh
  sudo crontab -e
  # Add:
  0 */10 * * * /absolute/path/to/scripts/update-token.sh >> /var/log/token.log 2>&1
  ```

### 5. (Optional) Add VPC Endpoints (for Private Access)

- Create Interface VPC endpoints for:
  - `com.amazonaws.<region>.codeartifact.api`
  - `com.amazonaws.<region>.codeartifact.repositories`
- Associate with your EC2's subnet and security group (allow 443 inbound)

### 6. Client Configuration

- Trust the self-signed cert on clients (import the .crt file)
- Set pip config:
  ```sh
  pip config set global.index-url https://your-dns-name/simple/
  ```
- Test:
  ```sh
  pip install some-package
  ```

## Troubleshooting

See `troubleshooting.md` for common issues (401/502 errors, SSL, etc.)

## License

Apache 2.0 License - see LICENSE for details.
