#!/bin/bash
# Setup: nginx.conf is in the wrong directory — user must find and move it

mkdir -p /home/user/etc/nginx/sites-available
mkdir -p /home/user/etc/nginx/sites-enabled
mkdir -p /home/user/var/log/nginx
mkdir -p /home/user/tmp
mkdir -p /home/user/home/deploy

# Plant the misplaced file
cat > /home/user/tmp/nginx.conf << 'EOF'
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.html;
}
EOF

# Decoy files to make it interesting
echo "# empty placeholder" > /home/user/etc/nginx/sites-available/default
echo "deploy_user=www-data" > /home/user/home/deploy/deploy.env
echo "127.0.0.1 localhost" > /home/user/etc/hosts

chown -R user:user /home/user