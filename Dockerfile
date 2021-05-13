FROM ubuntu:20.04

LABEL Author="Esron Silva esron.silva@sysvale.com"

ENV PATH ${PATH}:/usr/local/bin:/usr/local/sbin:/usr/bin:/sbin:/bin:/usr/sbin

# Add PHP ondrej repository
RUN apt-get update \
  && apt install lsb-release ca-certificates apt-transport-https software-properties-common -y \
  && LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update && apt-get upgrade -y

# Install php and its libraries
RUN apt-get -y install php8.0 \
  php8.0-mbstring \
  php8.0-xml \
  php8.0-curl \
  php8.0-mysql \
  php8.0-zip \
  libxrender1 \
  libfontconfig1 \
  libxtst6 \
  apache2 \
  curl \
  && apt-get autoremove -y \
  && apt-get clean \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

# Install nodejs and npm
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g n npm@latest

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && php -r "unlink('composer-setup.php');"

COPY . /usr/app

WORKDIR /usr/app

RUN chown www-data storage bootstrap/cache -R

ADD apache.conf /etc/apache2/sites-enabled/000-default.conf

RUN a2enmod rewrite &&\
    ln -sfn /usr/app/public /var/www/dev


CMD ["apachectl", "-D", "FOREGROUND"]
