# Dockerfile for generating a WordPress friendly container
# Run unittests, build with grunt or install your own packages with npm

# Start from php image
FROM php:7

# Maintainer
MAINTAINER Swashata Ghosh <swashata4u@gmail.com>

# Non interactive mode
ARG DEBIAN_FRONTEND=noninteractive

# Update our repository
RUN apt-get update -yqq

# Install git
RUN apt-get install git -yqq

# Install core dependencies
RUN apt-get install -yqqf --fix-missing \
  vim wget curl zip unzip subversion mysql-client libmcrypt-dev libmysqlclient-dev

# Install MYSQL driver
RUN docker-php-ext-install mysqli pdo_mysql mbstring

# Install XDEBUG
RUN pecl install xdebug

# Enable needed PHP extensions
RUN docker-php-ext-enable mysqli pdo_mysql mbstring xdebug

# Install PHPUnit tests
RUN wget https://phar.phpunit.de/phpunit-6.1.phar && \
  chmod +x phpunit-6.1.phar && \
  mv phpunit-6.1.phar /usr/local/bin/phpunit

# Install composer
RUN curl -sS https://getcomposer.org/installer | php

# Install Node
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash
RUN apt-get install -yqq nodejs

# Install grunt-cli
RUN npm install -g grunt-cli

# Setup WordPress PHPUnit Testing environment

# Setup environment
ENV WP_CORE_DIR "/tmp/wordpress/"
ENV WP_TESTS_DIR "/tmp/wordpress-tests-lib"
ENV WP_VERSION "4.8"
ENV WP_TESTS_TAG "tags/4.8"

# Download WordPress from source
RUN mkdir -p $WP_CORE_DIR
RUN curl -s "https://wordpress.org/${ARCHIVE_NAME}.tar.gz" > "/tmp/wordpress.tar.gz" && \
  tar --strip-components=1 -zxmf /tmp/wordpress.tar.gz -C $WP_CORE_DIR

# Get the test data from SVN
RUN mkdir -p $WP_TESTS_DIR && \
  svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/includes/ $WP_TESTS_DIR/includes
  svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/data/ $WP_TESTS_DIR/data

## That's it, let pray it works
