
docker stop weby_server && docker rm weby_server >/dev/null
#using apache2
docker run -d -p 8080:80 --name weby_server   -v ~/workspace/yocto_not/build/tmp/deploy/images/aero-rsp/:/usr/local/apache2/htdocs/   httpd
