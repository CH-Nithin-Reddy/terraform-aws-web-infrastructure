#!/bin/bash

apt update -y
apt install nginx -y

systemctl start nginx
systemctl enable nginx

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Nithin Portfolio - Server 1</title>

<style>
body {
    font-family: Arial;
    background:#0f172a;
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
    color:#38bdf8;
    font-size:24px;
    font-weight:bold;
}
</style>

</head>

<body>

<h1>Nithin Reddy</h1>

<p class="server">
 Served from Server 1
</p>

<div class="card">
<h2>Terraform AWS Infrastructure Project</h2>

<p>
This portfolio is deployed using Terraform on AWS
with Application Load Balancer and EC2 instances.
</p>

</div>

</body>

</html>
EOF