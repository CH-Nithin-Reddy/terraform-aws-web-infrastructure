#!/bin/bash

# Update packages
apt-get update -y

# Install Nginx
apt-get install nginx -y

# Start Nginx
systemctl start nginx

# Enable Nginx
systemctl enable nginx

# Create Web Page for Instance 2
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Server 2</title>
</head>
<body>
<h1>Terraform Load Balancer Project</h1>
<h2>This is Server 2</h2>
<h3>Hostname:</h3>
<p>$(hostname)</p>
</body>
</html>
EOF