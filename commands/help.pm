package help;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/..";

sub main {
  my $command = shift;
  my $user = shift;
  my $message = "Hub keeps kicking you? Try refreshing your IP /n Open Connection settings from the file menu /n Choose 'Direct connection' /n Click 'Get IP address' then OK /n Now reconnect to the hub."; 
  my @return = ();

  @return = (
    {
      param    => "message",
      message  => $message,
      user     => '',
      touser   => '',
      type     => 2,
    },
  );
  return @return;
}

1;
