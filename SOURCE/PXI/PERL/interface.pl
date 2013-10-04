#!perl -wl

use strict;
use warnings;

use File::Basename;
use File::Copy;
use File::Spec;
use File::Find;
use Getopt::Std;
use POSIX;

my $conf = {
  # Load command for each interface, with #FILE# in place of filename
  load_cmd => {
	'302PROD.txt'     => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I302 -V0 -SPromax_PX_Test',
	'303PRODHIER.txt' => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I303 -V0 -SPromax_PX_Test', 
	'300CUST.txt'     => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I300 -V0 -SPromax_PX_Test',
	'301CUSTHIER.txt' => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I301 -V0 -SPromax_PX_Test',
	'347VEND.txt'     => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I347 -V0 -SPromax_PX_Test',
	'330PRICE.txt'    => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I330 -V0 -SPromax_PX_Test',
	'306SALES.txt'    => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I306 -V0 -SPromax_PX_Test',
	'336PCACT.txt'    => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I336 -V0 -SPromax_PX_Test',
	'336COGS.txt'     => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I336 -V1 -SPromax_PX_Test',
	'361DEDUCT.txt'   => '"C:\\Program Files (x86)\\PromaxPX\\pxInterfaceCMD.exe" -I361 -V0 -SPromax_PX_Test'
  },
  # Send command
  # #SRCEP#, #SRCFILE# for source endpoint and filename
  # #DESTEP#, #DESTFILE# for destination endpoint and filename
  #send_cmd => 'c:\mqft\mqft.exe #SRCEP# #SRCFILE# #DESTEP# /dummy/dest/dir/#DESTFILE#',
  send_cmd => 'D:\apps\global\mqft_light\test\shell\mqsend.cmd -srcqmgr #SRCEP# -srcfile #SRCFILE# -tgtqmgr #DESTEP# -tgtfile /ics/lad/test/inbound/#DESTFILE#',
  # Source endpoint
  mqft_src_endpoint => 'XPMXT01',
  # Destination endpoint
  mqft_dest_endpoint => 'QM0218T',
};

my @inbound_file_order = qw(302PROD.txt 303PRODHIER.txt 300CUST.txt 301CUSTHIER.txt 347VEND.txt 330PRICE.txt 306SALES.txt 336PCACT.txt 336COGS.txt 361DEDUCT.txt);
my @outbound_file_order = qw(359PROM.txt 325ACCRLS.txt 331CLAIMS.txt 337EST.txt);

# List of errors encountered during processing
my @errors = ();

# Get command line parameters
our ($opt_t, $opt_d, $opt_p);
getopts('td:p:'); # -t is boolean flag, -d and -p have values
unless (defined $opt_d && defined $opt_p) {
  print "Usage: perl $0 [-t] -d <interface_dir> -p <processing_type>";
  exit 1;
}

my ($testing, $iface_dir, $proc_type) = ($opt_t, $opt_d, $opt_p);

my $dirs = {
  inbound    => File::Spec->catdir($iface_dir, 'inbound'),
  outbound   => File::Spec->catdir($iface_dir, 'outbound'),
  ib_execute => File::Spec->catdir($iface_dir, 'ib_execute'),
  ob_execute => File::Spec->catdir($iface_dir, 'ob_execute'),
  ib_load    => File::Spec->catdir($iface_dir, 'ib_load'),
  ib_pending => File::Spec->catdir($iface_dir, 'ib_pending'),
  ob_pending => File::Spec->catdir($iface_dir, 'ob_pending'),
  ib_archive => File::Spec->catdir($iface_dir, 'ib_archive'),
  ob_archive => File::Spec->catdir($iface_dir, 'ob_archive'),
  ib_failed  => File::Spec->catdir($iface_dir, 'ib_failed'),
  ob_failed  => File::Spec->catdir($iface_dir, 'ob_failed')
};

if ($testing) { print "TESTING MODE: I won't touch anything!"; }

# -d parameter is the top-level interfacing directory
unless (-d $iface_dir) {
  die "Interface directory ($iface_dir) is not a directory.";
}

