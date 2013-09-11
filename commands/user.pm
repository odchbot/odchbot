package user;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";
use DCBSettings;
use DCBDatabase;
use DCBCommon;
use DCBUser;

sub postlogin {
  my $command = shift;
  my $user = shift;
  my @return = ();
  my $hubname = DCBSettings::config_get('hubname');
  my $topic = DCBSettings::config_get('topic');
  if ($user->{new}) {
    @return = (
      {
        param    => "message",
        message  => "Welcome to $hubname for the first time: $user->{name}",
        user     => '',
        fromuser   => '',
        type     => 4,
      },
    );
  }
  else {
    @return = (
      {
        param    => "message",
        message  => "Welcome back to $hubname $user->{name}\nThe current topic is: $topic",
        user     => $user->{name},
        fromuser   => '',
        type     => 2,
      },
    );
  }
  # Provide the user with additional welcome information
  my $permissions = DCBUser::PERMISSIONS;
  my %perm = %{$permissions};
  my $perm = 'UNKNOWN';
  foreach my $val (keys %perm) {
    if ($perm{$val} == $user->{permission}) {
      $perm = $val;
    }
  }

  my $member_time = DCBCommon::common_timestamp_duration($user->{'join_time'});
  my $share_delta = DCBCommon::common_format_size($user->{'connect_share'} - $user->{'join_share'});

  my $welcome = "\n" . ('-' x 70) . "\n";
  $welcome .= "***===[ $user->{'name'} :: $perm :: $user->{'client'} ]===***\n***===[ Member for: $member_time :: Share delta: $share_delta ]===***\n";
  $welcome .= '-' x 70;

  my @login = (
    {
      param    => "message",
      message  => $welcome,
      user     => $user->{name},
      fromuser   => '',
      type     => 2,
    },
  );

  push(@return, @login);

  return @return;
}

sub prelogin {
  my $command = shift;
  my $user = shift;
  return;
}

sub logout {

}

1;