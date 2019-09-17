#!/usr/bin/env perl

use Pod::Usage;

use strict;
use warnings;
# symbol
use Fcntl;
use Getopt::Long qw(GetOptions);
use Pod::Usage;
use feature qw(say);
use strict;
use YAML ();
use Data::Dumper ();

# option
my $checkSetting = "";
my $setup = "";
my $default = "";
my $exec = "";
my $timestamp = "";

{ # parse cmd argument.
  GetOptions (
    # handle imgaes
    'checkSetting' => \$checkSetting,
    'default'      => \$default,
    'setup'        => \$setup,
    'exec'         => \$exec,
    'timestamp'         => \$timestamp,
  ) or pod2usage();
}

# open and read config.yaml
my $filename = "./config.yaml";
open(IN, $filename) or die("cannot open $filename.: $!");
read(IN, my $input, (-s $filename));
close(IN);
my $yaml = YAML::Load("$input");

# write config info to config_info.pl.
my $infoFIle="./config_info.pl";

#ENV VARIABLES###############################################################
my @CONTAINERS = (); #ALL CONTAINERS_NAME array.
my @containers_nos = (); #ALL CONTAINERS NOs, corrsponded @
my @CMD = (); # ALL COMMAND. be enable to serach cmd_no. 実際に実行されるcmd
my @cmd_names = (); # cmd_name (ex. json, syslog, .)
my @cmd_nos = (); #cmd_no array used to search command.
my @USING = (); # コンテナが使うコマンドの番号の配列(コンテナ番号の配列と対応している). cmd_no array that is enable to search container_no.
my @DEFAULT_CONTAINERS = (); #conteriner_no array.
#ENV VARIABLES#######################################################

sub get_cno_from_cname($){
  my $cname;
  ($cname) = @_;
  my $cno;
  foreach $cno (@containers_nos){
    if ($CONTAINERS[$cno] eq $cname){
      return $cno;
    }
  }
}

sub get_cmdno_from_cmdName($){
  my $cmd_name;
  ($cmd_name) = @_;
  my $cmno;
  foreach $cmno (@cmd_nos){
    if ($cmd_names[$cmno] eq $cmd_name){
      return $cmno;
    }
  }
}

# read config data from yaml.
sub read_yaml{
  my $no = 0;
  if ($checkSetting) { 
    print Data::Dumper::Dumper($yaml);
    print "container ---------------------------------\n";
  }
  # read containers.
  my $con_hashs = $yaml->{"containers"};
  for my $proj (keys %$con_hashs) {
    my @cons = @{$con_hashs->{$proj}};
    foreach my $con (@cons){
      my $c_name;
      if ($proj eq "none"){ $c_name = "$con"; }
      else { $c_name = "$proj" . "_" . "$con"; }
      push(@CONTAINERS, $c_name);
      push(@containers_nos, $no++);
    }
    if ($checkSetting) { print "[$proj] : @{$con_hashs->{$proj}}\n"; }
  }
  $no = 0;
  # read commands.
  if ($checkSetting) { print "cmd ---------------------------------------\n"; }
  my $cmd_hashs = $yaml->{"cmd"};
  for my $hash (sort keys %$cmd_hashs) {
    my $cmd = "$cmd_hashs->{$hash}";
    push (@cmd_names, $hash);
    push(@CMD, $cmd);
    push(@cmd_nos, $no++);
    if ($checkSetting) { print "$hash : $cmd_hashs->{$hash}\n"; }
  }
  $no = 0;

  if ($checkSetting) { print "using ------------------------------------\n"; }
  # @USING init
  for my $cno (@containers_nos){
    @USING[$cno] = -1;
  }
  my $using = $yaml->{"using"};
  for my $cmd (keys %$using) {
    my @cons = @{$using->{$cmd}};
    #print "[$cmd] : $con\n";
    for my $con (@cons){
      @USING[get_cno_from_cname($con)] = get_cmdno_from_cmdName($cmd);
    }    
  }
  if ($checkSetting) { print "\n"; }

  if ($checkSetting) { print "  --- All containers ---\n"; }
  foreach my $cno (@containers_nos){
    if ($checkSetting) { 
      print "no: $containers_nos[$cno]\n";
      print "-> conteiner:$CONTAINERS[$cno]\n";
      print "-> using cmd: {$CMD[$USING[$cno]]}\n";
    }
  }
  print "       --- cmds ---\n"; 
  foreach my $no (@cmd_nos){
    print "no: $cmd_nos[$no]\n";
    print "cmds-> $CMD[$no]\n";
    print "name-> $cmd_names[$no]\n";
  }
  print "     --- defaults ---\n";
  my @defaults = @{$yaml->{"defaults"}};
  my $defau_sum = $#defaults;
  print "sum: $defau_sum\n";
  foreach my $def (@defaults){
    for (my $i = 0; $i < $#CONTAINERS; $i++){
      if ($CONTAINERS[$i] eq $def){
        push(@DEFAULT_CONTAINERS, $i);
      }
    }
  }
  print "default: \n";
  foreach my $cno (@DEFAULT_CONTAINERS){
    print(  "no $cno-> $CONTAINERS[$cno]\n");
  }
}

