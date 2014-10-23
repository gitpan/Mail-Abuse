package Mail::Abuse;

require 5.005_62;

use strict;
use warnings;

require Exporter;

				# The code below should be in a single line

our $VERSION = do { my @r = (q$Revision: 1.18 $ =~ /\d+/g); sprintf " %d."."%03d" x $#r, @r };

"I'm just a placeholder module";

__END__

=head1 NAME

Mail::Abuse - Helps parse and respond to miscellaneous abuse complaints

=head1 SYNOPSIS

  use Mail::Abuse;

=head1 DESCRIPTION

This module and the accompaining software can be used to automatically
parse and respond to various formats of abuse complaints. This
software is geared towards abuse desk administrators who need
sophisticated tools to deal with the complains.

C<Mail::Abuse> is actually a bundle of modules that provide various
services. This documentation provides a general description of the
functions provided by each one. No useful code is provide in the
C<Mail::Abuse> module, appart from this documentation and the version
information below.

The following classes/packages are part of this distribution.

=over

=item C<Mail::Abuse::Report>

A report is a collection made of the received report and ths incidents
it describes. See L<Mail::Abuse::Report> for more information.

=item C<Mail::Abuse::Incident>

An incident is each of the individual policy violations that are
presented in a given report. A report should have at least, one
incident. See L<Mail::Abuse::Incident> for more information.

=item C<Mail::Abuse::Processor>

Once the reports are analyzed and its incidents are extracted, you
will want to do something with the information. This is the job of a
processor. See L<Mail::Abuse::Processor> for more information.

=item C<Mail::Abuse::Reader>

Abuse reports can be fetched from a variety of places and through
various protocols. This is what readers do: Read a report. See
L<Mail::Abuse::Reader> for more information.

=item C<Mail::Abuse::Filter>

An abuse report might contain incidents that are not to be handled by
us. A filter remove incidents that does not belong to our network. See
L<Mail::Abuse::Filter> for more information.

=back

All of the modules take a lot of their configuration information from
a specially formatted file.

This distribution also includes a number of scripts. See the C<bin/>
directory for more information.

=head2 EXPORT

None by default.


=head1 HISTORY

$Log: Abuse.pm,v $
Revision 1.18  2004/02/16 17:20:29  lem
Freeze for next release

Revision 1.17  2004/02/15 19:39:42  lem
Changes to ::Incident::Log. Added requester. Changed doc structure to
include the CVS log in the docs, altough this is not that useful for
this module.


=head1 LICENSE AND WARRANTY

This code and all accompanying software comes with NO WARRANTY. You
use it at your own risk.

This code and all accompanying software can be used freely under the
same terms as Perl itself.

=head1 AUTHOR

Luis E. Mu�oz <luismunoz@cpan.org>

=head1 SEE ALSO

perl(1).

=cut
