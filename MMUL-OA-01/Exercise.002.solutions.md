# Exercise 002 - Running your first container on crc - Solutions

1) Use crc executable to load the podman environment:

> eval $(crc podman-env)

2) Use the podman-remote command as it was the local podman command:

> podman-remote run --detach --publish 8888:80 --name first-nginx-test alpine_nginx

3) Use the ```crc ip``` command with curl to verify the status of the port:

> curl $(crc ip):8888
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

4) Since we launched the command with --rm option, then it is sufficient to
stop it and it will be automatically destroyed:

> podman-remote stop first-nginx-test

> podman-remote ps -a
CONTAINER ID  IMAGE   COMMAND  CREATED  STATUS  PORTS   NAMES
