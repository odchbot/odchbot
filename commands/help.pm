package help;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/..";

sub main {
  my $command = shift;
  my $user = shift;
  my $message = "Testing bitches"
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
