#!/bin/bash

#variables 
app_version=$((1 + $RANDOM % 100))

apt-get update

echo "install and enable nginx"
apt-get -qq -y install nginx
systemctl enable nginx

echo "install curl"
apt-get -qq -y install curl

echo "install npm"
apt-get -qq -y install npm

echo "install yarn"
npm install --global yarn

echo "install nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
echo 'export NVM_DIR="/.nvm"' >> /etc/profile.d/nvm.sh
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> /etc/profile.d/nvm.sh
source /etc/profile.d/nvm.sh
nvm install node

echo "install proper node version"
nvm install 16.14.2

echo "clone repo"
git clone https://github.com/xmd5a/vite-app-1.git
cd vite-app-1

echo "set env variable"
echo "VITE_APP_VERSION=$app_version" > .env

echo "build app"
yarn install
yarn run build

echo "copy app to nginx"
rm -f /var/www/html/index.nginx-debian.html
mv dist/* /var/www/html/

echo "update nginx config"
echo "server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;

    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /api {
        proxy_pass ${api_url};
    }
}" > /etc/nginx/sites-enabled/default

echo "restart nginx server"
systemctl restart nginx