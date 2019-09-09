#!/usr/bin/perl
package HtmlPackage;

use Time::Piece;

use strict;

our $test = "test";
our $logs_no;
our @datas;
our $sum_datas = 0;

sub get_time_stamp(){ # return now-time_stamp_daya and  now-time_stamp_time.
  my @wdays = ( "日", "月", "火", "水", "木", "金", "土"); 
  my $time = time();
  my ($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($time);
  $year = $year+1900; $mon = $mon +1; 
  my $time_stamp_day  = "$year" . "/" . "$mon" . "/" . "$mday" . "(" . "$wdays[$wday]" . ")";
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

1;