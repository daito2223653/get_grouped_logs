our $tests;
$tests = "test";

use strict;
use warnings;

# file copy
use File::Copy qw/copy move/;

# my perl module
BEGIN {unshift @INC, "./"}
use HtmlPackage;

# use for time stamp
use Time::Piece;

# 読み込みたいファイル名
my $info_file = "./info.pl";
my $main_file = "./main.html"; 
my $menu_file = "./menu.html"; 

our @datas = (); # it is made from cmd arguments . cmd arg is gived :  ( (target_name01, write_data01, option01), (target_name02, write_data02, option02), ...).
my $sum_datas = 0; # sum of datas. ()
my $data_index = 0; # data index
my $logs_no;
my @time_stamp = ();

# is used temporatory in some functions.
my $target ="";    
my $write_data = "";
my $option = "";

# prottype 
sub get_new_logs_menu($$$);

{ # parse cmd argument
  my $index = 0; # argindex
  my @data = ();

  while ($index != ($#ARGV + 1) ){ # ARGV = target_name01 write_data01 option01 target_name02 write_data02 option02 ...
    $target = $ARGV[$index];     $index = $index+1;
    $write_data = $ARGV[$index]; $index = $index+1;
    $option = $ARGV[$index];     $index = $index+1;
    @data = ($target, $write_data, $option);
    $datas[$sum_datas] = [ @data ];     
    $sum_datas = $sum_datas + 1;
  }
} 

{ # parse info.pl
  if (-e $info_file){
    my $info=do($info_file);
        die "Error parsing $info_file: $@" if $@;
        die "Error reading $info_file: $!" unless defined $info;
    $logs_no = $info -> {'nextLogsNo'}   // $logs_no;
  }
}

sub get_time_stamp(){ # return now-time_stamp_daya and  now-time_stamp_time.
  my @wdays = ( "Sunday", "Monday", "Thuesday", "Wednesday", "Thursday", "Friday", "saturday"); # NOTE: conver japanese.
  # my @wdays = ( "Sunday", "月", "火", "水", "木", "金", "土");
  my $time = time();
  my ($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($time);
  $year = $year+1900; $mon = $mon +1; 
  my $time_stamp_day  = "$year" . "_" . "$mon" . "_" . "$mday" . "(" . "$wdays[$wday]" . ")";
  my $time_stamp_time = "$hour" . ":" . "$min" . ":" ."$sec" ;
  
  return ($time_stamp_day, $time_stamp_time);
}

# return all lines from $fh(html_file).  
sub read_html(){
    my $fh;
    ($fh) = @_;
    my @lines;
    # readline関数で、一行読み込む。
    while(my $line = readline $fh){ 
      # $line に対して何らかの処理。
      # 標準出力へ書き出し。
      push(@lines, $line);
      # ファイルがEOF( END OF FILE ) に到達するまで1行読みこみを繰り返す。
    }
    close $fh;
    return (@lines);
}

my $logs_name;
sub get_new_logs_menu($$$){ # return new_logs_menu(string of html type).

  my $time_stamp_day;
  my $time_stamp_time;
  ($logs_name, $time_stamp_day, $time_stamp_time) = @_;
  my $result;

  my $space = " ";
  my $spaces;
  $spaces = $space x 12;

  my $t = "";
  my $opt = "";
  # set logs link. 
  $result = "$spaces<!--$logs_no-->\n";
  $result = $result . "$spaces<li><a href=\"./html_logs/logs_gui_$logs_name.html\" target=logs_gui>$logs_name $time_stamp_day $time_stamp_time</a></li>\n";
  $result = $result . "$spaces<ul class=\"$logs_name\">\n";
  # set targets list with each options.
  $spaces = $space x 16;
  for (my $i = 0; $i < $sum_datas; $i++){
    $t = $datas[$i][0];
    $opt = $datas[$i][2];
    $result = $result . "$spaces<li>$t $opt</li>\n";
  }
  $spaces = $space x 12;
  $result = $result . "$spaces</ul>\n";
  $result = $result . "$spaces<!--next-->\n";

  return $result;
}

# add menu to new logs link.
sub updata_menu{
  my @lines;

  # read All lines.
  open(my $menu_fh, "<", $menu_file)
    or die "Cannot open $menu_file: $!";
  @lines = &read_html($menu_fh);  
  close ($menu_fh);

  # write modified lines ---
  open(my $menu_fh2, ">", $menu_file)
    or die "Cannot open $menu_file: $!";
    # modify. 
    foreach my $line (@lines){  
      # patturn match.
      if ($line !~ /<!--next-->/){
        print $menu_fh2 "$line"; 
      }
      else{
        # if <!--next-->
        my $logs_name = "logs" . "$logs_no";
        # get timeStamp 
        my ($time_stamp_day, $time_stamp_time) = get_time_stamp();
        @time_stamp = ($time_stamp_day, $time_stamp_time);
        # print 
        my $logs_menu = get_new_logs_menu($logs_name, $time_stamp_day, $time_stamp_time);
        print $menu_fh2 "$logs_menu";
      }
    }
  close($menu_fh);
}

sub update_info_file{
  my $next_logs_no = $logs_no+1;
  open(my $fh, ">", $info_file)
    or die "Cannot open $info_file: $!";
    print $fh "{\n";
    print $fh "nextLogsNo => $next_logs_no\n";
    print $fh "}";
  close($fh);
}

updata_menu();
update_info_file();


#$HtmlPackage::datas = \@datas;
#$HtmlPackage::sum_datas = $sum_datas;

# 変数の共有 ???
# my $arg = "$logs_name" . "@ARGV" . "$time_stamp";
# system("echo_make_logsGUI.pl $arg") == 0 or die "Can't execute echo_make_logs_GUI.pl: $!";
# --- ??? 
#my @test = $HtmlPackage::datas;
#my @data1 = $test[0][0][0];
#my @data2 = $test[0][0][1];

#my $target01 = $data1[0];
#print "test: $target01 ";

### make_logs_GUI_page ### 変数の共有ができなかったから、ここで直接打つ, 本来なら -> make_logs_GUI_page　へ
# set file_name. 
my $time_stamp_day = $time_stamp[0];
my $time_stamp_time =  $time_stamp[1];
my $logs_gui_folder = "$logs_name" . "_" . "$time_stamp_day" . "_" . "$time_stamp_time";
my $logs_gui_HTML = "logs_gui_" . "$logs_name" . ".html";
#print "$logs_gui_folder\n";
#print "$logs_gui_HTML\n";
#mkdir "./" . "$logs_GUIfolder" # NOTE: In windows, can't do
  #or die "$logs_GUIfolder is not maked error at <> : $!";

sub make_logs_GUI_page{
  my $space = " ";
  my $spaces;
  open my $fh, ">", "./html_logs/" ."$logs_gui_HTML"  # NOTE: create it  to logsFoder.
    or die "$logs_gui_HTML を書き込みモードでオープンすることができません。: $!";
    print $fh "<!DOCTYPE html>\n";
    print $fh "\n";
    print $fh "<html>\n";
    $spaces = $space x 4;
    my $t;
    my $opt;
    my $name;
    print $fh "$spaces<h1>$logs_name</h1>\n";
    for (my $i = 0; $i < $sum_datas; $i++){
      $t =  $datas[$i][0];
      $opt = $datas[$i][2];
      $name = "$logs_name" . "-" . "$i";
      print $fh "$space<font color=\"green\" size=\"4\">$t:option{$opt}</font><br>\n";
      print $fh "$spaces<iframe src=\"$name.html\" width=1000 height=300></iframe>\n";
      make_log_page($name, $i);
    }
    
    print $fh "</html>\n";
  close $fh;
}

sub make_log_page{
  my $log_page_file;
  my $index;
  ($log_page_file, $index) = @_;
  $log_page_file = "./html_logs/" . "$log_page_file" . ".html";

  my $tmp_file = "tmp_" . "$index" . ".html";
  copy($tmp_file, $log_page_file) or die "Can't copy \"$tmp_file\" to \"$log_page_file\": $!";
}

=pod
  # get write_data from tmp_no.log file.
  #my $write_data = get_write_data($index);
  open my $fh, ">", "$log_page_file"  # NOTE: create it  to logsFoder.
    or die "$logs_gui_HTML can't open error at <>: $!";
    copy($tmp_file, $log_page_file);
    print $fh "<!DOCTYPE html>\n";
    print $fh "\n";
    print $fh "<html>\n";
    print $fh "$write_data";
}

sub get_write_data{
  my $no;
  ($no) = @_;
  my $tmp_file = "tmp_" . "$no" . ".html";
  
  my $write_lines = "";
  # read  line s from tempFile";
  open my $fh, "<", "$tmp_file"
    or die "$logs_gui_HTML can't open error at <>: $!"; 

  @write_lines = &read_html($fh);
  close ($fh);

  return "$write_data"; 
}
=cut

make_logs_GUI_page();

=pod
<!DOCTYPE html> 

<html>
    <h1>logs01</h1>
    <iframe src="log01.html" width=600 height=200></iframe>
    <iframe src="log02.html" width=600 height=200></iframe>
</html>

=cut

sub make_target_log_page{

}
