package Mail::Abuse::Incident::Log;

require 5.005_62;

use Carp;
use strict;
use warnings;
use NetAddr::IP;
use Date::Parse;

use base 'Mail::Abuse::Incident';

				# The code below should be in a single line

our $VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf " %d."."%03d" x $#r, @r };

=pod

=head1 NAME

Mail::Abuse::Incident::Log - Parses generic logs into Mail::Abuse::Reports

=head1 SYNOPSIS

  use Mail::Abuse::Report;
  use Mail::Abuse::Incident::Log;

  my $i = new Mail::Abuse::Incident::Log;
  my $report = new Mail::Abuse::Report (incidents => [$i] );

=head1 DESCRIPTION

This class parses generic logs that include a timestamp and an IP
address in the same line. The following functions are provided for the
customization of the behavior of the class.

=cut

=over

=item C<parse($report)>

Pushes all instances of log incidents into the given report, based
on parsing of the text in the report itself.

Returns a list of objects of the same class, with the incident data
(IP address, timestamp and other information) filled.

The IP address and timestamp searching is done in a consecutive number
of lines. This number can be set with the C<log lines> variable, and
defaults to 5 lines.

This module tends to get a significant number of, potentially false,
incidents out of reports. Adjust the number of lines carefully based
on the types of complaints that your site receives.

=cut

sub _push ($$$$$$)
{
    my $self	= shift;
    my $rep	= shift;
    my $ip	= shift;
    my $date	= shift;
    my $data	= shift;
    my $subtype	= shift;
    my $ret	= shift;

    my $i = $self->new();
    $i->ip($ip);
    $i->time($date);
    $i->type("log/$subtype");
    $i->data($data || 'no data');

    return 
	if grep { $i->ip eq $_->ip 
		      and $i->time == $_->time 
			  and $i->type eq $_->type } @$ret;

    push @$ret, $i;

#    warn "_push $ip $date, ret=", scalar @$ret, "\n";

    return $i;
}

sub _add_ip ($$)
{
    my $ip = new NetAddr::IP $_[1] or return;

    for (@{$_[0]})
    {
	return if $_ == $ip;
    }
    push @{$_[0]}, $ip;
#    warn "# _add_ip $_[1], ret=", scalar @{$_[0]}, "\n";
}

sub _add_time ($$$)
{
    my $time = str2time($_[1], $_[2]) or return;

    for (@{$_[0]})
    {
	return if $_ == $time;
    }
    push @{$_[0]}, $time;
#    warn "# _add_time $_[1] $_[2], ret=", scalar @{$_[0]}, "\n";
}

sub parse
{
    my $self	= shift;
    my $rep	= shift;

    my @ret = ();		# Default return
    my $count = 0;

    my $text = undef;
    my $lines = ($rep->config ? $rep->config->{'log lines'} : '') || 5;

    my $subtype;

#    $lines --;

    if ($rep->normalized)
    {
	$text = $rep->body;
    }
    else
    {
	$text = $rep->text;
    }

    return unless $$text;
				# Attempt to guess a type of log by
				# searching for keywords

    if ($$text =~ m/\W(virus|scan|ids|intrussion|worm|firewall)\W/i
	or $$text =~ m/^(virus|scan|ids|intrussion|worm|firewall)\W/mi
	or $$text =~ m/\W(virus|scan|ids|intrussion|worm|firewall)$/mi
	or $$text =~ m/^(virus|scan|ids|intrussion|worm|firewall)$/mi)
    {
	$subtype = 'network';
    }
    elsif ($$text =~ m/\W(copyright|infringement|rights|media)\W/i
	   or $$text =~ m/^(copyright|infringement|rights|media)\W/mi
	   or $$text =~ m/\W(copyright|infringement|rights|media)$/mi
	   or $$text =~ m/^(copyright|infringement|rights|media)$/mi)
    {
	$subtype = 'copyright';
    }
    elsif ($$text =~ m/\W(spam|uce|unsolicited|mass)\W/i
	   or $$text =~ m/^(spam|uce|unsolicited|mass)\W/mi
	   or $$text =~ m/\W(spam|uce|unsolicited|mass)$/mi
	   or $$text =~ m/^(spam|uce|unsolicited|mass)$/mi)
    {
	$subtype = 'spam';
    }
    else
    {
	$subtype = '*';
    }

    my @time;			# List of timestamps
    my @addr;			# List of IP addresses

    for my $skip (0..$lines-1)
    {
	$$text =~ m!^!g;
	$$text =~ m!(([^\n]*\n){$skip,$skip})!g;

#	warn ((map { s/^/\# skip $skip>/m; $_ . "\n" } split (/\n/, $1)), "# ***\n");
	
	while ($$text =~ m!^(([^\n]*\n)(([^\n]*\n){0,$lines})?)!mg)
	{

#	    warn "# clear \@time and \@addr\n" if @time or @addr;

	    @time = ();
	    @addr = ();

	    my $line = $1;
#	    warn ((map { s/^/\# /; $_ . "\n" } split (/\n/, $line)), "\n# ***\n");

	    _add_ip \@addr, $1 while $line =~ m/(\d+\.\d+\.\d+\.\d+)/g;

				# dd:mm:yyyyyThh:mm:ss.ssss
	    _add_time \@time, $1, $rep->tz
		while $line =~ m/(\d+[:-]\d+[:-]\d+T[\d:\.]+)/g;
				# day,  5 Oct 2000 hh:mm:ss: +0700
	    _add_time \@time, $1, $rep->tz 
		while $line =~ m/((\w+,\s+)?\d+\s\w+\s\d+\s[\d:]+(\s[-+]?\w+)?)/g;
	    _add_time \@time, $1, $rep->tz 
		while $line =~ m!(\d+[/-]\d+[/-]\d+\s+\d+:\d+:\d+)!g;
	    _add_time \@time, $1, $rep->tz 
		while $line =~ m!(\d+[/-]\w+[/-]\d+\s+\d+:\d+:\d+)!g;
	    _add_time \@time, $1, $rep->tz 
		while $line =~ m!(\w+\s+\w+\s+\d+\s+\d+:\d+:\d+\s+\w+\s+\d+)!g; 
	    _add_time \@time, $1, $rep->tz 
		while $line =~ m!((\w+\s)?\w+\s+\d+\s\d+:\d+:\d+(\s\d+)?)!g; 

	    while ($line =~ m!(\d+/\d+)-(\d+:\d+:\d+)!g)
	    {
		_add_time (\@time, "$1 $2", $rep->tz);
	    }

	    while ($line =~ m!Date: (\d+-\d+-\d+), Time: (\d+:\d+:\d+)!g)
	    {
		_add_time (\@time, "$1 $2", $rep->tz);
	    }

	    if (@time or @addr)
	    {
#		warn ((map { s/^/\# match:/m; $_ . "\n" } split (/\n/, $line)), "# ***\n");
	    }

	    for my $time (@time)
	    {
		$self->_push($rep, $_, $time, $line, $subtype, \@ret) 
		    for @addr;
	    }
	}
    }
    return @ret;
}

__END__

=pod

=back

=head2 EXPORT

None by default.


=head1 HISTORY

=over 8

=item 0.01

Original version; created by h2xs 1.2 with options

  -ACOXcfkn
	Mail::Abuse
	-v
	0.01

=back


=head1 LICENSE AND WARRANTY

This code and all accompanying software comes with NO WARRANTY. You
use it at your own risk.

This code and all accompanying software can be used freely under the
same terms as Perl itself.

=head1 AUTHOR

Luis E. Muñoz <luismunoz@cpan.org>

=head1 SEE ALSO

perl(1).

=cut

