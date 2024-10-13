FROM nginx:latest

# Install dependencies and certbot using apt
RUN apt-get update && apt-get install -y curl certbot iproute2 gnupg2 ca-certificates lsb-release python3-certbot-nginx

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Copy NGINX configuration
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Run Tailscale, NGINX, and obtain certs using Certbot
CMD ["/bin/bash", "-c", "tailscaled & tailscale up --authkey=$TS_AUTH_KEY && nginx -g 'daemon off;'"]
