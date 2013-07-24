#!/usr/bin/perl -w

## Put extra dependencies here.
use XML::Simple;
use LWP::Simple;
use Data::Dumper;
use HTML::Strip;

## Do not alter after this point until stated ##
use strict;
use warnings;
use Config::IniFiles;

my $ConfigFile = "/home/vps/.opendchub/scripts/chaosbot.conf";
tie my %ini, 'Config::IniFiles', (-file => $ConfigFile);
my %Config = %{$ini{"config"}};

my $x = '';
my @array = ();
my $user = $ARGV[0];
my $user_perm = $ARGV[1];
my $arg_first = $ARGV[2];
my $arg_second = $ARGV[3];
my $userip = $ARGV[4];
my $fire = $Config{fire};


if ($fire == 0 && $user_perm < 2) {
die;
}

sub output( @ ) {
  my @array = @_;
  for($x=0;$x<@array;$x++) {
    $array[$x] = $array[$x] . "Ã";
  }

  print @array;
}
## Do not alter before this point ##

## Info Block ##

#1# Command Name: weather
#2# Description: This command is used to show the weather in Canberra and a 3 day forecast.
#3# Command used by: Users
#4# Author: KY
#5# Date Created: 06/11/2011
#6# Date added to Bot: 06/11/2011

## Variables available to the script:

# User initiating the script :: $user
# Permission level of the User :: $user_perm
#	0 = Non registered
#	1 = Registered
#	2 = Op
#	3 = Admin
# args1 (The first word after the command) :: $arg_first
# args2 (The second word after the command) :: $arg_second
# eg -testcommand args1 args2

## Output values

# Fill in the required return values here and leave output(@array); as is.
# @array[0] Is the user initiating the script
# @array[1] Is the user the script acts upon
# @array[2] Is the type of message to be sent using the sendmessage function
# @array[3] Is the message to be sent back
# @array[4] If there is an odch function to be used name it here. If not leave blank or null
# @array[5] $fire determines whether or not the script actually fires.

## Message Types (for @array[2])

# The most oft used 'types' when sending to sendmessage are as follows:
# 2 Displays in main chat ONLY to the user
# 3 Sends a PM to the user
# 4 Sends to main chat for everyone

## End Info Block ##

## Place your module specific code here.

#check to see if there is a cached copy on the server
#if not, do EDIT: ignore caching it's fast enough

#Prepare html stripper
my $hs = HTML::Strip->new();

my $feed = 'http://rss.weather.com.au/act/canberra';
my $content = get($feed);
my $weather_data = XMLin($content);
my $current = $weather_data->{channel}->{item}->[0]->{'description'};
my $future = $weather_data->{channel}->{item}->[1]->{'description'};

my $c_parse = $hs->parse($current);
my $f_parse = $hs->parse($future);

$f_parse =~ s/\r//gs;
$f_parse =~ s/ +/ /gs;
$f_parse =~ s/\t*//gs;
$f_parse =~ s/[\t\n]*\n/\n/gs;
$f_parse =~ s/\n+/\n/gs;
$f_parse =~ s/:\n/: /gs;
$f_parse =~ s/\.\n/. /gs;
$f_parse =~ s/(\d)\n/$1°C\n/gs; #Adds the C and &deg; symbol
$c_parse =~ s/\t//gs;
my $message = "Weather:\nToday's weather in Canberra:" . $c_parse . "Canberra 3 day forecast:\n" . $f_parse;
$array[0] = $user;
$array[1] = "";
$array[2] = 2;
$array[3] = $message;
$array[4] = "null";
$array[5] = $fire;

## Do not alter following line
output(@array);
