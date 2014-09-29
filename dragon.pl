#!/usr/bin/env perl

use strict;
use warnings;

#use Log::Log4perl qw(:easy); # Also gives additional debug info back from bot.
use Net::Jabber::Bot;
use Data::Dumper;

use DCBSettings;
use DCBDatabase;
use DCBCommon;
use DCBUser;
use Data::Dumper;

eval {
  our $Settings = new DCBSettings;
  $Settings->config_init();

  our $Database = new DCBDatabase;
  $Database->db_init();

  our $Common = new DCBCommon;
  $Common->common_init();
  $Common->commands_init();

  our $User = new DCBUser;
  $User->user_init('');

  # odch_hooks('init');
};
if ($@) {
  #jabber_sendmessage("","",4,"$@");
  #jabber_debug("init","","$@");
  #die;
}

# Init log4perl based on command line options
my %log4perl_init;
$log4perl_init{'cron'}     = 1 if(defined $ARGV{'-cron'});
$log4perl_init{'nostdout'} = 1 if(defined $ARGV{'-nostdout'});
$log4perl_init{'log_file'} = $ARGV{'-logfile'} if(defined $ARGV{'-logfile'});
$log4perl_init{'email'} = $ARGV{'-email'} if(defined $ARGV{'-email'});
$log4perl_init{'debug_level'} = $ARGV{'-debuglevel'};
#InitLog4Perl(%log4perl_init);

my $jabber  = $DCBSettings::config->{jabber};

my %alerts_sent_hash;
my %next_alert_time_hash;
my %next_alert_increment;

my %forums_and_responses;
foreach my $forum (@{ $jabber->{forums} }) {
  my $responses = "bot:|lol hai|"; # Note the pipe at the end indicates it will act on all messages
  my @response_array = split(/\|/, $responses);
  push @response_array, "" if($responses =~ m/\|\s*$/);
  $forums_and_responses{$forum} = \@response_array;
}

my $bot = Net::Jabber::Bot->new(
  server => $jabber->{server},
  conference_server => $jabber->{conference_server},
  port => $jabber->{port},
  username => $jabber->{username},
  password => $jabber->{password},
  safety_mode => 1,
  message_function => \&new_bot_message,
  background_function => \&background_checks,
  forums_and_responses => \%forums_and_responses,
  alias => $DCBSettings::config->{botname},
  ignore_server_messages => 1,
  ignore_self_messages => 1,
);


foreach my $forum (@{ $jabber->{forums} }) {
#    $bot->SendGroupMessage($forum, "$alias logged into $forum");
}

sub background_checks {
# bot_object
#ROSTERDB->JIDS
#PRESENCEDB
}

sub new_bot_message {
  my %bot_message_hash = @_;
  $bot_message_hash{'sender'} = $bot_message_hash{'from_full'};
  $bot_message_hash{'sender'} =~ s{^.+\/([^\/]+)$}{$1};
  if ($bot_message_hash{'sender'} !~ $DCBSettings::config->{botname}) {
    if ($bot_message_hash{body} =~ /^(.*\s)?apac(\s.*)?$/i && $bot_message_hash{reply_to} =~ 'apj@conference.acquia.com') {
      $bot->SendGroupMessage($bot_message_hash{reply_to}, "The preferred name is APJ thank you please.");
    }
    if (($bot_message_hash{body} =~ /^(.*[\s\W])?apac([\s\W].*)?$/im || $bot_message_hash{body} =~ /^(.*[\s\W])?apj([\s\W].*)?$/im) && $bot_message_hash{reply_to} =~ 'support@conference.acquia.com') {
      $bot->SendGroupMessage($bot_message_hash{reply_to}, "APJ == Best Region");
    }
  }
}

$bot->Start(); #Endless loop where everything happens after initialization.

# DEBUG("Something's gone horribly wrong. Jabber bot exiting...");
exit;


