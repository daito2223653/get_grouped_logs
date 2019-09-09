our $tests;
$tests = "test";

use strict;
use warnings;

# file copy
use File::Copy qw/copy move/;

# tmp_file and maked tmp_HTML_file.
my $tmp_HTML = "";
my $tmp_log = ""; 
my $index = 0;

# paturn match
# NOTE_: set patturns from config.
my $err = "Error";
my $info = "Info";
my $warn = "Warning";
my @patturns = ($err, $info, $warn);

# printed colors 
# NOTE_: set COLORS from config.
my $err_color = "red";
my $info_color = "blue";
my $warn_color = "yellow";
my @colors = ($err_color, $info_color, $warn_color, "tan", "sandybrown", "skyblue");  # @colos is  (ERR, INFO, WARN, OPT1, OPT2, OPT3); # it is error when user put more 3 OPTs # OPT{$no} is grep_option

# add other_patturn, from cmd arguments. 
# NOTE: print error, when user put more 3 arguments. 
for ( my $i = 0 ; $i <= $#ARGV ; $i ++ ) { 
  push(@patturns, $ARGV[$i]);
}
print "PATTURNS: @patturns\n";
print "COLORS  : @colors\n";

#  main
sub modify_log{
  my $toCall;
  $tmp_HTML = "../" . "tmp_" . "$index" . ".html";
  open(my $fh, ">", $tmp_HTML)
    or die "Cannot open $tmp_HTML: $!";
    while( defined(my $line = <STDIN>) ) {
      for ( my $i = 0 ; $i <= $#patturns ; $i ++ ) { 
        my $color=sprintf "%dm", $i + 31;
        if($line =~ "$patturns[$i]"){
          my $cl = $colors[$i];
          if ($i == 0 || $i == 1 || $i == 2){ 
            # when match ERROR or INFO or WARNING.
            $line = "<font color=$cl>" . "$line" . "</font>\n";
          }
          else{
            $line =~ s/$patturns[$i]/<font color=$cl>$patturns[$i]<\/font>/;
          }
        }
      }
      print $fh "$line" . "<br>";
    }
    close($fh);
}

modify_log();
