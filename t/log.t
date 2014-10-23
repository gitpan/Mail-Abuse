
# $Id: log.t,v 1.10 2004/02/17 11:48:47 lem Exp $

use Test::More;

$ENV{TZ} = 'GMT';		# Set a default timezone

our @msgs = ();

{
    local $/ = "*EOM\n";
    push @msgs, <DATA>;
}

our $msg = 0;
my $loaded = 0;
my $tests = 10 * @msgs;

package MyReader;
use base 'Mail::Abuse::Reader';
sub read
{ 
  main::ok(1, "Read message $main::msg");
    $_[1]->text(\$main::msgs[$main::msg++]); 
    return 1;
}
package main;

package MyReport;
use base 'Mail::Abuse::Report';
sub new { bless {}, ref $_[0] || $_[0] };
package main;

plan tests => $tests;

SKIP:
{
    eval { use Mail::Abuse::Incident::Normalize; $loaded = 1; };
    skip 'Mail::Abuse::Incident::Normalize failed to load (FATAL)', $tests
	unless $loaded;

    $loaded = 0;

    eval { use Mail::Abuse::Incident::Log; $loaded = 1; };
    skip 'Mail::Abuse::Incident::Log failed to load (FATAL)', $tests
	unless $loaded;

    my $rep = MyReport->new;
    $rep->reader(MyReader->new);
    $rep->filters([]);
    $rep->processors([]);
    $rep->config({});
#    $rep->config->{'debug log'} = 1;

    for my $p ([new Mail::Abuse::Incident::Normalize, 
		new Mail::Abuse::Incident::Log],
	       [new Mail::Abuse::Incident::Log])
    {
	$msg = 0;			# Retry all the messages
	$rep->parsers($p);
    
	for my $m (@msgs)
	{
	    isa_ok($rep->next, 'MyReport');
	    is(@{$rep->incidents}, 1, 'Correct number of incidents reported');
	    for (@{$rep->incidents})
	    {
		unless (is($_->time, 1066947216) 
			and is($_->ip, NetAddr::IP->new('10.10.10.10')))
		{
		    diag $ {$rep->text};
		}
	    }
	}
    }
}


__DATA__
Return-Path: <updatestatusonly@mynetwatchman.com>
Message-Id: <200310310151.h9V5555555557770@lidiot.mynetwatchman.com>
From: myNetWatchman <updatestatusonly@mynetwatchman.com>
To: "abuse@somewhere.net" <abuse@somewhere.net>
Errors-To: <mnwbounce@mynetwatchman.com>
Date: Thu, 30 Oct 2003 20:40 -0400
X-Msmail-Priority: Normal
Reply-To: updatestatusonly@mynetwatchman.com
Subject: myNetWatchman Incident [54049036] Src:(x.x.x.x) Targets:10
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

rbooth, 23 Oct 2003 18:13:36 -0400, 10.10.10.10, 17, 137, W32.Opaserv Worm?, 1033, 1



23 Oct 2003 18:13:36 -0400 popoah: ipfw DENY from 10.10.10.10
*EOM
Return-Path: <updatestatusonly@mynetwatchman.com>
Message-Id: <200310310151.h9V5555555557770@lidiot.mynetwatchman.com>
From: myNetWatchman <updatestatusonly@mynetwatchman.com>
To: "abuse@somewhere.net" <abuse@somewhere.net>
Errors-To: <mnwbounce@mynetwatchman.com>
Date: Thu, 30 Oct 2003 20:40 -0400
X-Msmail-Priority: Normal
Reply-To: updatestatusonly@mynetwatchman.com
Subject: myNetWatchman Incident [54049036] Src:(x.x.x.x) Targets:10
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

rbooth, 
23 Oct 2003 18:13:36 -0400, 
10.10.10.10, 17, 
137, W32.Opaserv Worm?, 1033, 1




23 Oct 2003 18:13:36 -0400
popoah: 
ipfw DENY from 10.10.10.10
*EOM
Return-Path: <updatestatusonly@mynetwatchman.com>
Message-Id: <200310310151.h9V5555555557770@lidiot.mynetwatchman.com>
From: myNetWatchman <updatestatusonly@mynetwatchman.com>
To: "abuse@somewhere.net" <abuse@somewhere.net>
Errors-To: <mnwbounce@mynetwatchman.com>
Date: Thu, 30 Oct 2003 20:40 -0400
X-Msmail-Priority: Normal
Reply-To: updatestatusonly@mynetwatchman.com
Subject: myNetWatchman Incident [54049036] Src:(x.x.x.x) Targets:10
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

rbooth, 
23 Oct 2003 18:13:36 -0400, 
10.10.10.10, 17, 
137, W32.Opaserv Worm?, 1033, 1




Oct, 23 2003  6:13:36 PM -0400
popoah: 
ipfw DENY from 10.10.10.10
*EOM
Return-Path: <updatestatusonly@mynetwatchman.com>
Message-Id: <200310310151.h9V5555555557770@lidiot.mynetwatchman.com>
From: myNetWatchman <updatestatusonly@mynetwatchman.com>
To: "abuse@somewhere.net" <abuse@somewhere.net>
Errors-To: <mnwbounce@mynetwatchman.com>
Date: Thu, 30 Oct 2003 20:40 -0400
X-Msmail-Priority: Normal
Reply-To: updatestatusonly@mynetwatchman.com
Subject: myNetWatchman Incident [54049036] Src:(x.x.x.x) Targets:10
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

