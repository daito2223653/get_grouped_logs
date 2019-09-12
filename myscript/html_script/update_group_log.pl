

sub modify_log{
  my $toCall;
  $tmp_HTML = "./tmp/" . "tmp_" . "$cno" . ".html";
  # cno
  my $cno = -1;
  ($cno) = $ARGV[0];
  # open.
  say STDERR "    make : temporatory html made from log.";
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

