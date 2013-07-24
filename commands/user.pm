package user;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";
use DCBSettings;
use DCBDatabase;
use DCBUser;

use Data::Dumper;

sub postlogin {
  my $command = shift;
  my $user = shift;
  my @return = ();
  if ($user->{new}) {
    @return = (
      {
        param    => "message",
        message  => "Welcome for the first time: $user->{name}",
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
        message  => "Welcome back $user->{name}",
        user     => $user->{name},
        fromuser   => '',
        type     => 2,
      },
    );
  }
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