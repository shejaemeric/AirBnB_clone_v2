#!/usr/bin/env bash
#  Bash script that sets up your web servers for the deployment of web_static. It must:
#     Install Nginx if it not already installed
#     Create the folder /data/ if it doesn’t already exist
#     Create the folder /data/web_static/ if it doesn’t already exist
#     Create the folder /data/web_static/releases/ if it doesn’t already exist
#     Create the folder /data/web_static/shared/ if it doesn’t already exist
#     Create the folder /data/web_static/releases/test/ if it doesn’t already exist
#     Create a fake HTML file /data/web_static/releases/test/index.html (with simple content,
#     to test your Nginx configuration)
#     Create a symbolic link /data/web_static/current linked to the /data/web_static/releases/test/ folder.
#     If the symbolic link already exists, it should be deleted and recreated every time the script is ran.
#     Give ownership of the /data/ folder to the ubuntu user AND group (you can assume this user and group exist).
#     This should be recursive; everything inside should be created/owned by this user/group.
#     Update the Nginx configuration to serve the content of /data/web_static/current/ to hbnb_static
#     (ex: https://mydomainname.tech/hbnb_static). Don’t forget to restart Nginx after updating the configuration:


sudo apt-get update
sudo apt-get install nginx

sudo mkdir -p /data/web_static/releases/test/
sudo mkdir -p /data/web_static/shared/
echo "hello static world" >> /data/web_static/releases/test/index.html

ln -sf /data/web_static/releases/test/ /data/web_static/current
sudo chown -R ubuntu:ubuntu /data/


echo "
server {
	add_header X-Served-By $hostname always;
	listen 80 default_server;
	listen [::]:80 default_server;

	root /var/www/html;

	index index.html index.htm index.nginx-debian.html;

	server_name _;

    location /hbnb_static {
        alias /data/web_static/current/;
        index index.html index.htm;
    }

	location =/redirect_me {
		return 301 https://www.youtube.com/watch?v=QH2-TGUlwu4;
	}
	error_page 404 /404.html;
	location /404.html {
		internal;
	}
}
" > /etc/nginx/sites-available/default

sudo nginx -s reload
sudo service nginx restart

