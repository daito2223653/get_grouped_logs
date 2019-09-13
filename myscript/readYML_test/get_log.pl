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

# open and read config.yaml
my $filename = "./config_test.yaml";
open(IN, $filename) or die("cannot open $filename.: $!");
read(IN, my $input, (-s $filename));
close(IN);
my $yaml = YAML::Load("$input");

#ENV VARIABLES###############################################################
my @CONTAINERS = (); #ALL CONTAINERS_NAME array.
my @containers_nos = (); #ALL CONTAINERS NOs, corrsponded @
my @CMD = (); # ALL COMMAND. be enable to serach cmd_no. 実際に実行されるcmd
my @cmd_names = (); # cmd_name (ex. json, syslog, .)
my @cmd_nos = (); #cmd_no array used to search command.
my @USING = (); # コンテナが使うコマンドの番号の配列(コンテナ番号の配列と対応している). cmd_no array that is enable to search container_no.
my @DEFAULT_CONTAINERS = (); #conteriner_no array.
#ENV VARIABLES#######################################################

sub read_yaml{
  my $no = 0;
  if ($checkSetting) { 
    print Data::Dumper::Dumper($yaml);
    print "container ---------------------------------\n";
  }
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

sub get_envStr{
  my @containers = split /\s+/, "@CONTAINERS";
  #print @containers;
  my $cmd_str = "";
  my $flg = 0;
  print @USING, "\n";

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

  print "$using\n";

  $flg = 0;
  for my $cmd (@CMD){
    if ($flg++ > 0){
      $cmd_str = $cmd_str . ", $cmd";
    }else{
      $cmd_str = $cmd;
    }
  }


my $line = <<"EOS";
#NOTE: don't config!
CONTAINERS => @CONTAINERS; 
containers_nos => @containers_nos;
CMD => $cmd_str;
cmd_names => @cmd_names;  
cmd_nos => @cmd_nos;
USING => @USING;
DEFAULT_CONTAINERS => @DEFAULT_CONTAINERS;
EOS

  return $line;
}

sub writeEnv_from_yaml{
  my $outputFile="YML_info.pl";
  # make str.
  my $line = get_envStr();
  
  print $line;
  open (my $fh, ">", $outputFile) or die "$!"; 
    print $fh $line;    
  close ($fh);
}

###############################  MAIN ##################
{ # parse cmd argument.
  GetOptions (
    # handle imgaes
    'checkSetting' => \$checkSetting,
    'default'      => \$default,
    'setup'        => \$setup,
    'exec'         => \$exec,
  ) or pod2usage();
}

my $cname;
my $cno;
my $logStr;

my $path_file; # this is ..../myscript/logs/#cname.log

# $path;

sub main(){
  print "\nmain\n";
  ($cname) = $ARGV[0];
  $cno = get_cno_from_cname($cname);
  print "cno $cno : $cname\n";
  $logStr = "EXEC: $CMD[$USING[$cno]] $CONTAINERS[$cno]\n";
  print $logStr;
  return ($logStr, "gheajgjoo");
}

if ($setup){
  read_yaml();
  #yesorno();
  writeEnv_from_yaml();
}elsif ($checkSetting){
	#read_env();
}
if ($exec){
  main();
}

sub test{
  return "test";
}

