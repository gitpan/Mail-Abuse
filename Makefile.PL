use ExtUtils::MakeMaker;

# $Id: Makefile.PL,v 1.14 2003/11/08 06:18:43 lem Exp $

my $checker = 0;

if ($] <= 5.006)
{
    warn <<EOT;

Your version of Perl is not supported by Params::Validate. This
warning is being produce because sometimes the code will work anyway,
though ocassional core dumps and similar problems are not unheard
of. I thought you might want to know.

Please consider upgrading your Perl to 5.6.1 or better, which seems to
be the recomendation that comes with Params::Validate. See its README
file for more information.

EOT
    ;
}

eval { use Test::Pod;
       $checker = 1; };

unless ($checker)
{
    print <<EOF;

Looks like this host does not have Test::Pod installed. Without this module,
the Pod documentation cannot be tested. This is not a big deal really, but
you might want to install Test::Mod by issuing the following command:

    perl -MCPAN -e "install('Test::Pod')"

at a nearby shell. This is nice because it allows easy tests of your own
documentation.

EOF
    ;
}

$checker = 0;

eval { use IO::Scalar;
       $checker = 1; };

unless ($checker)
{
    print <<EOF;

Looks like this host does not have IO::Scalar installed. This module
is used in some tests, but is not required for the production
code. This is not a big deal really, but you might want to install
Test::Mod by issuing the following command:

    perl -MCPAN -e "install('IO::Scalar')"

at a nearby shell. This is nice because it allows easy tests of your own
documentation.

EOF
    ;
}

WriteMakefile
    (
     'NAME'		=> 'Mail::Abuse',
     'VERSION_FROM'	=> 'lib/Mail/Abuse.pm', # finds $VERSION
     'EXE_FILES'	=> [ 'bin/abuso', 
			     'bin/acat', 
			     'bin/scan', 
			     'bin/maps-scan' ],
     'INSTALLSCRIPT'	=> '/usr/local/bin',
     'PREREQ_PM'	=> 
     {
	 'Storable'		=> 0,
	 'Net::POP3'		=> 0,
	 'Test::More'		=> 0,
	 'File::Path'		=> 0,
	 'File::Spec'		=> 0,
	 'Date::Parse'		=> 0,
	 'NetAddr::IP'		=> 3.00,
	 'Date::Manip'		=> 0,
	 'Date::Parse'		=> 0,
	 'Digest::MD5'		=> 0,
	 'MIME::Entity'		=> 0,
	 'MIME::Parser'		=> 0,
	 'HTML::Parser'		=> 0,
	 'Mail::Mailer'		=> 0,
	 'Config::Auto'		=> 0.03,
	 'Params::Validate'	=> 0,
     }, # e.g., Module::Name => 1.1
     ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM	=> 'lib/Mail/Abuse.pm',
       AUTHOR     	=> 'Luis E. Muñoz <luismunoz@cpan.org>') : ()),
     );

package MY;

sub postamble
{
    '
install ::
	@echo ==============================================================
	@echo "                           NOTICE"
	@echo ==============================================================
	@echo 
	@echo This package contains various scripts that have been installed
	@echo in /usr/local/bin. Please check the bin directory in this
	@echo distribution for specific information.
	@echo 
	@echo Each script includes its own documentation in POD. Use
	@echo 
	@echo "  perldoc bin/abuso"
	@echo "  perldoc bin/acat"
	@echo "  perldoc bin/scan"
	@echo "  perldoc bin/maps-scan"
	@echo 
	@echo to see it. Please read the documentation of each module 
	@echo thoroughly before reporting bugs or asking for help.
	@echo
	@echo Under ./etc in this distribution, you should see some config
	@echo files. Please review and edit them prior to using this
	@echo software.
';
}
