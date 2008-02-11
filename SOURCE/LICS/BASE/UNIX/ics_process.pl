#!/usr/local/bin/perl -w

################################################################################
# (C) Copyright Mars UK Ltd, 2000                                              #
################################################################################
#                                                                              #
# Module :         ics_process.pl                                              #
#                                                                              #
# Description :    Run Maestro jobs in response to MQSeries trigger messages   #
#                                                                              #
# Change History :                                                             #
#                                                                              #
# Who            When         ver    Why                                       #
# ---            ----         ---    ---                                       #
# R.Ashpole      14-Feb-2003  v3.00   Copied from hub version of               #
#                                     mqseries_maestro.pl (v2.05)              #
#                                                                              #
# R.Ashpole      14-Feb-2003  v3.01   Add TOHUB and FRMHUB to list of          #
#                                     qualifiers to remove                     #
#                                                                              #
# R.Ashpole      07-Oct-2003  v3.02   Remove calls to non-existant routines    #
#                                     LogWarn and LogError                     #
#                                                                              #
# R.Ashpole      07-Oct-2003  v3.03   Cope with the case that the job name     #
#                                     (after removal of standard prefixes)     #
#                                     is exactly 20 characters long            #
#                                                                              #
# J. Eitel        16-Jul-2004  v4.0   Added specific logging : LogInfoICS      #
#                                     Added logic for Maestro decision         #
#                                                                              #
# J. Eitel        22-Jul-2004  v4.1   Changed logging from GMT to local time   #
#                                                                              #
# J. Eitel        18-Aug-2004  v4.1   Remove non-maestro post submit logging   #
#                                     in RunCmd                                #
#                                                                              #
# J. Eitel	31-Aug-2004  v4.2          Added process id ($$) into logging    #
#                                                                              #
# J. Eitel	08-Oct-2004   v4.3        Changed non-maestro processes to run   #
#                                     using system instead of backticks        #
#                                     Changed MQSI1 maestro alias to ICSL      #
#                                                                              #
# Linden Glen   12-Apr-2005   v4.4    Altered no config match error to be      #
#                                     CRITICAL, instead of HARMLESS            #
# T. Keon           14-Nov-2007 v5.0  Added support for commands with quotes   #
#                                     and fixed warnings related to the old    #
#                                     log file function which hadnt been       #
#                                     removed                                  #
################################################################################
#
# ICS: 
#
# Notes :-
#
# 1) It is not easy to get Maestro on NT to accept scripts which have
#    parameters. The problem is a mixture of poor Maestro command syntax
#    and broken Microsoft shell programme.
#
#    To issue a conman command from the command line the manual wants you to
#    say something like...
#
#      conman "sbd ascript;alias=xyz"
#
#    (Note the quotes.) This fine if ascript does not have parameters. If
#    it has parameters then you need to put them after the script name in
#    quotes. You want to say something like...
#
#      conman "sbd "ascript p1 p2"";alias=xyz
#
#    However, I have found no way to get the CMD.EXE/CONMAN.EXE to accept
#    embedded quotes.
#
#    To get round the problem the script pipes the command into conman rather
#    than passing it as a parameter. E.g.
#
#      echo sbd "ascript p1 p2";alias=xyz | conman
#
#    For reasons best known to Microsoft the echo command does not interpret
#    characters on the command line so this works.
#
#    To get a similar effect on Unix we do
#
#      echo 'sbd "ascript p1 p2";alias=xyz' | conman
#
#    (Note the single quotes.)
#
# 2) The script contains various hard-coded paths. These should be changed
#    to suit the machine on which the script is running.
#
# 3) This script has been tested on Windows NT 4.0 SP6a, Maestro for Windows
#    5.2 and ActiveState Perl 5.00503 (Build 522).
#
#    The code ought to work on HP-UX but has not been tested there.
#

  #use strict ;
  use vars qw'$VERSION $DIR_CONFIG $DIR_SCRIPTS' ;
  use Getopt::Long ;
  use File::Spec ;
  use File::Basename ;

  if ( File::Spec->file_name_is_absolute($0) )
  {
    $abs_path = $0;
  }
  else
  {
    $abs_path = File::Spec->rel2abs($0);
  }
  
  (undef, $script_path, undef) = File::Spec->splitpath($abs_path);

  #get the parent folder to the path of this script so we can find the log, bin, config, etc folders
  #root_path should be similar to "/ics/lad/test" (note no "/" at the end of the path!)
  my $root_path = dirname($script_path);
  my $process_id = $$;
  
  my $ICS_LOG = $root_path . "/log/ics_integration.log";
  
  $| =1 ;
  $VERSION = "3.03" ;
  print "$0 version $VERSION\n";
  print "Log path: $ICS_LOG\n";

  # Parse parameters.
  my %options ;
  unless ( GetOptions( \%options, "qmgr|m=s", "queue|q=s" ) )
  {
    &PrintUsage() ;
  };
  $options{qmgr}  = uc $options{qmgr}  if exists $options{qmgr} ;
  $options{queue} = uc $options{queue} if exists $options{queue} ;

  # Now check @ARGV for a trigger message
  foreach my $x ( @ARGV )
  {
    if ( my $y = ParseTrig( $x ) )
    {
      $options{qmgr}  = $y->{QMgrName}  unless defined $options{qmgr} ;
      $options{qmgr}  = Trim( $options{qmgr} ) ;
      $options{queue} = $y->{QName}     unless defined $options{queue} ;
      $options{queue} = Trim( $options{queue} ) ;
    }
    else
    {
      &PrintUsage() ;
    };
  }; # foreach

  # The queue manager name and queue name are mandatory parameters
  unless ( defined( $options{qmgr} ) and defined( $options{queue} ) )
  {
    &PrintUsage() ;
  };

  my $q_name = $options{queue};
  
  $DIR_CONFIG = $root_path . "/config/";
  $DIR_SCRIPTS = $root_path . "/bin/";
  
  &LogInfoICS("INFO: MQ trigger triggered for [$options{queue}]/[$options{qmgr}]", "HARMLESS", $q_name);

  # Open the input file
  my $input_file = "${DIR_CONFIG}mqs_trigger_$options{qmgr}.config" ;

  &LogInfoICS("Reading from configuration file $input_file", "HARMLESS", $q_name);

  unless ( open INPUTFILE,"<$input_file" )
  {
      die( &LogInfoICS("Cannot open for input file $input_file", "HARMLESS", $q_name ) . "\n" ) ;
  };

  my $script = &CheckFile( $options{queue} ) ;
  if ( defined $script )
  {
    # Expand %m, %q and %p
    for ( $script )
    {
      s/%m/$options{qmgr}/egi;
      s/%q/$options{queue}/egi;
      s/%p/$DIR_SCRIPTS/egi;
    };
    
    # Find the alias for the job
    my $alias_name = &BuildAliasName( $options{queue} ) ;    
    my $cmd = "$DIR_SCRIPTS$script &";
    
    &LogInfoICS("Running command: $cmd", "HARMLESS", $q_name);    
    &RunCmd( $cmd ) ;
  }
  else
  {
    &LogInfoICS( "ERROR: No match found for $options{queue}", "CRITICAL", $q_name ) ;
  };

  exit 0 ;

