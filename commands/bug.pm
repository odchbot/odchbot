package bug;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/..";
use Sys::Hostname;
use Mail::Sendmail;

sub main {
  my $command = shift;
  my $user = shift;
  my $chat = shift;

  my @return = ();
  my $message = 'Bug report unable to be submitted QQ';
  my $hostname = hostname;
  my %mail = ( To      => $DCBSettings::config->{maintainer_email},
            From    => "bug_report@" . $hostname,
            Subject => "[BUG REPORT] ($DCBSettings::config->{botname})",
            Message => "Submitted by: $user->{name}\nHost: $hostname\nBug Report: $chat",
          );

  if (sendmail(%mail)) {
    $message = 'Bug report successfully submitted! Thanks~~ :3';
  }
  else {
    $message = $Mail::Sendmail::error;
  }

  @return = (
    {
      param    => "message",
      message  => $message,
      user     => $user->{name},
      touser   => '',
      type     => 4,
    },
  );
  return @return;
}

1;
