#!/bin/bash

apt update -y
apt install nginx -y

systemctl start nginx
systemctl enable nginx

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Nithin Portfolio - Server 2</title>

<style>
body {
    font-family: Arial;
    background:#020617;
    color:white;
    text-align:center;
}

.card {
    background:#1e293b;
    padding:20px;
    margin:20px;
    border-radius:10px;
}

.server {
    color:#22c55e;
    font-size:24px;
    font-weight:bold;
}
</style>

</head>

<body>

<h1>Nithin Reddy</h1>

<p class="server">
 Served from Server 2
</p>

<div class="card">
<h2>High Availability Architecture</h2>

<p>
Traffic is distributed using AWS Application Load Balancer
across multiple availability zones.
</p>

</div>

</body>

</html>
EOF