################################################################################
# PrintUsage: Print usage script and exit with code 1                          #
################################################################################
sub PrintUsage
{
  print STDERR "Usage: $0 -qmgr <qmgr> -queue <queue>\n" ;
  die( &LogInfoICS( "Invalid options", "HARMLESS", $q_name ) . "\n" ) ;
} # PrintUsage

################################################################################
# CheckFile: Check the file to find the script to run                          #
################################################################################
sub CheckFile
{
  my $queue = uc shift ;

  # Check the input file
  my $buffer = '' ;
  while ( <INPUTFILE> )
  {
    # Skip comments
    next if m/^\s*#/ or m/^\s*\*/ ;

    # Remove final LF and inital whitespace. Ignore blank lines
    chomp ;
    s/^\s*// ;
    next if m/^$/ ;

    # Allow continuation lines
    if ( m/\+\s*$/ )
    {
      s/\s*\+\s*$/ / ;
      $buffer .= $_ ;
      next ;
    };
    my $line = $buffer . $_ ;
    $buffer  = '' ;

    # Extract queue name and command
    my ( $qname, $command ) = $line =~ m/^\s*(\S*)\s*=\s*(.*)$/ ;
    unless ( defined $command )
    {
      &LogInfoICS( "Syntax error on line $. of input file. Line ignored.", "HARMLESS", $q_name ) ;
      next ;
    };

    # Is this the queue we want ?
    return $command if $queue eq uc $qname ;
  }; # while

  # Not found
  return ;
} # CheckFile


