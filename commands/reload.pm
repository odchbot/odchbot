package reload;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";
use DCBCommon;
use Data::Dumper;

sub main {
  my $command = shift;
  my $user = shift;
  my $params = shift;
  my @return = ();
  if ($DCBCommon::registry->{commands}->{$params} || $params =~ /^\*$/) {
    if ($params =~ /^\*$/) {
      foreach my $module (keys %{$DCBCommon::registry->{commands}}) {
        $module .= '.pm';
        delete $INC{$module};
      }
    }
    else{
      my $module = $DCBCommon::registry->{commands}->{$params}->{name} . '.pm';
      delete $INC{$module};
    }
    DCBCommon::registry_rebuild($params);
    @return = (
      {
        param    => "message",
        message  => "$params reloaded.",
        user     => "",
        touser   => "",
        type     => 4,
      },
      {
        param    => "log",
        action   => "reload",
        arg      => "$params reloaded.",
        user     => $user,
      },
    );
  }
  else {
    @return = (
      {
        param    => "message",
        message  => "Unable to reload module. Ensure module exists.",
        user     => "",
        touser   => "",
        type     => 4,
      },
    );
  }

  return @return;
}


1;
