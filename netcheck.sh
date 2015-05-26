#!/bin/bash

# @author Martin Vician <martin@vician.cz>

## Constants
EXPECTED_GW=192.168.0.1
IP=8.8.8.8
DOMAIN="google-public-dns-a.google.com"
DOMAIN_IP=8.8.8.8

GW_PING_COUNT=4
IP_PING_COUNT=4

EXIT_OK=0
EXIT_WRONG_PARAM=1
EXIT_NOT_INSTALLED=2
EXIT_SYSTEM_FAILED=3

## Functions

function test_traceroute {
	cmd="traceroute"
	if [ -z "`which $cmd`" ] ; then
		echo "ERROR: Program $cmd not installed!"
		exit $EXIT_NOT_INSTALLED
	fi
	$cmd $SERVER
}

function verify_gw {
	echo "Veryfing if default gateway is expected"
	ip route show 2>/dev/null | grep default 1>/dev/null
	if [ $? -ne 0 ]; then
		echo "ERROR: no default rote!"; exit $EXIT_SYSTEM_FAILED
	fi
	DEFAULT_GW=`ip route show 2>/dev/null | grep default | awk '{ print $3 }'`
	if [ "$DEFAULT_GW" != "$EXPECTED_GW" ]; then
		echo "WARNING: Expeced gateway isn't default gateway which was detected!"
	fi
	netstat -nr 2>/dev/null | grep $EXPECTED_GW 1>/dev/null
	if [ $? -ne 0 ] ; then
		echo "ERROR Current gateway isn't expected!"
		echo "Current is: $DEFAULT_GW"
		echo "Expected is: $EXPECTED_GW"
		exit 1
	fi
}

function check_gw {
	echo "Veryfing connection to default gateway (router)"
	ping -c $GW_PING_COUNT $DEFAULT_GW 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		echo "ERROR: Connection to default gateway (router) isn't stable!"
		echo "It can be a serious problem!"
	fi
}

function check_ip {
	echo "Veryfing connection to test IP!"
        ping -c $GW_PING_COUNT $IP 1>/dev/null 2>/dev/null
        if [ $? -ne 0 ]; then
                echo "ERROR: Connection to test IP isn't stable!"
                echo "It can be a serious problem!"
        fi

}

function check_dns {
	echo "Veryfing DNS resolving"
	host $DOMAIN 2>/dev/null | grep $DOMAIN_IP 1>/dev/null
	if [ $? -ne 0 ]; then
		echo "ERROR: DNS resolving isn't stable!"
		echo "It can be a serious problem!"
	fi
}

verify_gw
check_gw
check_ip
check_dns


#test_traceroute
