package stats;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";
use Clone qw(clone);
use DCBDatabase;
use DCBCommon;

sub schema {
  my %schema = (
    schema => ({
      stats => {
        sid => {
          type          => "INTEGER",
          not_null      => 1,
          primary_key   => 1,
          autoincrement => 1,
        },
        time => { type => "INT", },
        number_users  => { type => "INT", },
        total_share => { type => "BLOB", },
        connections => { type => "INT", },
        disconnections => { type => "INT", },
        searches => { type => "INT", },
      },
    }),
  );
  return \%schema;
}

sub init {
  # Record when the hub started and insert bot information as the first record so it has a UID
  my %fields = ( 'time' => time(), number_users => 0, total_share => 0, connections => 0, disconnections => 0, searches => 0 );
  DCBDatabase::db_insert( 'stats', \%fields );

  my %where = ();
  my @fields = ('*');
  my $order = {-desc => 'sid'};
  my $statsh = DCBDatabase::db_select('stats', \@fields, \%where, $order);
  $DCBCommon::COMMON->{stats}->{hubstats} = $statsh->fetchrow_hashref();
}

sub main {
  my $command = shift;
  my $user = shift;
  my $chat = shift;

  my @return = ();

  my $message = "Hub Stats:
  'sid' => $DCBCommon::COMMON->{stats}->hubstats}->{sid},
  'disconnections' => $DCBCommon::COMMON->{stats}->{hubstats}->{disconnections},
  'total_share' => $DCBCommon::COMMON->{stats}->{hubstats}->{total_share},
  'connections' => $DCBCommon::COMMON->{stats}->{hubstats}->{connections},
  'time' => $DCBCommon::COMMON->{stats}->{hubstats}->{time},
  'number_users' => $DCBCommon::COMMON->{stats}->{hubstats}->{number_users},
  'searches' => $$DCBCommon::COMMON->{stats}->{hubstats}->{searches},
  ";

  @return = (
    {
      param    => "message",
      message  => "$message",
      user     => $user->{name},
      touser   => '',
      type     => 4,
    },
  );
  return @return;
}

sub timer {
  my $stats = clone ($DCBCommon::COMMON->{stats}->{hubstats});
  delete($stats->{sid});
  $stats->{time} = time();
  db_insert('stats', $stats);
  return;
}


1;