for my $d (keys %$dirs) {
  unless (-d $dirs->{$d} || mkdir($dirs->{$d})) {
    die "Directory '" . $dirs->{$d} . "' does not exist.";
  }
}

# -p parameter is the type of processing to initiate on this execution.
if    (uc($proc_type) eq 'CHECK_OUTBOUND') { &check_outbound_files; }
elsif (uc($proc_type) eq 'SEND_OUTBOUND' ) { &send_outbound_files;  }
elsif (uc($proc_type) eq 'CHECK_INBOUND' ) { &check_inbound_files;  }
elsif (uc($proc_type) eq 'LOAD_INBOUND'  ) { &load_inbound_files;   }
else { die "Unknown processing type '$proc_type'"; }

&print_error_report;

# Return code is the number of errors encountered
exit (scalar @errors);



sub check_inbound_files {
  &move_files_older_than('5mins', $dirs->{inbound}, $dirs->{ib_pending});
}

sub load_inbound_files {
  # Check for files remaining from previous unsuccessful loads
  for my $dir ($dirs->{ib_load}, $dirs->{ib_execute}, $dirs->{ib_failed}) {
    my @dir_files = get_file_list($dir);
    if (@dir_files > 0) {
      print "Found file in '$dir'. This indicates a previous load was unsuccessful. Quitting...";
      print "Files found: " . join(', ', @dir_files);
	  return;
    }
  }

  my @pending = get_file_list($dirs->{ib_pending});

  # Iterate through inbound file types
  for my $inbound_file_type (@inbound_file_order) {
	my ($name, $ext) = split(/\./, $inbound_file_type); # Split current file type into name and extension
    my @files_to_load = grep { /^$name\d+\.$ext$/ } @pending; # Only get files matching the current file type
	@files_to_load = map { $_ = File::Spec->catfile($dirs->{ib_pending}, $_) } @files_to_load; # Convert to absolute paths

	# Process files of this type in date order
	for my $pending_file_name (sort_by_modified_date(@files_to_load)) {
	  # Build some filenames
	  my $pending_file_basename = basename($pending_file_name);
	  my $exec_file_name    = File::Spec->catfile($dirs->{ib_execute}, $pending_file_basename);
	  my $load_file_name    = File::Spec->catfile($dirs->{ib_load},    $inbound_file_type);
	  my $archive_file_name = File::Spec->catfile($dirs->{ib_archive}, $pending_file_basename);
	  my $failed_file_name  = File::Spec->catfile($dirs->{ib_failed},  $pending_file_basename);
	  
	  # Move file from pending -> execute
	  if (!move($pending_file_name, $exec_file_name)) {
	    push @errors, "Couldn't copy '$pending_file_name' to '$exec_file_name' ($!)";
		return;
	  }
	  # Copy file from exec -> load (file unique ID is removed)
	  if (!copy($exec_file_name, $load_file_name)) {
	    push @errors, "Couldn't copy '$exec_file_name' to '$load_file_name' ($!)";
		return;
	  }
	  
	  print "Loading '$load_file_name'...";
	  load_file($load_file_name);
	  
	  if (@errors == 0) {
	    # Move from exec -> archive
	    if (!move($exec_file_name, $archive_file_name)) {
		  push @errors, "Couldn't move '$load_file_name' to '$archive_file_name' after loading successfully.";
		}
		# Remove from load directory
		if (unlink($load_file_name) != 1) {
		  push @errors, "Couldn't delete '$load_file_name' after loading.";
		}
      }
	  else {
	    # Move from load -> failed
	    if (!move($load_file_name, $failed_file_name)) {
		  push @errors, "Couldn't move '$load_file_name' to '$failed_file_name' after loading failed.";
		}
	  }
	  return if @errors > 0; # Stop processing if we had any errors during the processing of this file
	}
  }
  
  # Check for remaining files (should be none)
  my @remaining_files = get_file_list($dirs->{ib_pending});
  if ( @remaining_files > 0) {
    push @errors, "Found remaining files in " . $dirs->{ib_pending} . " after processing completed. This should not occur.";
	return;
  }
}