rbooth, 
23 Oct 2003 18:13:36 -0400, 
10.10.10.10, 17, 
137, W32.Opaserv Worm?, 1033, 1




Oct, 23 2003 6:13:36 PM -0400
popoah: 
ipfw DENY from 10.10.10.10
*EOM
Return-Path: <updatestatusonly@mynetwatchman.com>
Message-Id: <200310310151.h9V5555555557770@lidiot.mynetwatchman.com>
From: myNetWatchman <updatestatusonly@mynetwatchman.com>
To: "abuse@somewhere.net" <abuse@somewhere.net>
Errors-To: <mnwbounce@mynetwatchman.com>
Date: Thu, 30 Oct 2003 20:40 -0400
X-Msmail-Priority: Normal
Reply-To: updatestatusonly@mynetwatchman.com
Subject: myNetWatchman Incident [54049036] Src:(x.x.x.x) Targets:10
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

rbooth, 
23 Oct 2003 18:13:36 -0400, 
10.10.10.10, 17, 
137, W32.Opaserv Worm?, 1033, 1




Tue, 23 Oct 2003 18:13:36 -0400
popoah: 
ipfw DENY from 10.10.10.10
*EOM
Return-Path: <updatestatusonly@mynetwatchman.com>
Message-Id: <200310310151.h9V5555555557770@lidiot.mynetwatchman.com>
From: myNetWatchman <updatestatusonly@mynetwatchman.com>
To: "abuse@somewhere.net" <abuse@somewhere.net>
Errors-To: <mnwbounce@mynetwatchman.com>
Date: Thu, 30 Oct 2003 20:40 -0400
X-Msmail-Priority: Normal
Reply-To: updatestatusonly@mynetwatchman.com
Subject: myNetWatchman Incident [54049036] Src:(x.x.x.x) Targets:10
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

end of submission -------------------------------------------------
Received: from [10.10.10.10] by daver.bungi.com via sendmail with smtp;
  Tue, 23 Oct 2003 18:13:36 -0400 (EST)





Return-Path: Received: from 10.10.10.10 ([10.10.10.10]) by sparc.xsite.tld with QMQP; Oct, 23 2003 06:13:36 PM -0400
*EOM
Return-Path: <updatestatusonly@mynetwatchman.com>
Message-Id: <200310310151.h9V5555555557770@lidiot.mynetwatchman.com>
From: myNetWatchman <updatestatusonly@mynetwatchman.com>
To: "abuse@somewhere.net" <abuse@somewhere.net>
Errors-To: <mnwbounce@mynetwatchman.com>
Date: Thu, 30 Oct 2003 20:40 -0400
X-Msmail-Priority: Normal
Reply-To: updatestatusonly@mynetwatchman.com
Subject: myNetWatchman Incident [54049036] Src:(x.x.x.x) Targets:10
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

end of submission -------------------------------------------------
Received: from [10.10.10.10] by daver.bungi.com via sendmail with smtp;
  Tue, 23 Oct 2003 18:13:36 -0400 (EST)





Return-Path: Received: from 10.10.10.10 ([10.10.10.10]) by sparc.xsite.tld with QMQP; Oct, 23 2003 6:13:36 PM -0400
*EOM
Return-Path: <updatestatusonly@mynetwatchman.com>
Message-Id: <200310310151.h9V5555555557770@lidiot.mynetwatchman.com>
From: myNetWatchman <updatestatusonly@mynetwatchman.com>
To: "abuse@somewhere.net" <abuse@somewhere.net>
Errors-To: <mnwbounce@mynetwatchman.com>
Date: Thu, 30 Oct 2003 20:40 -0400
X-Msmail-Priority: Normal
Reply-To: updatestatusonly@mynetwatchman.com
Subject: myNetWatchman Incident [54049036] Src:(x.x.x.x) Targets:10
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

end of submission -------------------------------------------------
Received: from [10.10.10.10] by daver.bungi.com via sendmail with smtp;
  Tue, 23 Oct 2003 18:13:36 -0400 (EST)





Return-Path: Received: from 10.10.10.10 ([10.10.10.10]) by sparc.xsite.tld with QMQP; Oct, 23 2003  6:13:36 PM -0400

*EOM
Return-Path: <updatestatusonly@mynetwatchman.com>
Message-Id: <200310310151.h9V5555555557770@lidiot.mynetwatchman.com>
From: myNetWatchman <updatestatusonly@mynetwatchman.com>
To: "abuse@somewhere.net" <abuse@somewhere.net>
Errors-To: <mnwbounce@mynetwatchman.com>
Date: Thu, 30 Oct 2003 20:40 -0400
X-Msmail-Priority: Normal
Reply-To: updatestatusonly@mynetwatchman.com
Subject: myNetWatchman Incident [54049036] Src:(x.x.x.x) Targets:10
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



10.10.10.10 - - [23/Oct/2003:18:13:36 -0400] "GET / HTTP/1.1" 200 804





10.10.10.10 - - [23/Oct/2003:18:13:36 -0400] "GET 

