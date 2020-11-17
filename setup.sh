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

	if [[ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]]; then
	    >&2 echo 'ERROR: Invalid installer signature'
	    rm composer-setup.php
	    exit 1
	fi

	php composer-setup.php
	RESULT=$?
	rm composer-setup.php
fi
echo ""

# Updating composer to latest version.
php composer.phar selfupdate
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

    # Add link to phpcs in ~/bin
    if [[ ! -f "$HOME/bin/phpcs" ]]; then
        ln -s $SYSDIR/phpcs.sh $HOME/bin/phpcs
        echo "Link $HOME/bin/phpcs created."
        echo ""
    fi

    # Add link to "symfony-autocomplete".
    if [[ ! -f "$HOME/bin/symfony-autocomplete" ]]; then
        ln -s $SYSDIR/vendor/bin/symfony-autocomplete $HOME/bin/symfony-autocomplete
        echo "Link $HOME/bin/symfony-autocomplete created."
        echo ""
    fi

    # Make sure "symfony-autocomple is added to ".bashrc".
    CHECK=$(grep "symfony-autocomplete" $HOME/.bashrc)
    if [ -z "$CHECK" ]; then
        echo "eval \"\$(\$HOME/bin/symfony-autocomplete)\"" >> $HOME/.bashrc
    fi
fi

cd $CURDIR
echo "Setup done."
