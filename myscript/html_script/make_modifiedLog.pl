#!/usr/bin/env perl

use Pod::Usage;
use strict;
use warnings;
# file copy
use File::Copy qw/copy move/;
# symbol
use Fcntl;
use Getopt::Long qw(GetOptions);

# tmp_file and maked tmp_HTML_file.
my $tmp_HTML = ""; 
my $index = 0;

# paturn match
# NOTE_: set patturns from config.
my $err = "Error";
my $err2 = "ERROR";
my $err3 = "error";
my $info = "Info";
my $info2 = "INFO";
my $info3 = "info";
my $warn = "WARN";
my $warn2 = "WARNING";
my $warn3 = "Warn";
my @patturns = ($err, $info, $warn, $err2, $info2, $warn2, $err3, $info3, $warn3);

# printed colors 
# NOTE_: set COLORS from config.
my $err_color = "red";
my $info_color = "blue";
my $warn_color = "orange";
my @colors = ($err_color, $info_color, $warn_color, 
	      $err_color, $info_color, $warn_color,
	      $err_color, $info_color, $warn_color,
	      "tan", "sandybrown", "skyblue", "gray", "black");  # it is error when user put more 5.

# option
my $update = "";
GetOptions (
  # handle imgaes
  'update' => \$update,
) or pod2usage();


# cno
my $cno = -1;

# add other_patturn, from cmd arguments. 
# NOTE: print error, when user put more 3 arguments. ;

sub push_greps_fromARGV(){
  if (!$update){ 
    for ( my $i = 1; $i <= $#ARGV; $i++ ) { 
      push(@patturns, $ARGV[$i]);
    }
  }
  else{
    for (my $i = 2; $i <= $#ARGV; $i++){
      push(@patturns, $ARGV[$i]);
    }
  }
}

# debug
print "     All_greps : @patturns\n";
print "     colors: @colors\n";

#  main ARGV[0] is cno, other  STDIN is log. 
#  if ARGV >   
sub modify_log{  #modified log and make ./tmp/tmp_$cno.html
  my $toCall;
  # cno
  my $cno = -1;
  ($cno) = $ARGV[0];
  $tmp_HTML = "./tmp_" . "$cno" . ".html";
  # open.
  say STDERR "     make : temporatory html made from log. => $tmp_HTML";
  open(my $fh, ">", $tmp_HTML)
    or die "Cannot open $tmp_HTML: $!";
    # read line from STDIN(logStr)
    while( defined(my $line = <STDIN>) ) {
      #patturn match.
      for ( my $i = 0 ; $i <= $#patturns ; $i ++ ) { 
        my $color=sprintf "%dm", $i + 31;
        if($line =~ "$patturns[$i]"){
          my $cl = $colors[$i];
          if (0 < $i && $i < 9){ 
            # when match ERROR or INFO or WARNING.
            $line = "<font color=$cl>" . "$line" . "</font>\n";
          }
          else{
            $line =~ s/$patturns[$i]/<font color=$cl>$patturns[$i]<\/font>/;
          }
        }
      }
      # write.
      print $fh "$line" . "<br>";
    }
  close($fh);
}

# update_log
my $group_no = -1;
my $group_folder;
my $log_file;

sub update_log{
  ($group_no) = $ARGV[0];
  ($cno)     = $ARGV[1];
  $group_folder = "./html_script/html_logs/group$group_no";
  
  my $toCall;
  $log_file = "$group_folder/group$group_no-$cno" . ".html";
  say STDERR "     targetFiles : $log_file ";
  # cno
  # open.
  say STDERR "    update : html maked from log.";
  open(my $fh, ">", $log_file)
    or die "Cannot open $log_file: $!";
    # read line from STDIN(logStr)
    while( defined(my $line = <STDIN>) ) {
      #patturn match.
      for ( my $i = 0 ; $i <= $#patturns ; $i ++ ) {
        my $color=sprintf "%dm", $i + 31;
        if($line =~ "$patturns[$i]"){
          my $cl = $colors[$i];
          if (0 < $i && $i < 9){
            # when match ERROR or INFO or WARNING.
            $line = "<font color=$cl>" . "$line" . "</font>\n";
          }
          else{
            $line =~ s/$patturns[$i]/<font color=$cl>$patturns[$i]<\/font>/;
          }
        }
      }
      # write.
      print $fh "$line" . "<br>";
    }
  close($fh);
  say STDERR "     update!!";
}

push_greps_fromARGV();
if (!$update){
  modify_log();
}
if ($update){
  update_log();
}
