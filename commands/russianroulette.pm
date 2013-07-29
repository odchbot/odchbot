package russianroulette;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";
use DCBSettings;

sub main {
  my $command = shift;
  my $user = shift;

  my @return = ();
  my $message = "";
  my $num_barrels = 6;

  my $barrel = DCBSettings::get_config('russianroulette_barrel');

  if ($barrel == 0) {
    $message = "BANG\!";
    # Load a bullet and spin to a random barrel
    $barrel = int(rand($num_barrels));
    @return = (
      {
        param => "message",
        message => $message,
        user => '',
        touser => '',
        type => 4,
      },
      {
        param => "action",
        action => "kick",
        arg => $message,
        user => $user->{name},
      },
    );
  } else {
    $message = "Click\!";
    $barrel--;
    @return = (
      {
        param => "message",
        message => $message,
        user => '',
        touser => '',
        type => 4,
      },
    );
  }

  # Update current cocked barrel
  DCBSettings::config_set('russianroulette_barrel', $barrel);

  return @return;
}

1;
