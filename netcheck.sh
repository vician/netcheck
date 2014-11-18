#!/bin/bash

# @author Martin Vician <martin@vician.cz>

## Constants
SERVER=8.8.8.255

EXIT_OK=0
EXIT_WRONG_PARAM=1
EXIT_NOT_INSTALLED=2

## Functions

function test_traceroute {
	cmd="traceroute"
	if [ -z "`which $cmd`" ] ; then
		echo "ERROR: Program $cmd not installed!"
		exit $EXIT_NOT_INSTALLED
	fi
	$cmd $SERVER
}

test_traceroute