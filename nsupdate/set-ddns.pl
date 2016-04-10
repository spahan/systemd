#!/usr/bin/perl

# set-ddns.pl
#
# Copyright (c) 05-20-2006, JRS System Solutions
# All rights reserved under standard BSD license
# details: http://www.opensource.org/licenses/bsd-license.php

# note: requires BIND 9.3.1 and CPAN LWP::UserAgent, HTTP::Request, and HTTP::Response
#       FreeBSD admins may find the CPAN modules under /usr/ports/www/p5-libwww
#
# WARNING: FreeBSD admins must make CERTAIN they are calling the BIND9 version
#          of nsupdate - FreeBSD systems have a nasty habit of leaving a copy
#          of the BIND8 version higher up in the PATH, even in systems shipped
#          with BIND9 in the base install!

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;

$NAMESERVER = 'ns.spahan.ch';
$KEYDIR = '/root';
$KEYFILE = '/root/nsupdate.private';
$TYPE = 'A';
$TTL = '10';
$HOST = $ARGV[0]; 

$url_string = 'http://xn--hm-via.ch/ip.php';
$ua = LWP::UserAgent->new;
$req = HTTP::Request->new('GET',$url_string);
$resp = $ua->request($req)->as_string();

$_ = $resp;
m/.*?Current IP Address\: (\d{0,3}\.\d{0,3}\.\d{0,3}\.\d{0,3}).*/gs;
$WAN = $1;

#print "==============================\nWAN IP parsed: $WAN\n==============================\n";

chdir ($KEYDIR);
open (NSUPDATE, "| /usr/bin/nsupdate -d -k $KEYFILE -t300 -v");
#open (NSUPDATE, ">","./cmd.out");
print NSUPDATE "server $NAMESERVER\n";
print NSUPDATE "update delete $HOST A\n";
print NSUPDATE "update add $HOST $TTL A $WAN\n";
#print NSUPDATE "show\n";
print NSUPDATE "send\n";
close (NSUPDATE);
