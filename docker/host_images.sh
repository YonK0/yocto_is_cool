
docker stop weby_server && docker rm weby_server >/dev/null
#using apache2
docker run -d -p 8080:80 --name weby_server   -v $PWD/../build/tmp/deploy/images/pizero/:/usr/local/apache2/htdocs/   httpd
