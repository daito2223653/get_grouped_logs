#!/usr/bin/env perl

use Pod::Usage;

use strict;
use warnings;

# file copy
use File::Copy qw/copy move/;
# symbol
use Fcntl;


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
my $warn = "Warning";
my $warn2 = "WARNING";
my $warn3 = "Warning";
my @patturns = ($err, $info, $warn, $err2, $info2, $warn2, $err3, $info3, $warn3);

# printed colors 
# NOTE_: set COLORS from config.
my $err_color = "red";
my $info_color = "blue";
my $warn_color = "yellow";
my @colors = ($err_color, $info_color, $warn_color, 
	      $err_color, $info_color, $warn_color,
	      $err_color, $info_color, $warn_color,
	      "tan", "sandybrown", "skyblue", "gray", "black");  # it is error when user put more 5.

# cno
my $cno = -1;
($cno) = $ARGV[0];


# add other_patturn, from cmd arguments. 
# NOTE: print error, when user put more 3 arguments. ;
for ( my $i = 1; $i <= $#ARGV; $i++ ) { 
  push(@patturns, $ARGV[$i]);
}
print "PATTURNS: @patturns\n";
print "COLORS  : @colors\n";

#  main
sub modify_log{
  my $toCall;
  $tmp_HTML = "./" . "tmp_" . "$cno" . ".html";
  # cno
  my $cno = -1;
  ($cno) = $ARGV[0];
  # open.
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

modify_log();
