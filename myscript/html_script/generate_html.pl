#!/usr/bin/env perl

use Pod::Usage;

use strict;
use warnings;

# symbol
use Fcntl;

use Getopt::Long qw(GetOptions);
use Pod::Usage;

# use for time stamp
use Time::Piece;

use File::Copy;

# files
my $info_file  = "./html_script/info.pl";
my $main_file  = "./html_script/main.html"; 
my $menus_file = "./html_script/menus.html"; 

our @datas = (); # it is made from cmd arguments .
# cmd arg is gived like c_no1 c_name1 anything {greps1} c_no2 anithing {grep3} ... c_noN c_nameN anythingN {grepN} 
my $sum_datas = 0; # sum of datas. ()
my $data_index = 0; # data index
my $group_no;
my $group_name;
my $time_stamp_day;
my $time_stamp_time;

# is used temporatory in some functions.
my $target ="";    
my $write_data = "";
my $option = "";

# NOTE: get COMPORNENTS config
my @COMPORNENTS = ("sw360", "couchdb", "fossology", "postgres", "nginx", "csv_search");

# prottype 
sub get_new_menu($$$);

{ # parse cmd argument
  my $index = 0; # argindex
  my @data = ();

  my $cno;
  my $cname;
  my $anything;
  my $greps = ""; 
  my $grep = "";

  while ($index != ($#ARGV + 1) ){ # ARGV  = c_no1 c_name1 anything {greps1} c_no2 anithing {grep3} ... c_noN c_nameN anythingN {grepN}
    $cno   = $ARGV[$index];     $index = $index+1;
    $anything = $ARGV[$index]; $index = $index+1;
    $greps = "";
    while ($index != ($#ARGV + 1) && $ARGV[$index] !~ /^[0-9]$/){
      $greps = "$greps" . "$ARGV[$index] ";     
      $index = $index+1;
    }
    @data = ($cno, $cname, $anything, $greps);
    $datas[$sum_datas] = [ @data ];     
    $sum_datas = $sum_datas + 1;
  }
  say STDERR "  sum_datas : $sum_datas";
} 

{ # parse info.pl
  if (-e $info_file){
    my $info=do($info_file);
        die "Error parsing $info_file: $@" if $@;
        die "Error reading $info_file: $!" unless defined $info;
    $group_no = $info -> {'nextGroupNo'}   // $group_no;
    say STDERR "  log group NO: $group_no";
  }
}

sub get_time_stamp(){ # return now-time_stamp_daya and  now-time_stamp_time.
  my @wdays = ( "日", "月", "火", "水", "木", "金", "土"); 
  my $time = time();
  my ($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($time);
  $year = $year+1900; $mon = $mon +1; 
  my $time_stamp_day  = "$year" . "/" . "$mon" . "/" . "$mday" . "(" . "$wdays[$wday]" . ")";
  my $time_stamp_time = "$hour" . ":" . "$min" . ":" ."$sec" ;
  say STDERR "  timestamp : $time_stamp_day  $time_stamp_time";

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

sub get_new_menu($$$){ # return new_menu.html (string of html type).
  my $group_name;
  my $time_stamp_day;
  my $time_stamp_time;
  ($group_name, $time_stamp_day, $time_stamp_time) = @_;
  my $result;

  my $space = " ";
  my $spaces;
  $spaces = $space x 12;

  # set group link. 
  $result = "$spaces<!--$group_no-->\n";
  $result = $result . "$spaces<li><a href=\"./html_logs/$group_name/$group_name.html\" target=group>$group_name $time_stamp_day $time_stamp_time</a></li>\n";
  $result = $result . "$spaces<ul class=\"$group_name\">\n";
  # set targets list with each options.
  $spaces = $space x 16;
  # set each log link.
  my $cname= "";
  my $opt = "";
  my $cno = 0;
  for (my $i = 0; $i < $sum_datas; $i++){
    $cname  = $COMPORNENTS[$datas[$i][0]];
    $opt    = $datas[$i][3];
    $cno    = $datas[$i][0];
    $result = $result . "$spaces<li><a href=\"./html_logs/$group_name/$group_name-$cno.html\" target=group>$cname</a> $opt</li>\n";
  }
  $spaces = $space x 12;
  $result = $result . "$spaces</ul>\n";	
  $result = $result . "$spaces<!--next-->\n";

  return $result;
}

# add menu to new each log link as group.
sub update_menu_page{
  my @lines;

  # read All lines.
  open(my $menus_fh, "<", $menus_file)
    or die "Cannot open $menus_file: $!";
  @lines = &read_html($menus_fh);  
  close ($menus_fh);

  # write modified lines
  open(my $menus_fh2, ">", $menus_file)
    or die "Cannot open $menus_file: $!";
  # modify. 
  foreach my $line (@lines){  
    # patturn match.
    if ($line !~ /<!--next-->/){
      print $menus_fh2 "$line"; 
    }
    else{
      # if <!--next-->
      $group_name = "group" . "$group_no";
      # get timeStamp 
      ($time_stamp_day, $time_stamp_time) = get_time_stamp();
      # get option 
      # print 
      my $new_menu = get_new_menu($group_name, $time_stamp_day, $time_stamp_time);
      print $menus_fh2 "$new_menu";
    }
  }
  say STDERR "  updateed menu.html!";
  close($menus_fh);
}

sub update_info_file{
  my $next_group_no = $group_no+1;
  open(my $fh, ">", $info_file)
    or die "Cannot open $info_file: $!";
    print $fh "{\n";
    print $fh "nextGroupNo => $next_group_no\n";
    print $fh "}";	
  close($fh);
}

update_menu_page();
update_info_file();

#$HtmlPackage::datas = \@datas;
#$HtmlPackage::sum_datas = $sum_datas;

# 変数の共有 ???
#system("echo_make_.pl @ARGV $") == 0 or die "Can't execute echo_make_logs_GUI.pl: $!";

# --- ??? 
#my @test = $HtmlPackage::datas;
#my @data1 = $test[0][0][0];
#my @data2 = $test[0][0][1];

#my $target01 = $data1[0];
#print "test: $target01 ";

### make_logs_GUI_page ### 変数の共有ができなかったから、ここで直接打つ, 本来なら -> make_logs_GUI_page　へ
# set file_name.

my $logs_gui_folder = "$group_name";
my $logs_gui_HTML = "$group_name" . ".html";
#print "$logs_gui_folder\n";
#print "$logs_gui_HTML\n";
mkdir "./html_script/html_logs/" . "$logs_gui_folder" # NOTE: In windows, can't do
  or die "$logs_gui_folder is not maked error at <> : $!";

sub make_log_page{
  my $log_page_file;
  my $index;
  my $cno;
  my $name;
  ($name, $cno) = @_;
  $log_page_file = "./html_script/html_logs/$group_name/" . "$name" . ".html";

  my $tmp_file = "./tmp/tmp_" . "$cno" . ".html";
  move($tmp_file, $log_page_file) or die "Can't move \"$tmp_file\" to \"$log_page_file\": $!";
}

sub make_logs_GUI_page{
  my $space = " ";
  my $spaces;
  open my $fh, ">", "./html_script/html_logs/$group_name/" ."$logs_gui_HTML"  # NOTE: create it  to logsFoder.
    or die "./html_script/html_logs/$logs_gui_HTML を書き込みモードでオープンすることができません。: $!";
    print $fh "<!DOCTYPE html>\n";
    print $fh "\n";
    print $fh "<html>\n";
    $spaces = $space x 4;
    my $cno;
    my $cname;
    my $opt;
    my $name;
    my $result;
    print $fh "$spaces<h1>$group_name</h1>\n";
    for (my $i = 0; $i < $sum_datas; $i++){
      $cno   = $datas[$i][0]; 
      $cname = $COMPORNENTS[$cno];
      $opt    = $datas[$i][3];
      # "$spaces<li>$cname $opt</li>\n";
      $name = "$group_name" . "-" . "$cno";
      print $fh "$space<font color=\"green\" size=\"4\">$cname:option{$opt}</font><br>\n";
      print $fh "$spaces<iframe src=\"$name.html\" width=1100 height=400></iframe>\n";
      make_log_page($name, $cno);
      say STDERR "  maked log page [$cname, $opt]";
    }
    say STDERR "  updateed logs page!!";
    print $fh "</html>\n";
  close $fh;
}


make_logs_GUI_page();
