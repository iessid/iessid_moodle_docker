# This Dockerfile is heavily inspired by https://github.com/sergiogomez/docker-moodle/

# We start from another base image to have PHP5.6
FROM debian:jessie
MAINTAINER Emmanuel Di Pretoro <di_pretoro@he-spaak.be>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install apt-utils

# Basic Requirements
RUN apt-get -y install mysql-server mysql-client pwgen python-setuptools curl git unzip 

# Moodle Requirements
RUN apt-get -y install apache2
RUN apt-get -y install postfix wget supervisor vim curl libcurl3 libcurl3-dev
RUN apt-get -y install php5-gd php5-mysql php5-curl php5-xmlrpc php5-intl
RUN apt-get -y install phpmyadmin

# SSH
RUN apt-get -y install openssh-server
RUN mkdir -p /var/run/sshd

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN easy_install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf

ADD https://download.moodle.org/download.php/direct/stable31/moodle-3.1.2.tgz /var/www/moodle-3.1.2.tgz
RUN rm -rf /var/www/html
RUN cd /var/www; tar zxf moodle-3.1.2.tgz; mv /var/www/moodle /var/www/html; rm /var/www/moodle-3.1.2.tgz
RUN chown -R www-data:www-data /var/www/html/
RUN mkdir /var/moodledata
RUN chown -R www-data:www-data /var/moodledata; chmod 777 /var/moodledata
RUN chmod 755 /start.sh /etc/apache2/foreground.sh

EXPOSE 22 80
CMD ["/bin/bash", "/start.sh"]
