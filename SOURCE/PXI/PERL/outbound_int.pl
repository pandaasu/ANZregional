# 20131003	B.Keenan	Script creation
# Calls promax interface creation exe

use strict;
use File::Basename;

my $promaxexe = '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe"';
my $dbname = '-SPromax_PX_Test';			#Promax DB name

my $dirname = dirname(__FILE__);			#Script path
my $logfile = $dirname."\\outbound_int_log.txt";

open (LFP, ">$logfile") || die "cant open $logfile";	#overwrites log file each time its run

my %params = (
'1. Off Invoice Promotions'=>'-I359 -V0',
'2. Accruals'=>'-I325 -V0',
'3. Payments'=>'-I331 -V0'
);

for my $d (sort keys %params) {
	print LFP "$d\n-----\n";
	my $output = qx/$promaxexe $params{$d} $dbname/;	#run the exe

	if ($?) {	#check return code
		my $errorcode = $? >> 8;
		print LFP "$errorcode - Error running: $promaxexe $params{$d} $dbname\n";

		if($errorcode == 255){
			print LFP "No Transfer Required\n";
		}
		else{	   
			die "$errorcode - Error running: $promaxexe $params{$d} $dbname\n";
		}
	}
	print LFP "$output\n";
}
close(LFP);

exit;