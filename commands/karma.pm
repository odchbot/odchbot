#Written by Wickfish May 2013 for Chaotic Neutral
package karma;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/..";

sub main {
  my $command = shift;
  my $user = shift;
  my $chat = shift;
  my $website = DCBSettings::config_get('website');
  my $message = "Link to the Chaotic Neutral karma page: " . $website . "/karma";		

  my @return = ();
  @return = (
    {
      param    => "message",
      message  => $message,
      user     => $user->{name},
      touser   => '',
      type     => 2,
    },
  );
  return @return;
}

1;
