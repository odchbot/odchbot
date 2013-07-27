package ban;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/..";
use DCBSettings;
use DCBCommon;
use DCBUser;
use DCBDatabase;
use Switch;

sub schema {
  my %schema = (
    schema => ({
      ban => {
        bid => {
          type          => "INTEGER",
          not_null      => 1,
          primary_key   => 1,
          autoincrement => 1,
        },
        op_uid => { type => "INTEGER" },
        uid => { type => "VARCHAR(35)" },
        time  => { type => "INT" },
        expire => { type => "INT" },
        message  => { type => "BLOB" },
      },
    }),
    config => {
      ban_default_ban_time => 300,
      ban_default_ban_message => "You are banned",
    },
  );
  return \%schema;
}

sub main {
  my $command = shift;
  my $user = shift;
  my $botmessage = '';
  my @return = ();
  my @chatarray = split(/\s+/, shift);
  if (!@chatarray) {
    $botmessage = "You must specify parameters with this command!";
  }
  else {
    my $victim = @chatarray ? $DCBUser::userlist->{shift(@chatarray)} : '';
    my $bantime = @chatarray ? shift(@chatarray) : '';
    if ($bantime =~ /^\d+([m|h|d|w|y])?$/) {
      $bantime = ban_calculate_ban_time($bantime);
    }
    else {
      $bantime = DCBSettings::config_get('tban_default_ban_time');
    }
    my $unbantime = DCBCommon::common_timestamp_time(time() + $bantime);
    my $banmessage = @chatarray ? join(' ', @chatarray) : DCBSettings::config_get('tban_default_ban_message');
    $botmessage = "$user->{'name'} is banning $victim->{'name'} until $unbantime because: $banmessage";

    # Check that the victim is actually a user
    if ($victim) {
      # If the user is lower permission than the victim, make the kick fail
      if ($user->{'permission'} >= $victim->{'permission'}) {
        @return = (
          {
            param    => "message",
            message  => "You are being banned by $user->{'name'} until $unbantime because: " . $banmessage,
            user     => $victim->{name},
            touser   => '',
            type     => 8,
          },
          {
            param    => "message",
            message  => "You are being banned by $user->{'name'} until $unbantime because: " . $banmessage,
            user     => $victim->{name},
            touser   => '',
            type     => 2,
          },
          {
            param    => "message",
            message  => $botmessage,
            user     => $victim->{name},
            touser   => '',
            type     => 4,
          },
          {
            param    => "log",
            action   => "ban",
            arg      => $botmessage,
            user     => $user,
          },
        );
        if (DCBSettings::config_get('ban_handler') =~ 'bot') {
          # We handle the ban in the bot rather than allow ODCH to handle
          my $expire = $bantime == '-1' ? '-1' : time() + $bantime;
          my %fields = (
            'op_uid' => $user->{uid},
            'uid' => $victim->{uid},
            'time' => time(),
            'expire' => $expire,
            'message' => $banmessage,
          );
          DCBDatabase::db_insert('ban', \%fields);
        }
        else {
          my @nickban = (
            {
              param    => "action",
              user     => $victim->{name},
              action   => 'nickban',
              arg      => $bantime,
            },
          );
          push(@return, @nickban);
        }
          my @kick = (
            {
              param    => "action",
              user     => $victim->{name},
              action   => 'kick',
            },
          );
        push(@return, @kick);
        return(@return);
      }
      else {
        $botmessage = DCBSettings::config_get('no_perms');
      }
    }
    else {
      $botmessage = "User does not exist or is offline";
    }
  }

  @return = (
    {
      param    => "message",
      message  => $botmessage,
      user     => $user->{name},
      touser   => '',
      type     => 4,
    },
  );
  return @return;
}

sub prelogin {
  my $command = shift;
  my $user = shift;
  # Check early if we're even using the bot as a ban handler to 
  # ensure we don't query without cause
  if (DCBSettings::config_get('ban_handler') =~ 'bot') {
    if (ban_check_fast($user)) {
      my @fields = ('op_uid', 'time', 'message', 'expire');
      my %where = ('uid' => $user->{uid});
      my $banh = DCBDatabase::db_select('ban', \@fields, \%where);
       while (my $ban = $banh->fetchrow_hashref()) {
        if ($ban->{'expire'} > time() || $ban->{'expire'} == '-1') {
          my $op = DCBUser::user_load($ban->{'op_uid'});
          my $time = DCBCommon::common_timestamp_time($ban->{'time'});
          my $expire = $ban->{'expire'} != '-1' ?  DCBCommon::common_timestamp_time($ban->{'expire'}) : 'never';

          my $banline = "\n*** BANNED ***\n";
          $banline .= "by: $op->{name}\n";
          $banline .= "at: $time\n";
          $banline .= "The reason for the ban was: $ban->{message}\n";
          $banline .= "The ban will expire: $expire\n";
          my @return = (
            {
              param    => "message",
              message  => $banline,
              user     => $user->{name},
              touser   => '',
              type     => 8,
            },
            {
              param    => "message",
              message  => $banline,
              user     => $user->{name},
              touser   => '',
              type     => 2,
            },
            {
              param    => "action",
              user     => $user->{name},
              action   => 'kick',
            },
            {
              param    => "log",
              action   => "ban",
              arg      => 'Attempted login by ' . $user->{name} . "[BANNED]",
              user     => $user,
            }
          );
          return @return;
        }
      }
    }
    return;
  }
  return;
}

sub ban_check_fast {
  # TODO use a global to keep track of bans before going to the db
  my $user = shift;
  my @fields = (1);
  my %where = ('uid' => $user->{uid});
  my $banh = DCBDatabase::db_select('ban', \@fields, \%where);
  return $banh->fetchrow_array();
}

sub ban_calculate_ban_time {
  # Normalise the bantime as seconds which works with both ODCH
  # and our custom ban implementation.
  my @bantime = split(/(\d+)(\w?)/, shift);
  my $time = $bantime[1];
  switch ($bantime[2]) {
    case 'm' { $time *= 60; }
    case 'h' { $time *= (60 * 60); }
    case 'd' { $time *= (60 * 60 * 24); }
    case 'w' { $time *= (60 * 60 * 24 * 7); }
    case 'y' { $time *= (60 * 60 * 24 * 365); }
  }

  return $time;
}

sub timer {
  my %where = ('expire' => { '<' => time() });
  DCBDatabase::db_delete('ban', \%where);
}

1;
