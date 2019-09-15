#!/usr/bin/env perl

use Pod::Usage;

use strict;
use warnings;

# symbol
use Fcntl;

use Getopt::Long qw(GetOptions);
use Pod::Usage;

use feature qw(say);

######################################################################################
# NOTE: ?
=head1 SYNOPSIS
 written by daito 
 this script is to get logs from sw360chore's Container.

 # how to use---
   ./get_conpornentlog.pl [compornent] [targetFile]  [option]
  ## [conpornent]
     sw360=liferay=tomcat
     couchdb
     fossology
     postgresql
     nginx
  ## [option]
     --timestamp : include timestamp
     --config : コンフィグファイルを読んで, 作成する. (default)
     --interactive 
     --lokkOnly
     --save
     --html
     grep-patturn: cmd arguments
     --update [$group_no] : update from groupNOs. 
 
 # evironmental variables---
 ## $COMPORNENT
    is the compornent name of the chores containers
 ## $TARGET
    is the target file name of the $COMPORNENT's log. Default is $COMPORNET_{no}.log
=cut

 ##############################################################################
# read options
my $timestamp = '';
my $config  = '1';
my $lookonly = '';
my $interactive = '';
my $save = "";
my $html = "";
my $update = "";
my $setup = "";
my $checkSetting = "";
my $debug      = '1';

# setting info.
my @containers_nos;# COMPORNENT_NO.
my @CONTAINERS;# COMPORNENT_NAME.
my @DEFAULT_CONTAINERS;# default containers.
my @targets = (); # conteiners user select. 
my $paths   = (); # path of logFile copied by this script.
# info file.
my $info_file = "./config_info.pl";
# return log(string type) to call get_log.pl and conteniner_no as command argument.
# log_folder/
# defaults.
my $log_folder = "~/tmp/";
my $log_extension = ".log";

# greps
my @greps = (); #
# group.
my $g_no = -1;
my $g_name = "";
my $group_folder;
my $ginfo_file; # group info file.

##########################################################
{ # parse config and read command line arguments
  GetOptions (
    # handle imgaes
    'timestamp' => \$timestamp,
    'config' => \$config,
    'interactive' => \$interactive,
    'lookonly' => \$lookonly, 
    'save'     => \$save,
    'html'     => \$html,
    'update=i' => \$update,
  ) or pod2usage();
  
  # read setting.
  require($info_file);
  our @_CONTAINERS;
  our @_containers_nos;
  our @_DEFAULT_CONTAINERS;
  @CONTAINERS = @_CONTAINERS; #ALL CONTAINERS_NAME array.
  @containers_nos = @_containers_nos; #ALL CONTAINERS NOs, corrsponded @
  @DEFAULT_CONTAINERS = @_DEFAULT_CONTAINERS; #conteriner_no array.  
}

