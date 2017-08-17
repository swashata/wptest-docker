# Dockerfile for generating a WordPress friendly container
# Run unittests, build with grunt or install your own packages with npm

# Start from php image
FROM php:7.0

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
  vim wget curl zip unzip subversion mysql-client libmcrypt-dev libmysqlclient-dev zip unzip openssh-client gettext

# Install MYSQL driver
RUN docker-php-ext-install mysqli pdo_mysql mbstring mcrypt

# Install XDEBUG
RUN pecl install xdebug

# Enable needed PHP extensions
RUN docker-php-ext-enable mysqli pdo_mysql mbstring xdebug mcrypt

# Install PHPUnit tests
RUN wget https://phar.phpunit.de/phpunit-6.3.phar && \
  chmod +x phpunit-6.3.phar && \
  mv phpunit-6.3.phar /usr/local/bin/phpunit

# Install composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer && rm -rf /tmp/composer-setup.php

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x wp-cli.phar && \
  mv wp-cli.phar /usr/local/bin/wp

# Install Node
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash
RUN apt-get install -yqq nodejs

# Install grunt-cli
RUN npm install -g grunt-cli

# Install bower
RUN npm install -g bower

# Setup WordPress PHPUnit Testing environment

# Setup environment
ENV WP_CORE_DIR "/tmp/wordpress/"
ENV WP_TESTS_DIR "/tmp/wordpress-tests-lib"
ENV WP_VERSION "4.8.1"
ENV WP_TESTS_TAG "tags/4.8.1"

# Download WordPress from source
RUN mkdir -p $WP_CORE_DIR
RUN curl -s "https://wordpress.org/wordpress-${WP_VERSION}.tar.gz" > "/tmp/wordpress.tar.gz" && \
  tar --strip-components=1 -zxmf /tmp/wordpress.tar.gz -C $WP_CORE_DIR

# Get the test data from SVN
RUN mkdir -p $WP_TESTS_DIR && \
  svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/includes/ $WP_TESTS_DIR/includes && \
  svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/data/ $WP_TESTS_DIR/data

# Setup initial SSH agent
RUN mkdir -p ~/.ssh && \
  eval $(ssh-agent -s) && \
  echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

## That's it, let pray it works
