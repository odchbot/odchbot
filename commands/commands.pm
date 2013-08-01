package commands;

use strict;
use warnings;
use Text::SimpleTable::AutoWidth;
use Text::Tabs;
use Storable qw(thaw);
use FindBin;
use lib "$FindBin::Bin/..";
use DCBCommon;
use DCBSettings;
use DCBUser;

use Data::Dumper;

sub main {
  my $command = shift;
  my $user = shift;
  my $chat = shift;

  my @return = ();
  # TODO potentially provide all info stored in the array if a user specifies a command
  # eg -commands kick will give all the info (basically a YAML dump)
  my @captions = ('Command', 'Description', 'Aliases');
  my $t = Text::SimpleTable::AutoWidth->new( max_width => 140, captions => \@captions );
  my $message = "\n";
  foreach my $commands (sort keys %{$DCBCommon::registry->{commands}}) {
    my $command = $DCBCommon::registry->{commands}->{$commands};
    if ($commands =~ $DCBCommon::registry->{commands}->{$commands}->{name}) {
      if (user_access($user, $command->{permissions})) {
        my $alias = '';
        if ($command->{alias}) {
          my $aliases = thaw($command->{alias});
          foreach (@$$aliases) {
            $alias .= "$_ ";
          }
        }
      $t->row(DCBCommon::common_escape_string("$DCBSettings::config->{cp}") . $command->{name}, $command->{description}, $alias);
      }
    }
  }
  $message .= $t->draw();
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