sub check_outbound_files {
  &move_files_older_than(
    '5mins', $dirs->{outbound}, $dirs->{ob_pending},
    sub { # Function to generate new filenames
      my $tstamp = strftime('%Y%m%d%H%M%S', localtime(time)); # Create timestamp
      my $name = shift; $name =~ s/\.txt$/$tstamp.txt/ig; return $name; # Add timestamp in front of .txt extension
    }
  );
}

sub send_outbound_files {
  # Check for files remaining from previous unsuccessful sends
  for my $dir ($dirs->{ob_execute}, $dirs->{ob_failed}) {
    my @dir_files = get_file_list($dir);
    if (@dir_files > 0) {
      print "Found file in '$dir'. This indicates a previous send was unsuccessful. Quitting...";
      print "Files found: " . join(', ', @dir_files);
	  return;
    }
  }

  my @pending = get_file_list($dirs->{ob_pending});

  # Iterate through outbound file types
  for my $outbound_file_type (@outbound_file_order) {
	my ($name, $ext) = split(/\./, $outbound_file_type); # Split current file type into name and extension
    my @files_to_send = grep { /^$name\d+\.$ext$/ } @pending; # Only get files matching the current file type
	@files_to_send = map { $_ = File::Spec->catfile($dirs->{ob_pending}, $_) } @files_to_send; # Convert to absolute paths

	# Process files of this type in date order
	for my $pending_file_name (sort_by_modified_date(@files_to_send)) {
	  # Build some filenames
	  my $pending_file_basename = basename($pending_file_name);
	  my $exec_file_name    = File::Spec->catfile($dirs->{ob_execute}, $pending_file_basename);
	  my $archive_file_name = File::Spec->catfile($dirs->{ob_archive}, $pending_file_basename);
	  my $failed_file_name  = File::Spec->catfile($dirs->{ob_failed},  $pending_file_basename);
	  
	  # Move file from pending -> execute
	  if (!move($pending_file_name, $exec_file_name)) {
	    push @errors, "Couldn't copy '$pending_file_name' to '$exec_file_name' ($!)";
		return;
	  }
	  	  
	  if (-s $exec_file_name) {
		  print "Sending '$exec_file_name'...";
		  send_file($exec_file_name);
	  }
	  else {
		my $file = basename($exec_file_name);
		print "WARNING: Empty file: $file detected";
	  }
	  
	  if (@errors == 0) {
	    # Move from exec -> archive
	    if (!move($exec_file_name, $archive_file_name)) {
		  push @errors, "Couldn't move '$exec_file_name' to '$archive_file_name' after sending successfully.";
		}
      }
	  else {
	    # Move from exec -> failed
	    if (!move($exec_file_name, $failed_file_name)) {
		  push @errors, "Couldn't move '$exec_file_name' to '$failed_file_name' after sending failed.";
		}
	  }
	  return if @errors > 0; # Stop processing if we had any errors during the processing of this file
	}
  }
  
  # Check for remaining files (should be none)
  my @remaining_files = get_file_list($dirs->{ob_pending});
  if ( @remaining_files > 0) {
    push @errors, "Found remaining files in " . $dirs->{ob_pending} . " after processing completed. This should not occur.";
	return;
  }
}

sub load_file {
  return if @errors > 0; # If errors have been encountered already, don't do anything
  my $file = shift; return unless -f $file; # Skip non-files
  my $basefile = basename($file);
  my $cmd = $conf->{load_cmd}->{$basefile};
  if (!defined $cmd) {
    push @errors, "Could not find load command for file '$basefile'";
    return;
  }	
  $cmd =~ s/#FILE#/$file/g;
  print "Executing command '$cmd'";
  if (!$testing && system(split(' ', $cmd)) != 0) {
    push @errors, "Failed loading file '$file'";
  }
}