################################################################################
# BuildAliasName: Build an alias for the job                                   #
################################################################################
sub BuildAliasName
{
  local $_ ;
  my $queue = uc shift ; # Parameter: Name of queue

  # Shorten the queue name by removing some common prefixes,
  # change "." to "_" and remove non-alphanumeric characters
  for ( $queue )
  {
    s/^QL\.// ;
    s/^IN\.// ;
    s/^OUT\.// ;
    s/^NAW_IN\.// ;
    s/^NAW_OUT\.// ;
    s/^DJFT\.// ;
    s/^TOHUB\.// ;
    s/^FRMHUB\.// ;
    s/\./_/g ;
    s/[^A-Z0-9_]//g ;
  };

  # Reduce the name to 19 characters
  $queue = substr( $queue, 0, 19 ) if length( $queue ) > 19 ;

  # Find current date/time
  my ( $sec, $min, $hour, $mday, $mon, $year ) = (localtime)[ 0..5 ] ;
  $year %= 100 ;
  ++$mon ;
  my $datetime = sprintf( ( "%0.2d" x 6 ),
                          $year, $mon, $mday, $hour, $min, $sec ) ;

  # Calculate the alias name
  my $alias_name = "ICSL_${queue}_${datetime}" . sprintf( "%0.3d", $$ % 1000 ) ;

  return $alias_name ;
} # BuildAliasName


################################################################################
# ParseTrig : Parse an MQSeries trigger parameter and return a hash reference  #
#             containing contents                                              #
################################################################################
sub ParseTrig
{
  my $arg = shift ;

  # Is argument a trigger ?
  if ( substr( $arg, 0, 4 ) ne 'TMC ' )
  {
    # Not a trigger !
    return ;
  }
  else
  {
    # Argument is a trigger so extract all the fields
    my %result ;
    ( $result{StrucId},
      $result{Version},
      $result{QName},
      $result{ProcessName},
      $result{TriggerData},
      $result{ApplType},
      $result{ApplId},
      $result{EnvData},
      $result{UserData},
      $result{QMgrName} ) = unpack( "a4a4a48a48a64a4a256a128a128a48", $arg ) ;

    return \%result ;
  };
} # ParseTrig


################################################################################
# Trim : Remove leading and trailing spaces                                    #
################################################################################
sub Trim
{
  my $arg = shift ;

  $arg =~ s/^ *// ;
  $arg =~ s/ *$// ;

  return $arg ;
} # Trim


################################################################################
# RunCmd: Run the commmand                                                     #
################################################################################
sub RunCmd
{
  my $cmd    = shift ; # Parameter: Command to run
  my $result = system($cmd) ;
  
  if ( $result == 0 ) 
  {
    &LogInfoICS( "Successful submission of CMD [$cmd].", "HARMLESS", $q_name ) ;
  } 
  else 
  {
    &LogInfoICS( "Error during submission of CMD [$cmd]. Return code [$result]", "CRITICAL", $q_name ) ;
  }
} # RunCmd

