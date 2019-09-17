#!/usr/bin/env perl

# cmd arg is gived (--html):  c_no1 c_name1 anything {greps1} c_no2 anithing {grep3} ... c_noN c_nameN anythingN {grepN} 
# cmd arg is gived (--update [no]):  c_no1 c_name1 anything {greps1} c_no2 anithing {grep3} ... c_noN c_nameN anythingN {grepN} 

# c_no: conteiner no.
# c_name: conteinre name.
# g_no : group no.

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
my $config_file = "./config_info.pl";

my @datas = (); # it is made from cmd arguments .
my $sum_datas = 0; # sum of datas. 
my $time_stamp_day;
my $time_stamp_time;

# group info. used --update option selected
my $group_no;      # group no 
my $group_name;    # group name,

# config info.
my @containers_nos;# COMPORNENT_NO.
my @CONTAINERS;# COMPORNENT_NAME.

# option.
my $update = "";

# prottype 
sub get_new_menu($$);

sub get_group_info($){ # parse argument. argument is groupNo.
  my $group_no;
  ($group_no) = @_;
  my $group_folder = "./html_script/html_logs/group$group_no/";
  my $ginfo_file    = "$group_folder" . "info.pl";

  my $grs;
  my $g_name;
  my $ts;
  if (-e $ginfo_file){
    say STDERR "    [INFO]read info file from: $ginfo_file";
    my $info = do($ginfo_file);
      die "Error parsing $ginfo_file: $@" if $@;
      die "Error reading $ginfo_file: $!" unless defined $info;
    $g_name = $info -> {'groupName'}   // $g_name;
    $grs      = $info -> {'greps'}         // $grs;
    $ts = $info -> {'targetNos'};
  }else{
    say STDERR "    [ERROR]  not exist $ginfo_file";
    exit;
  }
  return ($g_name, $grs, $ts);
}

