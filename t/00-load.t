
# $Id: 00-load.t,v 1.20 2005/03/21 23:43:30 lem Exp $

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
	Mail::Abuse::Processor::Table
	Mail::Abuse::Processor::Store
	Mail::Abuse::Processor::Score
	Mail::Abuse::Processor::Mailer
	Mail::Abuse::Processor::Radius
	Mail::Abuse::Incident::SpamCop
	Mail::Abuse::Processor::Explain
	Mail::Abuse::Incident::Received
	Mail::Abuse::Incident::Normalize
	Mail::Abuse::Processor::ArchiveDBI
	Mail::Abuse::Incident::MyNetWatchman
	/;
#	Mail::Abuse::Reader::GoogleGroups

my @paths = ();

plan tests => 2 * scalar @modules;

use_ok($_) for @modules;

my $checker = 0;

eval { require Test::Pod;
     Test::Pod::import();
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
