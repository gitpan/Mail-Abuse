package Mail::Abuse::Incident;

require 5.005_62;

use Carp;
use strict;
use warnings;

				# The code below should be in a single line

our $VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf " %d."."%03d" x $#r, @r };

=pod

=head1 NAME

Mail::Abuse::Incident - Parses a Mail::Abuse::Report to extract incidents

=head1 SYNOPSIS

  package Mail::Abuse::Incident::MyIncident;
  use Mail::Abuse::Incident;

  use base 'Mail::Abuse::Incident';
  sub ip { ... };
  sub time { ... };
  sub type { ... };
  sub data { ... };
  sub parse { ... }
  package main;

  use Mail::Abuse::Report;
  my $i = new Mail::Abuse::Incident::MyIncident;
  my $report = new Mail::Abuse::Report (incidents => [$i] );

=head1 DESCRIPTION

This class implements the reception of an abuse report and its
conversion to a C<Mail::Abuse::Report> object.

An object must respond to all the methods in the synopsis, returning
the required information about the incident (after it has been
parsed).

The following items of information have been defined:

=over

=item B<ip>

A C<NetAddr::IP> object encoding the origin of the particular
incident.

=item B<time>

A timestamp of the incident, extracted from the report. It must be a a
timestamp in the UTC timezone, for consistency.

=item B<type>

A string identifying the type of incident. Normally of the form
B<spam/SpamCom> or B<virus/Nimda>, if such filters exist.

=item B<data>

Any additional data that the class might want to keep regarding the
incident.

=back

The following functions are provided for the customization of the
behavior of the class.

=cut

sub new
{
    my $type	= shift;
    my $class	= ref($type) || $type;

    croak "Invalid call to Mail::Abuse::Incident::new"
	unless $class;

    bless {}, $class;
}

=pod

=over

=item C<parse($report)>

Pushes incidents into the given report, based on parsing of the text
in the report itself.

It must return a list of objects of the same class, with the incident data
(IP address, timestamp and other information) filled.

=cut

sub parse
{
    croak "Mail::Abuse::Incident is a virtual class";
}

				# This helps subclasses to provide accessors
				# automagically
sub AUTOLOAD 
{
    no strict "refs";
    use vars qw($AUTOLOAD);
    my $method = $AUTOLOAD;
    $method =~ s/^.*:://;
    *$method = sub 
    { 
	my $self = shift;
	my $ret = $self->{$method};
	if (@_)
	{
	    $ret = $self->{$method};
	    $self->{$method} = shift;
	}
	return $ret;
    };
    goto \&$method;
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

