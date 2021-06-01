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
rm -f $SYSDIR/composer
ln -s $SYSDIR/composer.phar $SYSDIR/composer

# Install/Update composer.json
php composer.phar update
echo ""

# Setup PHP CodeSniffer
echo "Setting up Code Sniffer."
$SYSDIR/vendor/bin/phpcs --config-set show_progress 1
$SYSDIR/vendor/bin/phpcs --config-set encoding utf-8
echo ""

# Setup "git number".
if [[ ! -d "$SYSDIR/git-number" ]]; then
    echo "Cloning git-number repository."
    cd $SYSDIR
    git clone git@github.com:holygeek/git-number.git -q
else
    echo "Refreshing git-number repository."
    cd $SYSDIR/git-number
    git pull -q
    cd $SYSDIR
fi
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

    # Add links to "git-number".
    if [[ ! -f "$HOME/bin/git-number" ]]; then
        ln -s $SYSDIR/git-number/git-number $HOME/bin/git-number
        ln -s $SYSDIR/git-number/git-list $HOME/bin/git-list
        ln -s $SYSDIR/git-number/git-id $HOME/bin/git-id
        echo "Links for git-number tools added."
        echo ""
    fi

    # Make sure "git-number aliases is added to ".bashrc".
    CHECK=$(grep "^# Setup aliases for git." $HOME/.bashrc)
    if [ -z "$CHECK" ]; then
        echo "Setup aliases for git."
        echo "" >> $HOME/.bashrc
        echo "# Setup aliases for git." >> $HOME/.bashrc
        echo "alias gn='git-number '" >> $HOME/.bashrc
        echo "alias ga='gn add '" >> $HOME/.bashrc
        echo "alias gap='gn add -p '" >> $HOME/.bashrc
        echo "alias gbl='git branch --list '" >> $HOME/.bashrc
        echo "alias gc='gn commit '" >> $HOME/.bashrc
        echo "alias gca='gc -a '" >> $HOME/.bashrc
        echo "alias gd='gn diff '" >> $HOME/.bashrc
        echo "alias gds='gn diff --staged '" >> $HOME/.bashrc
        echo "alias gdw='gn diff -w '" >> $HOME/.bashrc
        echo "alias gl='git log '" >> $HOME/.bashrc
        echo "alias gm='git merge '" >> $HOME/.bashrc
        echo "alias gmm='git merge master '" >> $HOME/.bashrc
        echo "alias go='gn checkout '" >> $HOME/.bashrc
        echo "alias gob='git checkout -b '" >> $HOME/.bashrc
        echo "alias gom='git checkout master '" >> $HOME/.bashrc
        echo "alias gres='gn reset '" >> $HOME/.bashrc
        echo "alias grm='gn rm '" >> $HOME/.bashrc
        echo "alias gs='gn --column '" >> $HOME/.bashrc
        echo "alias gush='git push '" >> $HOME/.bashrc
        echo "alias gull='git pull '" >> $HOME/.bashrc
        echo ""
    fi
fi

cd $CURDIR
echo "Setup done."
