package Mail::Abuse::Processor::TableDBI;

require 5.005_62;

use DBI;
use Carp;
use strict;
use warnings;
use NetAddr::IP;

use base 'Mail::Abuse::Processor';

				# The code below should be in a single line

our $VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf " %d."."%03d" x $#r, @r };

=pod

=head1 NAME

Mail::Abuse::ProcessorTableDBI - Match incidents to other data using a DBI table

=head1 SYNOPSIS

  use Mail::Abuse::ProcessorTableDBI;

  use Mail::Abuse::Report;
  my $p = new Mail::Abuse::ProcessorTableDBI;
  my $report = new Mail::Abuse::Report (processors => [ $p ]);

  # ... other pieces of code that configure the report ...

=head1 DESCRIPTION

This class matches incidents to data gathered into a DBI table.

=over

=item B<debug dbi table>

If set to a true value, causes this module to emit debugging info
using C<warn()>.

=cut

use constant DEBUG	=> 'debug dbi table';

=pod

=item B<dbi table dsn>

Specifies the DSN used to connect to the DBI database holding the
table we will be using.

=cut

use constant DSN	=> 'dbi table dsn';

=pod

=item B<dbi table user>

The username used to connect to the DSN. If specified in the DSN
itself, can be left blank.

=cut

use constant USER	=> 'dbi table user';

=pod

=item B<dbi table pass>

The password used to connect to the DSN. If specified in the DSN, it
can be left blank. Note that this is not good, as the DSN will be
printed along DBI-related error messages.

=cut

use constant PASS	=> 'dbi table pass';

=pod

=item B<dbi table name>

The name of the table to query. This table must define the following
columns.

=over

=item B<CIDR_Start>

The beginning of the CIDR range for which the remaining columns
apply. This is supposed to be the network IP address, as an unsigned
int.

=item B<CIDR_End>

The end of the CIDR range for which the remaining columns apply. This
is supposed to be the broadcast IP address, as an unsigned int.

=item B<TIME_Start>

The number of seconds since the epoch for the start of the time window
in which this entry is valid.

=item B<TIME_End>

The number of seconds since the epoch for the end of the time window
in which this entry is valid.

=back

The rest of the columns will be included in the resulting information
stored into the incident. For instance, a column named "Foo" will
cause the following structure to be added to the incident

    { Foo => column contents }

This is similar to the way in which L<Mail::Abuse::Processor::Table>
works.

=cut

use constant TABLE	=> 'dbi table name';

# Perform initialization of the DBI connection and fetch the
# information we need for the subsequent queries. Caching is
# done to prevent spurious connect/disconnect cycles.

sub _init_dbi
{
    my $self	= shift;
    my $rep	= shift;

    my $dsn	= $rep->config->{&DSN};
    my $user	= $rep->config->{&USER};
    my $pass	= $rep->config->{&PASS};
    my $table	= $rep->config->{&TABLE};
    my $debug	= $rep->config->{&DEBUG};

    return if $self->{_table_dbi}->{dbh};

    # Perform the connection and prepare - die on failure

    $self->{_table_dbi}->{dbh} = DBI->connect($dsn, $user, $pass,
					      { RaiseError => 1 });
    die "Failed to connect to $dsn: $DBI::errstr\n" 
	unless $self->{_table_dbi}->{dbh};

    $self->{_table_dbi}->{table} = $table;

    # Prepare the query that we will be using all the time,
    # for speed

    my $q_sql = qq{
	
	SELECT * FROM $table
	WHERE
	  ? >= CIDR_Start
	  AND ? <= CIDR_End
	  AND ? >= CIDR_Start
	  AND ? <= CIDR_End
	  AND ? >= TIME_Start
	  AND ? <= TIME_End
	ORDER BY TIME_Start DESC;
	
    };

    if ($debug)
    {
	warn "TableDBI: Query is:\n$q_sql\n\n";
    }

    $self->{_table_dbi}->{q_sth} = $self->{_table_dbi}->{dbh}->prepare($q_sql);

    undef;
}

=pod

=back

The following functions are implemented.

=over

=item C<process($report)>

Takes a C<Mail::Abuse::Report> object as an argument and, for each
C<Mail::Abuse::Incident> collected, perform a lookup in the given
table, attempting to match it by IP address and timestamp.

If a match is found, all the columns found in the DBI query, are 
added to the incident.

=cut

sub process
{
    my $self	= shift;
    my $rep	= shift;

    unless ($rep->config or ref $rep->config ne 'HASH')
    {
	warn "Invalid or no config";
	return;
    }

    my $dsn	= $rep->config->{&DSN};
    my $debug	= $rep->config->{&DEBUG};

    $self->_init_dbi($rep);

    # For each incident...

    for my $i (@{$rep->incidents})
    {
	{		
	    # Execute the query with the required data
	    $self->{_table_dbi}->{q_sth}->execute
		(scalar $i->ip->network->numeric,
		 scalar $i->ip->network->numeric,
		 scalar $i->ip->broadcast->numeric,
		 scalar $i->ip->broadcast->numeric,
		 $i->time || 0,
		 $i->time || 0);

	    my $result = $self->{_table_dbi}->{q_sth}->fetchrow_hashref;
	    $self->{_table_dbi}->{q_sth}->finish;

	    unless ($result)
	    {
		warn "TableDBI: Incident (", $i->ip, ", ", $i->time, 
		") did not match\n" 
		    if $debug;
		next;
	    }

	    if ($debug)
	    {
		warn "TableDBI: Incident (", $i->ip, ", ", $i->time, 
		") matched with results:\n";
		while (my ($k, $v) = each %$result)
		{
		    print "  $k => $v\n";
		}
	    }

	    $i->tabledbi({}) unless $i->tabledbi;
	    $i->tabledbi->{$_} = $result->{$_} for keys %$result;
	}
    }
    return 1;


    # Perform the query

    # Update the incident if matched
}

__END__

=pod

=back

=head2 EXPORT

None by default.


=head1 HISTORY

$Log: TableDBI.pm,v $
Revision 1.1  2005/06/09 16:03:46  lem
First version, ready for beta testing



=head1 LICENSE AND WARRANTY

This code and all accompanying software comes with NO WARRANTY. You
use it at your own risk.

This code and all accompanying software can be used freely under the
same terms as Perl itself.

=head1 AUTHOR

Luis E. Muñoz <luismunoz@cpan.org>

=head1 SEE ALSO

Mail::Abuse::Processor::Table(3), perl(1).

=cut
