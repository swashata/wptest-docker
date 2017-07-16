# Docker Container for Automated WordPress Testing and Build

So in my workflow I use the following:

* [WP-CLI](http://wp-cli.org/) to manage WordPress from commandline.
* [PHPUnitTest](https://phpunit.de/) for testing WordPress themes and plugin.
* [Nodejs](https://nodejs.org/en/) for javascript related stuff.
* [Grunt](https://gruntjs.com/) for automating builds and release.

For this to work under [gitlab](https://about.gitlab.com/) and [gitlab-ci](https://about.gitlab.com/features/gitlab-ci-cd/) I need a docker which would essentially have the following:

* **PHP-7.0 with CLI** - for unittesting.
* **Nodejs** - for using npm and grunt.
* **[WordPress Test](https://make.wordpress.org/cli/handbook/plugin-unit-tests/)** - an environment for making WordPress Plugin/Theme unit testing a breeze.

In this attempt, I am creating a docker which would have the following installed by default, so that I don't have to everytime.

## Docker Container Features

* `PHP-7.0`
* `Nodejs` and `npm`
* `Git`
* `vim wget zip unzip subversion mysql-client libmcrypt-dev libmysqlclient-dev`
* `PHPUnit` - PHAR Install.
* `Composer`
* `WP-CLI` setup for WordPress unit testing:
	* Downloaded WordPress latest.zip with proper environment setup. - `WP_CORE_DIR`
	* SVN-ed WordPress test libraries with proper environment setup. - `WP_TESTS_DIR`

For `WP_UnitTest` the following environment variables are set:

* `WP_CORE_DIR` "/tmp/wordpress/"
* `WP_TESTS_DIR` "/tmp/wordpress-tests-lib"
* `WP_VERSION` "4.8"
* `WP_TESTS_TAG` "tags/4.8"

So if you have used `WP-CLI` to scaffold your `PHP_UnitTest` (which you should), you are covered. The install will run to only setup the databse variables and the test-config file.

## Sample `.gitlab-ci.yml` configuration

```yaml
# Our base image
image: wpquark/wptest-php-nodejs-grunt:version-4.8

# mysql service
services:
- mysql

# Select what we should cache
cache:
  paths:
  - vendor/
  - node_modules/

before_script:
# Install npm dependencies
- npm install

# Install composer
- composer install

# Install WordPress PHPUnit Test
- bash bin/install-wp-tests.sh wordpress_test root mysql mysql $WP_VERSION

variables:
  # Configure mysql service (https://hub.docker.com/_/mysql/)
  MYSQL_DATABASE: wordpress_tests
  MYSQL_ROOT_PASSWORD: mysql
  WP_MULTISITE: "0"

# We test on php7
# default job
default-job:
  tags:
    - wordpress
  script:
  - grunt
  except:
    - tags

# release job on tag
release-job:
  tags:
    - wordpress
  image: php:7
  script:
    - grunt release
  artifacts:
    paths:
      - build/wpq-social-press.zip
  only:
   - tags
```

The above is what we use in our `gitlab-ci.yml`.
