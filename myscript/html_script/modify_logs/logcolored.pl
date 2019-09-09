#!/usr/bin/perl
#
# 標準入力から渡された文字列の中に、
# このスクリプトへの引数で渡された文字列が含まれる場合は
# 着色して出力するスクリプト

$| = 1;

if ( $#ARGV > 5 ) {
        print "Please use within 6 keywords. abort.\n";
        exit 1;
}

while( <STDIN> ) {
        for ( my $i = 0 ; $i <= $#ARGV ; $i ++ ) {
                my $color=sprintf "%dm", $i + 31;
                s/$ARGV[$i]/\033\[1;$color$&\033\[0m/gi
        }
} continue {
  print $_;
}
exit 0;