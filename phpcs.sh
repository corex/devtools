#!/bin/bash

CURDIR=$(pwd)
SYSDIR=$(dirname $(readlink -f $0))

if [[ ! -f "$SYSDIR/vendor/bin/phpcs" ]]; then
	echo "Could not find phpcs"
	echo ""
	echo "You need to run ./setup.sh"
	exit
fi

if [[ -z "$1" ]]; then
	echo "You need to specify at least 1 argument."
	exit
fi

$SYSDIR/vendor/bin/ecs check --config $SYSDIR/ecs/corex.yaml $1 $2 $3 $4 $5 $6 $7 $8 $9
