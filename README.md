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

## Sample `.gitlab-ci.yml` configuration

> // TODO
