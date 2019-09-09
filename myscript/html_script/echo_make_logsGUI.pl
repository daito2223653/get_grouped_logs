use strict;
use warnings;

# my perl module
BEGIN {unshift @INC, "./"}
use HtmlPackage;

# use for time stamp
use Time::Piece;

# 読み込みたいファイル名
my $logs_gui_file = "";

my @datas = (); # it is made from cmd arguments . cmd arg is gived :  ( (target_name01, write_data01, option01), (target_name02, write_data02, option02), ...).
my $sum_datas = 0; # sum of datas. ()
my $data_index = 0; # data index
my $next_logs_no;
my @time_stamp = ();

# is used temporatory in some functions.
my $target ="";    
my $write_data = "";
my $option = "";

# prottype 


my $logs_name = 0;
{ # parse cmd argument
  my $index = 0; # argindex
  my @data = ();

  $logs_name = $ARGV[$index];
  $index = $index +1;
  while ($index != ($#ARGV) ){ # ARGV = target_name01 write_data01 option01 target_name02 write_data02 option02 ...
    $target = $ARGV[$index];     $index = $index+1;
    $write_data = $ARGV[$index]; $index = $index+1;
    $option = $ARGV[$index];     $index = $index+1;
    @data = ($target, $write_data, $option);
    $datas[$sum_datas] = [ @data ];     
    $sum_datas = $sum_datas + 1;
  }
  @time_stamp = $ARGV[$index+1];
} 

# set file_name. 
my $time_stamp_day = $time_stamp[0];
my $time_stamp_time =  $time_stamp[1];
$logs_gui_file = "logs" . "$logs_name" . "_" . "$time_stamp_day" . "_" . "$time_stamp_time";

print $logs_gui_file;

sub make_new_logs_gui{

}