{ # utility
  sub get_grep_patturn{ # get grep-patturns, it is gived as this-> ./main.pl error warn network connect GET
    # --interactive : you can type grep_patturns each compornents. when greps gived as cmd_argument, all compornents target.
    my $grep = "";
    foreach my $arg (@ARGV){
      $grep = $grep . "$arg ";
    }
    push(@greps, $grep);
  }
 
  sub yesno{
    my $comment = shift;
    my $default = shift;
    if($default){
      $comment .= " [y]/n> ";
    }else{
      $comment .= " y/[n]> ";
      $default = 0;
    }
    my $prv = $|;
    $| = 1;
    print $comment;
    $| = $prv;
    my $ans = <STDIN>;
    chomp($ans);
    $ans = uc($ans);
    if($ans eq 'Y'){
      return(1);
    }elsif($ans eq 'N'){
      return(0);
    }
    return($default);
  }

  sub get_yesOrNo{
    my $isyes;
    ($isyes) = @_;

    if($isyes){
      return "yes";
    }
    else{
      return "no";
    }
  }

  sub get_oneStr_targets(){
    my $str = "";
    foreach my $cno (@targets){
      $str = $str . "$CONTAINERS[$cno] ";
    }
    return $str;
  }

  sub get_group_info{ # parse argument. argument is groupNo.
    my $group_no;
    ($group_no) = @_;
    $group_folder = "./html_script/html_logs/group$group_no/";
    $ginfo_file    = "$group_folder" . "info.pl";

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
}

if($debug) {
  # updata.
  if ($update){
    if ($interactive){
      say STDERR "sorry..., This script isn't covered --update option and --interactive option is selected both... pls improve...";
      exit;
    }
    $g_no = $update;
    say STDERR "  updates: ";
    say STDERR "    groupNOs: $g_no";
    say STDERR "    [INFO]  GET group_info in $g_no.";
    my $ts;
    eval `./html_script/get_group_info.pl`;
    die $@ if $@;
    # get group info.
    ($g_name, $greps[0], $ts) = get_group_info($g_no);
    @targets = split(/ /, $ts);
    say STDERR "      \$group_name =  $g_name";
    say STDERR "      \$greps      =  $greps[0]";
    say STDERR "      \@targets    =  @targets"; 
  }
  else{
    say STDERR "  variables: ";
    # set targets.
    for my $cno (@DEFAULT_CONTAINERS){
      if($interactive){
        if (yesno("    $CONTAINERS[$cno]")){
          push(@targets, $cno);
        }
      }else{
        push(@targets, $cno);
      }
    }
    # print conteiners user select.
    for my $cno (@DEFAULT_CONTAINERS){
      my $yes_or_no = "";
      if (grep { $_ eq $cno} @targets){ 
        # targets == conteriner no in DEFAULT_CONTAINERS.
        $yes_or_no = "yes";
      }else{
        $yes_or_no = "no";
      }
      say STDERR "    $CONTAINERS[$cno]     = $yes_or_no";
    }
    say STDERR "    \$debug      = $debug";
  }
  # print paths.
  if ($save){
    say STDERR "  Log_path: ";
    say STDERR "    \$folder          = $log_folder";
    foreach my $cno (@DEFAULT_CONTAINERS){
      say STDERR "    \$$CONTAINERS[$cno]_path      = `$CONTAINERS[$cno].$log_extension"; }
  }
}

{ # get_log(): get_log from @_(cname),
  # save()   : And save to @paths when user select --save option,
  # look()   : And look,  when user select --look option.
  # update() : 

  # set ENV
  ## cmd
  my @cmd = ("docker", "logs");    
  my @toCall; push(@toCall, @cmd); # cmd and arguments
  ## compornent_name
  my $cname;                  
  my $cno;

  sub save{
    my $path;
    my $logs;
    ($path, $logs) = @_;
    say STDERR "   [INFO] \$logs >  $path ";
    
    # open
    open(my $fh, ">", $path)
      or die "Cannot open $path: $!";
    # write
    print $fh "$logs";
    # close and debug
    close($fh);
    say STDERR "   [INFO] path=$path, write COMPORNENT's log.";
  }

  sub look{
    my $logs;
    ($logs) = @_;
    say STDERR "   [INFO] \$logs | less ";
    open(my $fh, "| less")
      or die "Couldn't open less cmd : $!";
    print $fh "$logs";
    close($fh);
  }

  sub get_log{
    my $cno = -1;
    ($cno, $cname) = @_; 
    # error hundler
    if ($cno < 0 and 5 < $cno){ # NOTE: dokcer_compornent is not exist error
      say STDERR "cno is more 0 least 5. error at line 141. get_log function";
      exit 
    } 
    if ($timestamp){
      return `./get_log.pl $cno --exec --timestamp`;
    }
    else{
      return `./get_log.pl $cno --exec`;
    }
  }
}

# main -----------
sub main{ # exec ALL cmd, it is based on option.
  my $count = 0; #exec count.
  my $cname; # compornent_name # = $project_name . "_sw360";
  my $cno;   # compornent_no.
  
  my $arg = ""; # for generate_html.pl 

  say STDERR "------ [main] ------";
  foreach my $cno (@targets) {  
    $count = $count+1;
    $cname = $CONTAINERS[$cno];
    say STDERR "[COMORNENT]-$cname, greps-$greps[0]      :$count";

    # get_log. $res
    say STDERR "  \$logStr =  ./get_log.pl $cno --exec";
    my $logStr = get_log($cno, $cname);

    if ($update){
      say STDERR "  ---[update]---";
      say STDERR "   exec: \$logstr | , update_log(gno=$g_no, cno=$cno)";
      my $arg = "$g_no" . " " . "$cno";
      open(my $fh, "| ./html_script/make_modifiedLog.pl --update  $arg")
        or die "Couldn't open less cmd : $!";
      print $fh "$logStr";
      close($fh);
    }

    if ($lookonly){
      say STDERR "  ---[lookonly]---";
      say STDERR "   exec:look(\$logStr)"; # 
      look($logStr);
    }
    if ($save){
      say STDERR "  ---[save]---";
      say STDERR "   exec:save(\$path, \$logStr)"; 
      my $path = '';
      # set file_path
      $path = "$log_folder" . "$CONTAINERS[$cno].$log_extension";
      save($path, $logStr);
    }
    if ($html){
      say STDERR "  ---[html]---";
      # if $interactive say STDERR "   exec: \$logStr | ./html_script/make_modifiedLog.pl arg=(\$cno=$cno, \@greps=$greps[$count-1])"; # modify_log.pl. and generate_html.
      say STDERR "   [INFO] EXEC \$logStr | ./html_script/make_modifiedLog.pl arg=(\$cno=$cno, \@greps=$greps[0])"; # modify_log.pl. and generate_html.
      #if ($interactive){ my $grep = $greps[$count-1]; }
      #else {  
      my $grep = $greps[0];
      #}
      open(my $fh, "| ./html_script/make_modifiedLog.pl  $cno $grep")
        or die "Couldn't open less cmd : $!";
      print $fh "$logStr";
      close($fh);

      $arg = $arg ."$cno " . "none " . "$greps[0] ";
      if ($count == ($#targets+1)){
        say STDERR   " [INFO] EXEC generate_html (arg:$arg)";
	      # arg : cno anything greps cno2 anything greps2...
        system(`./html_script/generate_html.pl $arg`) == 0
		or die " [ERROR]Couldn't system ./html_script/generate_html.pl: $!";
      }
    }
    say STDERR "   [INFO] CMD ok! \n";
  }
  return 1;
}


# main -----------
if (main()){
  say STDERR "-----------  all ok!! ------------";
}

