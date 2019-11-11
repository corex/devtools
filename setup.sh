#!/usr/bin/env bash

CURDIR=$(pwd)
SYSDIR=$(dirname $(readlink -f $0))
cd $SYSDIR

# Make sure composer is installed.
if [ ! -f "$SYSDIR/composer.phar" ]; then
	echo "Download composer."
	echo ""

	EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

	if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
	then
	    >&2 echo 'ERROR: Invalid installer signature'
	    rm composer-setup.php
	    exit 1
	fi

	php composer-setup.php --quiet
	RESULT=$?
	rm composer-setup.php
fi
echo ""

# Updating composer to latest version.
php composer.phar selfupdate
echo ""

# Updating FXP asset plugin.
php composer.phar global update fxp/composer-asset-plugin --no-plugins
echo ""

# Install/Update composer.json
php composer.phar update
echo ""

# Link composer.phar to composer
if [ ! -f "$SYSDIR/composer" ]; then
    ln -s $SYSDIR/composer.phar $SYSDIR/composer
fi
echo ""

# Setup PHP CodeSniffer
echo "Setting up Code Sniffer."
$SYSDIR/vendor/bin/phpcs --config-set colors 1
$SYSDIR/vendor/bin/phpcs --config-set show_progress 1
$SYSDIR/vendor/bin/phpcs --config-set report_width 120
$SYSDIR/vendor/bin/phpcs --config-set encoding utf-8
echo ""

cd $CURDIR
echo "Setup done."
