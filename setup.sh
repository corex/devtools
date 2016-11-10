#!/usr/bin/env bash

CURDIR=$(pwd)
SYSDIR=$(dirname $(readlink -f $0))
cd $SYSDIR

# Make sure composer is installed.
if [ ! -f "$SYSDIR/composer.phar" ]; then
	echo "Download composer."
	echo ""
	wget https://getcomposer.org/download/1.0.0/composer.phar
	if [ ! -f "$SYSDIR/composer.phar" ]; then
		echo "Something went wrong in installation of composer."
	fi
	chmod 700 $SYSDIR/composer.phar
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

# Symbolic Links for packages.
if [ ! -f "$SYSDIR/phpunit" ]; then
    ln -s $SYSDIR/vendor/bin/phpunit $SYSDIR/phpunit
fi

# Setup PHP CodeSniffer
echo "Setting up Code Sniffer."
$SYSDIR/vendor/bin/phpcs --config-set colors 1
$SYSDIR/vendor/bin/phpcs --config-set show_progress 1
$SYSDIR/vendor/bin/phpcs --config-set report_width 120
$SYSDIR/vendor/bin/phpcs --config-set encoding utf-8
echo ""

cd $CURDIR
echo "Setup done."
