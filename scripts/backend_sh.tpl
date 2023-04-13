#!/bin/bash

#variables
s3_region=us-east-1

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

echo "install pm2"
npm install --global pm2

echo "install nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
echo 'export NVM_DIR="/.nvm"' >> /etc/profile.d/nvm.sh
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> /etc/profile.d/nvm.sh
source /etc/profile.d/nvm.sh
nvm install node

echo "install proper node version"
nvm install 16.14.2

echo "clone repo"
git clone https://github.com/xmd5a/api-images.git
cd api-images

echo "set env variable"
echo "BUCKET_NAME=${s3_bucket}
DB_HOSTNAME=${db_hostname}
DB_NAME=${db_name}
DB_USERNAME=${db_user}
DB_PASSWORD=${db_password}
S3_REGION=$s3_region" > .env

echo "build app"
yarn install
yarn run build

echo "copy app to nginx"
rm -f /var/www/html/index.nginx-debian.html
mv -f ./{.,}* /var/www/html/

echo "update nginx config"
echo "server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location /api {
        proxy_pass http://localhost:4001;
    }
}
" > /etc/nginx/sites-enabled/default

echo "enable app using pm2"
cd /var/www/html/
pm2 start dist/index.js

echo "restart nginx server"
systemctl restart nginx