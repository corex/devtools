#!/usr/bin/env bash

CURDIR=$(pwd)
SYSDIR=$(dirname $(readlink -f $0))
cd $SYSDIR

# Check if php is installed on system.
if [[ ! -f "/usr/bin/php" ]]; then
    echo "PHP /usr/bin/php not installed on system."
    exit
fi

# Make sure composer is installed.
if [[ ! -f "$SYSDIR/composer.phar" ]]; then
	echo "Download composer."
	echo ""

	EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

	if [[ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]]
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

# Updating FXP asset plugin.1
if [[ -f "$HOME/.composer/vendor/fxp/composer-asset-plugin" ]]; then
    php composer.phar global update fxp/composer-asset-plugin --no-plugins
else
    php composer.phar global require fxp/composer-asset-plugin
fi
echo ""

# Link composer.phar to composer
if [[ ! -f "$SYSDIR/composer" ]]; then
    ln -s $SYSDIR/composer.phar $SYSDIR/composer
fi

# Install/Update composer.json
php composer.phar update
echo ""

# Setup PHP CodeSniffer
echo "Setting up Code Sniffer."
$SYSDIR/vendor/bin/phpcs --config-set show_progress 1
$SYSDIR/vendor/bin/phpcs --config-set encoding utf-8
echo ""

# If ~/bin exists, add symbolic links.
if [[ -d "$HOME/bin" ]]; then

    # Add link to composer.phar in ~/bin
    if [[ ! -f "$HOME/bin/composer" ]]; then
        ln -s $SYSDIR/composer $HOME/bin/composer
        echo "Link $HOME/bin/composer created."
        echo ""
    fi

    # Add link to phpcs-loose in ~/bin
    if [[ ! -f "$HOME/bin/phpcs-loose" ]]; then
        ln -s $SYSDIR/phpcs-loose.sh $HOME/bin/phpcs-loose
        echo "Link $HOME/bin/phpcs-loose created."
        echo ""
    fi

    # Add link to phpcs-strict in ~/bin
    if [[ ! -f "$HOME/bin/phpcs-strict" ]]; then
        ln -s $SYSDIR/phpcs-strict.sh $HOME/bin/phpcs-strict
        echo "Link $HOME/bin/phpcs-strict created."
        echo ""
    fi
fi

cd $CURDIR
echo "Setup done."
