#!/bin/bash

# @author Martin Vician <martin@vician.cz>

## Constants
IP=8.8.8.8
TEST_DOMAIN="www.google.com"
TEST_IP_DOMAIN="google-public-dns-a.google.com"
TEST_IP=8.8.8.8

PING_COUNT=4

EXIT_OK=0
EXIT_WRONG_PARAM=1
EXIT_NOT_INSTALLED=2
EXIT_SYSTEM_FAILED=3

### Variables ###
GW=""
DEBUG=1

## Functions

function debug {
	if [ $DEBUG -eq 0 ]; then
		return 0;
	fi
	echo "DEBUG:" $*
}

function error {
	if [ $# -ne 2 ]; then
		echo "ERROR: Function error() - wrong parameters! [$#: $*]"
		exit $EXIT_WRONG_PARAM
	fi
	echo "ERROR:" $2
	exit $1
}

function is_installed {
	if [ $# -eq 0 ]; then
		error $EXIT_WRONG_PARAM "Function is_installed() - wrong parameters! [$#: $*]"
	fi
	for program in $@; do
		debug "testing $program: `which $program`"
		which $program 1>/dev/null 2>/dev/null
		if [ $? -ne 0 ]; then
			echo "WARNING: Program $program not installed. Some functions will not work!"
			return 1
		fi
	done
}

function get_gw {
	ip route show 2>/dev/null | grep default 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		exit $EXIT_SYSTEM_FAILED "Cannot find default route!"
	fi
	GW=`ip route show 2>/dev/null | grep default 2>/dev/null | awk '{print $3}'`
	if [ $GW == "" ]; then
		error $EXIT_SYSTEM_FAILED "Cannot find default gateway!"
	fi
	debug "Founded GW: $GW"
}

function check_ping {
	if [ $# -ne 1 ]; then
		error $EXIT_WRONG_PARAM "Wrong pamateres check_ping() [$#: $*]"
	fi
	IP=$1
	echo "Veryfing connection to test IP: $IP!"
	if [ $DEBUG -eq 0 ]; then
		ping -c $PING_COUNT $IP 1>/dev/null 2>/dev/null
	else
		ping -c $PING_COUNT $IP
	fi
	if [ $? -ne 0 ]; then
	        debug "Ping to $IP not works!"
					return 1
	else
		debug "Ping to $IP works."
	fi
}

function check_dns {
	is_installed host
	if [ $? -ne 0 ]; then
		error $EXIT_NOT_INSTALLED "Please install requirements (host)!"
	fi
	debug "Veryfing DNS resolving"
	debug "Test DNS ($TEST_IP_DOMAIN): `host $TEST_IP_DOMAIN`"
	host $TEST_IP_DOMAIN 2>/dev/null | grep $TEST_IP_DOMAIN 1>/dev/null
	if [ $? -ne 0 ]; then
		echo "ERROR: DNS resolving isn't stable!"
		echo "It can be a serious problem!"
	fi
}

is_installed ip route ping
if [ $? -ne 0 ]; then
	error $EXIT_NOT_INSTALLED "Please install requirements (ip route ping)!"
fi
check_ping $TEST_DOMAIN
if [ $? -eq 0 ] ; then
	echo "Internet works. Are you sure that you want to run this analyzator?"
	read -p "Continue (y/n)?" choice
	case "$choice" in
  	y|Y ) ;;
  	n|N ) exit $EXIT_OK;;
  	* ) echo "Invalid ansewer."; exit $EXIT_OK;
	esac
fi

get_gw
check_ping $GW

check_dns
