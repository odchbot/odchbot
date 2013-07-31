package rules;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";
use DCBSettings;

sub schema {
  my %schema = (
    config => {
      web_rules => '/rules',
    },
  );
  return \%schema;
}

sub main {
  my $command = shift;
  my $user = shift;
  my $chat = shift;

  my $website = DCBSettings::config_get('website');
  my $rules = DCBSettings::config_get('web_rules');
  my $message = 'Link to the Chaotic Neutral karma page: ' . $website . $rules;

  my @return = (
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