# write data to yml_info.pl.
sub write_data{
  my @containers = split /\s+/, "@CONTAINERS";
  #print @containers;
  my $flg = 0;

  my $cons = "(";
  my $conNos= "("; 
  my $using = "(";
  for my $i (@containers_nos){
    if ($flg++ > 0){
      $cons = $cons . ", $CONTAINERS[$i]";
      $conNos = $conNos . ", $containers_nos[$i]";
      $using = $using . ", $USING[$i]"
    }else {
      $cons = $cons . "$CONTAINERS[$i]";
      $conNos = $conNos . "$containers_nos[$i]";
      $using = $using . "$USING[$i]"
    }
  }
  $cons = $cons . ")";
  $conNos = $conNos . ")";
  $using = $using . ")";

  my $cmd = "(";
  my $cn = "(";
  my $cmd_str = "(";

  $flg = 0;
  for my $no (@cmd_nos){
    if ($flg++ > 0){
      $cmd_str = $cmd_str . ", $cmd_names[$no]";
      $cn      = $cn      . ", $cmd_nos[$no]";
      $cmd      = $cmd      . ", \"$CMD[$no]\""
    }else{
      $cmd_str = $cmd_str .  $cmd_names[$no];
      $cmd = $cmd . "\"$CMD[$no]\"";
      $cn = $cn . $cmd_nos[$no];
    }
  }
  $cmd = $cmd . ")";
  $cn = $cn . ")";
  $cmd_str = $cmd_str . ")";

  # default
  $flg = 0;
  my $defa_str = "(";
  for my $cno (@DEFAULT_CONTAINERS){
    if ($flg++ > 0){
      $defa_str = $defa_str . ", $cno";
    }else{
      $defa_str = $defa_str . $cno;
    }
  }
  $defa_str = $defa_str .")";

my $line = <<"EOS";
#NOTE: don't config!
our \@_CONTAINERS = $cons; 
our \@_containers_nos = $conNos;
our \@_CMD = $cmd;
our \@_cmd_names = $cmd_str;  
our \@_cmd_nos = $cn;
our \@_USING = $using;
our \@_DEFAULT_CONTAINERS =  $defa_str;
1;
EOS
  return $line;
}

sub write_pl{
  # make str.
  my $line = write_data();
  if($checkSetting){
    print $line;
  }
  # write to info.pl
  open (my $fh, ">", $infoFIle) or die "$!"; 
  print $fh $line;    
  close ($fh);
}

sub read_pl{
  require($infoFIle);
  our @_CONTAINERS;
  our @_containers_nos;
  our @_CMD;
  our @_cmd_names;
  our @_cmd_nos;
  our @_USING;
  our @_DEFAULT_CONTAINERS;

  @CONTAINERS = @_CONTAINERS; #ALL CONTAINERS_NAME array.
  @containers_nos = @_containers_nos; #ALL CONTAINERS NOs, corrsponded @
  @CMD = @_CMD; # ALL COMMAND. be enable to serach cmd_no. 実際に実行されるcmd
  @cmd_names = @_cmd_names; # cmd_name (ex. json, syslog, .)
  @cmd_nos = @_cmd_nos; #cmd_no array used to search command.
  @USING = @_USING; # コンテナが使うコマンドの番号の配列(コンテナ番号の配列と対応している). cmd_no array that is enable to search container_no.
  @DEFAULT_CONTAINERS = @_DEFAULT_CONTAINERS; #conteriner_no array.  
  if($checkSetting){
    print "\n";
    print "cmd_nos => @cmd_nos\n";  
    print "cmd     => @CMD\n";
    print "cmd names => @cmd_names\n";
    print "conteiner_no => @containers_nos\n";
    print "conteiners => @CONTAINERS \n";
    print "USING       => @USING\n";
    print "defaults    => @DEFAULT_CONTAINERS";
  }
}

###############################  MAIN ##################
my $cname;
my $cno;
my $logStr;
my $path_file; # this is ..../myscript/logs/#cname.log

my @toCall;
sub main(){
  ($cno) = $ARGV[0];
  # set toCalls. #########
  my $command ="";
  $command = "$CMD[$USING[$cno]]" ;#. "$CONTAINERS[$cno]";
  if ($command =~ /\[target\]/){
    $command =~ s/\[target\]/$CONTAINERS[$cno]/;
    push(@toCall, $command);
  }
  else {
    push(@toCall, $CMD[$USING[$cno]]); #command.
    push(@toCall, $CONTAINERS[$cno]);  #conteiner_name.
  }
  if ($timestamp && $cmd_names[$cno] eq "json"){
    push(@toCall, "-t")              #timestamp option.
  }
  # exec. 
  print  "  # at get_log.pl--- toCall: \"@toCall.\" !";
  my $logStr = `@toCall 2>&1`;

  # return.
  return $logStr;
}

if ($setup){
  read_yaml();
  #yesorno();
  write_pl();
}
elsif ($checkSetting){
  read_pl();
}
if ($exec){
  read_pl();
  main();
}
