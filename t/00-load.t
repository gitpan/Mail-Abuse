
# $Id: 00-load.t,v 1.11 2003/11/07 15:41:27 lem Exp $

use Test::More;

my @modules = qw/
	Mail::Abuse
	Mail::Abuse::Filter
	Mail::Abuse::Reader
	Mail::Abuse::Report
	Mail::Abuse::Incident
	Mail::Abuse::Processor
	Mail::Abuse::Filter::IP
	Mail::Abuse::Reader::POP3
	Mail::Abuse::Filter::Time
	Mail::Abuse::Reader::Stdin
	Mail::Abuse::Incident::Log
	Mail::Abuse::Processor::Store
	Mail::Abuse::Processor::Mailer
	Mail::Abuse::Incident::SpamCop
	Mail::Abuse::Incident::Received
	Mail::Abuse::Incident::Normalize
	Mail::Abuse::Incident::MyNetWatchman
	/;

my @paths = ();

plan tests => 2 * scalar @modules;

use_ok($_) for @modules;

my $checker = 0;

eval { use Test::Pod;
       $checker = 1; };

for my $m (@modules)
{
    my $p = $m . ".pm";
    $p =~ s!::!/!g;
    push @paths, $INC{$p};
}

END { unlink "./out.$$" };

SKIP: {
    skip "Test::Pod is not available on this host", scalar @paths
	unless $checker;
    pod_file_ok($_) for @paths;
}