################################################################################
# LogInfoICS : Log file                                                           #
################################################################################
sub LogInfoICS
{
  my $message = shift;
  my $type = shift;
  my $q_name = shift;
  
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime(time);
  
  # put into 4 digit: 1900 + year = current year; increment months (pl starts at 0)
  $year += 1900;
  ++$mon;

  my $fmt_date = sprintf( "%0.4d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d",
                     $year, $mon, $mday, $hour, $min, $sec);

   open OUT2, ">>$ICS_LOG"
     or print "Cannot write to log file $ICS_LOG";
   print OUT2 $fmt_date . " INFO test TOKU006.AP.MARS " . $type . " ics_process.pl:[" . $process_id . "] INFO: Queue: [" . $q_name . "] " . $message . "\n";

   close OUT2;
}

################################################################################
# End of code                                                                  #
################################################################################
__END__

=head1 NAME

  mqseries_maestro.pl - Trigger Maestro jobs on the arrival of a message

=head1 SYNOPSIS

  mqseries_maestro.pl -qmgr <qmgr> -queue <queue>

=head1 DESCRIPTION

This script automates the submission of a Maestro job on the arrival of
MQSeries messages in a queue. A configuration file gives a cross-reference
of the queue name and the script to run.

The script submits a job whose alias depends on the name of the queue in which
the message arrived and the current date and time.

=head2 Parameter file

On NT the parameter file is called

  d:\ims\appl\maestro\config\mqs_trigger_<qmgr>.config

and on HP-UX 

  /opt/ims/maestro/config/mqs_trigger_<qmgr>.config

where <qmgr> is the queue manager of the queue.

Lines in the configuration file beginning with '#' or '*' and blank lines
are ignored. The rest of the file contains lines of the form

  queue.name = ascript.pl p1 p2

where queue.name is the name of the queue and "ascript.pl p1 p2" is the
name and parameters of the script file to run.

Any strings of the form "%m", "%q" or "%p" in the script name or parameters
are replaced by the queue manager name, queue name or the directory for
application Maestro scripts respectively.

The name of the queue is not case sensitve.

The characters single quote (') and double quote (") are not allowed in the
script or its parameters.

=head2 Maestro job names

To create the Maestro job name the script takes the queue name, changes and
dots(".") to underlines ("_"), removes any "QL.", "IN." or "OUT." prefixes and
adds a prefix "MQSI" and adds a suffix containing the current date/time and the
process id of the current task.

For example if the queue name is QL.IN.TEST1.QUEUE then the job might be
given the name...

  MQSI_TEST1_QUEUE_000911150401123

where "TEST1_QUEUE" is taken from the name of the queue, 000911 is from
the date 11 September 2000, 150401 is for the time "15:04:01" and 123 is the
last three digits of the process id.

=head2 MQSeries Configuration

To use this script a queue must be set up with triggering enabled, a process
of MAESTRO and a suitable initiation queue...

  define qlocal(ql.test.queue) trigger process(maestro) initq(qi.ims)

=head2 Log file

The script writes information and error messages to a file 
d:\ims\data\log\mqseries_maestro.log (Windows) or
/var/opt/apps/ims/data/log/mqseries_maestro.log (Unix).

=head1 PARAMETERS

=over 4

=item -qmgr

The name of the queue manager of the queue

=item -queue

The name of the queue on which the message has arrived

=back

=head1 BUGS

=over 4

=item Quotes

The various quoting rules of NT, sh (on HP-UX) and Maestro mean that the
characters single quote (') and double quote (") cannot be put into the
the script or its parameters.

=item Command line length

Maestro limits the length of a command to 256 characters. It is, therefore,
not possible to pass the complete MQSeries trigger structure to the 
started job.

=back

=head1 CHANGES

=over 4

=item Richard Ashpole, 14-Feb-2003, version 3.00

Creation

=item Richard Ashpole, 14-Feb-2003, version 3.01

Add TOHUB and FRMHUB to list of qualifiers to remove

=item Richard Ashpole, 07-Oct-2003, version 3.02

Remove calls to non-existant routines LogWarn and LogError

=item Richard Ashpole, 07-Oct-2003, version 3.03

Cope with the case that the job name (after removal of standard prefixes) is
exactly 20 characters long

=back

=head1 AUTHOR

Richard Ashpole, September 2000

=cut

################################################################################
# End of file                                                                  #
################################################################################

