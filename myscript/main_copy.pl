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
my @dists   = (); # path of logFile copied by this script.
# info file.
my $info_file = "./config_info.pl";
# dist_folder 
my $dist_folder = "~/tmp/";
my $dist_extension = ".log";
# greps
my @greps = (); #
# groups.
my $g_no = -1;
my $g_name = "";
my $group_folder;
my $ginfo_file; # group info file.

##########################################################
{ # parse config and read command line arguments. 
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


{ # utility functions. get_grep_patturn(), yesno, get_targets_oneline, get_group_info
  sub set_grep_patturn{ # get grep-patturns, it is gived as this-> ./main.pl error warn network connect GET
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

  sub get_targets_oneline(){
    my $str = "";
    foreach my $cno (@targets){
      $str = $str . "$CONTAINERS[$cno] ";
    }
    return $str;
  }

  sub get_group_info($){ # parse argument. argument is groupNo.
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

{ #set targets, grep-patturns, group_info and dist_paths. 

  if ($update){
    # set group info.
    if ($interactive){
      say STDERR "sorry..., This script isn't covered --update option and --interactive option is selected both... pls improve...";
      exit;
    }
    else{   # get and set group info.
      $g_no = $update;
      my $ts;
      eval `./html_script/get_group_info.pl`;
      die $@ if $@;
      ($g_name, $greps[0], $ts) = get_group_info($g_no);
      @targets = split(/ /, $ts);
    }
  }else{
    # set targets.
    if ($interactive){
      my $yesno = yesno("   TARGET SELECT FROM: y-> ALL CONTAINER / no-> [DEFAULTS]");
      if ($yesno){ 
        # from All containers.
        for my $cno (@containers_nos){
          if (yesno("    $CONTAINERS[$cno]")){
              push(@targets, $cno);
          }
        }
      }
      else{
        # from defaults.
        for my $cno (@DEFAULT_CONTAINERS){
          if (yesno("    $CONTAINERS[$cno]")){
              push(@targets, $cno);
          }
        }
      }
    }else{
      # NOTE: NO FURTURED.
      @targets = @DEFAULT_CONTAINERS;
    }
    # set greps.
    set_grep_patturn();
  }

  if ($save){
    # set dist path.
    my $path = '';
    # set file_path
    for my $cno (@targets){
      $path = "$dist_folder" . "$CONTAINERS[$cno]" . "$dist_extension";
      push(@dists, $path);
    }
  }
}

# debug.
if($debug) {
  if($update){
    # updata.
    say STDERR "    groupNOs: $g_no";
    say STDERR "    [INFO]  GET group_info in $g_no.";
    say STDERR "      \$group_name =  $g_name";
    say STDERR "      \$greps      =  $greps[0]";
    say STDERR "      \@targets    =  " . "@targets"; 
  }
  else{
    # without update. print targets.
    say STDERR "  variables: ";
    for my $cno (@targets){
      my $yes_or_no = "";
      if (grep { $_ eq $cno} @targets){ 
        $yes_or_no = "yes";
      }else{
        $yes_or_no = "no";
      }
      say STDERR "    $CONTAINERS[$cno]     = $yes_or_no";
    }
  }
  say STDERR "    \$debug      = $debug";

  if ($save){
    # print paths.
    say STDERR "  Distination: ";
    say STDERR "    \$folder          = $dist_folder";
    for (my $i = 0; $i <  $#targets; $i++){
      say STDERR "    $CONTAINERS[$targets[$i]]_path      = `$dists[$i]"; 
    }
  }

  if (!$update){
    say STDERR "  greps:";
    say STDERR "    patturn => @greps";
    say STDERR "    targets => " . get_targets_oneline();
  }
  say STDERR ""; 
  my $isYes = yesno("are you ok ?");
  if(!$isYes){ exit }
}

{ # main function.
  # get_log(): get_log from @_(cname),
  # save()   : And save to @paths when user select --save option,
  # look()   : And look,  when user select --look option.
  # update() : 

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
  my $arg = ""; # aruguments for --html and --update options, handed over to  other program.
  my $logStr = "";  # get_log's result.

  say STDERR "------ [main] ------";
  foreach my $cno (@targets) {  
    $count = $count+1;
    $cname = $CONTAINERS[$cno];
    say STDERR "[COMORNENT]-$cname, greps-$greps[0]      :$count";

    # get_log. $res
    say STDERR "  \$logStr =  ./get_log.pl $cno --exec";
    $logStr = get_log($cno, $cname);

    if ($update){
      say STDERR "  ---[update]---";
      say STDERR "   exec: \$logstr | , make_modifiedLog.pl --update (gno=$g_no, cno=$cno)";
      # make_modifiedLog.pl --update
      $arg = "$g_no" . " " . "$cno " . $greps[0];
      open(my $fh, "| ./html_script/make_modifiedLog.pl --update  $arg")
        or die "Couldn't open less cmd : $!";
      print $fh "$logStr";
      close($fh);
      $arg = "$g_no $greps[0]";
      # generate_html.pl --update
      if ($count == ($#targets+1)){
        say STDERR   " [INFO] EXEC generate_html --update(arg:$arg)";
	      # arg : cno anything greps cno2 anything greps2...
        system(`./html_script/generate_html.pl --update $arg`) == 0
		      or die "Couldn't system ./html_script/generate_html.pl --update: $!";
      }

    }

    if ($lookonly){
      say STDERR "  ---[lookonly]---";
      say STDERR "   exec:look(\$logStr)"; # 
      look($logStr);
    }
    if ($save){
      say STDERR "  ---[save]---";
      say STDERR "   exec:save(\$path, \$logStr)"; 
      save($dists[$count-1], $logStr);
    }
    if ($html){
      say STDERR "  ---[html]---";
      say STDERR "   [INFO] EXEC \$logStr | ./html_script/make_modifiedLog.pl arg=(\$cno=$cno, \@greps=$greps[0])"; # modify_log.pl. and generate_html.
      my $grep = $greps[0];
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

