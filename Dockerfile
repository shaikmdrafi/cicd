FROM centos
LABEL project="test apache service"
LABEL maintainer "mohammedrafi494@gmail.com"
RUN yum -y update
RUN yum -y install httpd
EXPOSE 80
RUN echo "this is a part of cicd testing" >> /var/www/html/index.html
ENTRYPOINT [ "/usr/sbin/httpd" ]
CMD ["-D", "FOREGROUND"]