{ # parse cmd argument and option.  
  # read setting.
  require($config_file);
  our @_CONTAINERS;
  our @_containers_nos;
  @CONTAINERS = @_CONTAINERS; #ALL CONTAINERS_NAME array.
  @containers_nos = @_containers_nos; #ALL CONTAINERS NOs, corrsponded @

  GetOptions (
    'update=i' => \$update,
  );

  # set datas.
  my $greps = "";
  my @targets;
  my $index = 0; # argindex
  my @data = ();
  my $cno;
  my $cname;
  my $anything;
  # from group info.
  if ($update){
    $group_no = $update;
    my $ts;
    # windows
    #eval `./html_script/get_group_info.pl`;
    #die $@ if $@;
    ($group_name, $greps, $ts) = get_group_info($group_no);
    @targets = split(/ /, $ts);
    foreach $cno (@targets){
      @data = ($cno, $cname, $anything, $greps);
      $datas[$sum_datas] = [ @data ]; 
      $sum_datas = $sum_datas + 1;
    }
  }
  else{
    # from arguments.
    while ($index != ($#ARGV + 1) ){ # ARGV  = c_no1 anything {greps1} c_no2 anithing {grep3} ... c_noN anythingN {grepN}
      $cno   = $ARGV[$index];     $index = $index+1;
      $anything = $ARGV[$index]; $index = $index+1;
      while ($index != ($#ARGV + 1) && $ARGV[$index] !~ /^[0-9]$/){
        # untill number come.
        $greps = "$greps" . "$ARGV[$index] ";     
        $index = $index+1;
      }
      @data = ($cno, $cname, $anything, $greps);
      $datas[$sum_datas] = [ @data ];     
      $sum_datas = $sum_datas + 1;
    }
      # parse info.pl (get and set next group no.)
    if (-e $info_file){
      my $info=do($info_file);
      die "Error parsing $info_file: $@" if $@;
      die "Error reading $info_file: $!" unless defined $info;
      $group_no = $info -> {'nextGroupNo'}   // $group_no;
      $group_name = "group" . "$group_no";
    }
  }
  say STDERR "  log group N0: $group_no";
  say STDERR "  sum_datas : $sum_datas"; 
  say STDERR "  group name: $group_name";
  say STDERR "  greps     : $datas[0][0]";

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

sub get_new_menu($$){ # return new_menu.html (string of html type).
  my $group_home;
  my $time_stamp_day;
  my $time_stamp_time;
  ($time_stamp_day, $time_stamp_time) = @_;
  my $result;

  my $space = " ";
  my $spaces;
  $spaces = $space x 12;

  # set group link. 
  $result = "$spaces<!--$group_no-->\n";
  $result = $result . "$spaces<li><a href=\"./html_logs/group$group_no/group$group_no.html\" target=group>[NO:$group_no]$group_name $time_stamp_day $time_stamp_time</a></li>\n";
  $result = $result . "$spaces<ul class=\"group$group_no\">\n";
  # set targets list with each options.
  $spaces = $space x 16;
  # set each log link.
  my $cname= "";
  my $opt = "";
  my $cno = 0;
  for (my $i = 0; $i < $sum_datas; $i++){
    print "$cname \n"; # NOTE
    $opt    = $datas[$i][3];
    $cno    = $datas[$i][0];
    $cname  = $CONTAINERS[$cno];
    $result = $result . "$spaces<li><a href=\"./html_logs/group$group_no/group$group_no.html\" target=group>$cname</a> $opt</li>\n";
  }
  $spaces = $space x 12;
  $result = $result . "$spaces</ul>\n";	
  $result = $result . "$spaces<!--next-->\n";

  return $result;
}

# add menu to new each log link as group.
sub update_menu_page{
  my @lines;

  my $modify_lineno;
  if ($update){
    $modify_lineno = $group_no;
  }
  else{
    $modify_lineno = "next";
  }

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
    if ($line !~ /<!--$modify_lineno-->/){
      print $menus_fh2 "$line"; 
    }
    else{
      # if <!--$modify_lineno-->
      # get timeStamp 
      ($time_stamp_day, $time_stamp_time) = get_time_stamp();
      # print. get new menu.
      my $new_menu = get_new_menu($time_stamp_day, $time_stamp_time);
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
if (!$update){ 
  update_info_file();
}

my $log_group_folder = "./html_script/html_logs/group$group_no/";
my $log_group_home = "group$group_no" . ".html";
print "$log_group_folder\n";
print "$log_group_home\n";
mkdir "./html_script/html_logs/group$group_no" # NOTE: In windows, can't do
  or die "$log_group_folder is not maked error at <> : $!";

sub make_log_frame{
  my $log_frame_file;
  my $index;
  my $cno;
  my $franme_name;
  ($franme_name, $cno) = @_;
  $log_frame_file = "$log_group_folder" . "$franme_name" . ".html";

  my $tmp_file = "./tmp_" . "$cno" . ".html";
  move($tmp_file, $log_frame_file) or die "Can't move \"$tmp_file\" to \"$log_frame_file\": $!";
}

sub make_log_group_home{
  my $space = " ";
  my $spaces;
  my $cno;
  my $cname;
  my $opt;
  my $franme_name;
  my $result;
 
  open my $fh, ">", "$log_group_folder" ."$log_group_home"  # NOTE: create it  to logsFoder.
    or die "./html_script/html_logs/$log_group_home を書き込みモードでオープンすることができません。: $!";
  print $fh "<!DOCTYPE html>\n";
  print $fh "\n";
  print $fh "<html>\n";
  $spaces = $space x 4;
  print $fh "$spaces<h1>$group_name</h1>\n";
  for (my $i = 0; $i < $sum_datas; $i++){
    $cno   = $datas[$i][0]; 
    $cname = $CONTAINERS[$cno];
    $opt    = $datas[$i][3]; # greps
    # "$spaces<li>$cname $opt</li>\n";
    $franme_name = "group$group_no" . "-" . "$cno";
    print $fh "$space<font color=\"green\" size=\"4\">$cname:option{$opt}</font><br>\n";
    print $fh "$spaces<iframe src=\"$franme_name.html\" width=1100 height=400></iframe>\n";
    make_log_frame($franme_name, $cno);
    say STDERR "  maked log page [$cname, $opt]";
  }
  say STDERR "  updateed logs page!!";
  print $fh "</html>\n";
  close $fh;
}

sub make_group_info(){
  my $log_group_folder = "./html_script/html_logs/group$group_no/";
  my $group_info_file = $log_group_folder . "info.pl";
  my $cno;

  open(my $fh, ">", $group_info_file)
  or die "Cannot open $group_info_file: $!";
  my @targets = ();
  for (my $i = 0; $i < $sum_datas; $i++){
    $cno   = $datas[$i][0]; 
    push(@targets, $cno);
  }
my $line = <<"EOS";
#NOTE: don't config!
{
groupName => "$group_name",
greps => "$datas[0][3]",
targetNos => "@targets",
updateInterval => "",
}
EOS
  return $line;
}

make_log_group_home();

if (!$update){
  make_group_info();
}