sub send_file {
  return if @errors > 0; # If errors have been encountered already, don't do anything
  my $file = shift; return unless -f $file; # Skip non-files
  my $basefile = basename($file);
  my $destfile = $basefile;
  
  if($basefile =~/^(\S{3}\D*)(\d*)(\.txt)$/) {
	$destfile = "$1$3";
  }
  
  my $cmd = $conf->{send_cmd};
  $cmd =~ s/#SRCEP#/$conf->{mqft_src_endpoint}/g;
  $cmd =~ s/#SRCFILE#/$file/g;
  $cmd =~ s/#DESTEP#/$conf->{mqft_dest_endpoint}/g;
  $cmd =~ s/#DESTFILE#/$destfile/g;
  print "Executing command '$cmd'";
  if (!$testing) {
    if (system(split(' ', $cmd)) != 0) {
	  push @errors, "Errors during MQ Transfer";
	  
  #   if (!move($file, File::Spec->catfile($dirs->{ob_archive}, $basefile))) {
  #      die "Couldn't move file '$_' to archive ($!)";
  #    }
  #  }
  #  else {
  #    push @errors, "Failed sending file '$file'";
  #    if (!move($file, File::Spec->catfile($dirs->{ob_failed}, $basefile))) {
  #      die "Couldn't move file '$_' to failed ($!)";
  #    }
    }
  }
}

# Move files older than X mins from one directory to another, optionally renaming them
# Parameters:
# 1. X - must be a number followed by 'mins' e.g. "5mins" (to avoid confusion over time units)
# 2. Source directory - must be a directory
# 3. Destination directory - must be a directory
# 4. Rename function (optional) - a function that accepts a filename and returns the desired new filename
# Example: move_files_older_than('c:\myfiles','c:\myfiles_new','60mins',sub { return "$_.new"; });
# This would take c:\myfiles\file1.txt and move it to c:\myfiles_new\file1.txt.new (assuming it's > 1 hour old)
sub move_files_older_than {
  my ($reqd_file_age, $src_dir, $dest_dir, $rename_callback) = @_;
  
  # Src & dest should be dirs, $time should be a number followed by mins
  die "'$src_dir' is not a directory" unless -d $src_dir;
  die "'$dest_dir' is not a directory" unless -d $dest_dir;
  die "'$reqd_file_age' is not a valid file age" unless $reqd_file_age =~ /^\d+mins$/;
  
  # Chop off the 'mins' on the end of the file age parameter
  $reqd_file_age =~ s/mins$//;
  
  # Get a list of files in the source directory old enough to process
  my $now = time;
  my @files = map { $_ = File::Spec->catfile($src_dir, $_) } get_file_list($src_dir);  # Convert to absolute paths
  @files = grep { $now - get_modified_date($_)  > $reqd_file_age * 60 } @files;

  # Iterate through files in order of modified date
  for my $file (sort_by_modified_date(@files)) {
    my $new_filename = basename($file); # Get the name of the file (without dir)
    # Call the rename function if supplied to generate the new filename
    #if ($rename_callback) { $new_filename = $rename_callback->($new_filename); }
    if ($rename_callback) { $new_filename = $rename_callback->($new_filename); }
    # Make new absolute filename
    $new_filename = File::Spec->catfile($dest_dir, $new_filename);
    print "Moving '$file' -> '$new_filename'...";
    if (!$testing) {
      if (!move($file, $new_filename)) {
        push @errors, "Could not move '$file' -> '$new_filename': $!";
        return 0;
      }
    }
  }
  
  return 1;
}

# Get list of all files in a directory (returns relative filenames)
sub get_file_list {
  my $dir = shift;
  opendir D, $dir || die "Can't opendir on '$dir' ($!)";
  my @files =  grep { -f File::Spec->catfile($dir, $_) } readdir(D); # Grep filters out non-files
  closedir D;
  return @files;
}

# Get modified date of a file or directory
sub get_modified_date {
  my $f = shift;
  my @finfo = stat($f) or die "Cannot get info about '$f'";
  return $finfo[9];
}

# Sort a list of files by modified date (oldest first)
sub sort_by_modified_date {
  return sort { get_modified_date($a) <=> get_modified_date($b) } @_;
}

# Print out any errors
sub print_error_report {
  if (@errors > 0) {
    print <<'EOF';
  
ATTENTION ---- The following errors were encountered during processing ----

EOF

    grep { print } @errors;

    print <<'EOF';
  
---------------------------------------------------------------------------
 
EOF
  }
}
