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

 # evironmental variables---
 ## $COMPORNENT
    is the compornent name of the chores containers
 ## $TARGET
    is the target file name of the $COMPORNENT's log. Default is $COMPORNET_{no}.log
=cut

 ##############################################################################

# COMPORNENT_NO
my $SW360 = 0;
my $COUCHDB = 1;
my $FOSSOLOGY = 2;
my $POSTGRESQL = 3;
my $NGINX = 4;
my $CSV_SEARCH = 5;
# COMPORNENT_NAME
my @COMPORNENTS = ("sw360", "couchdb", "fossology", "postgres", "nginx", "csv_search"); # $sw360 = catalina / liferay
my $project_name;; # NOTE: not furtured . get PROJECT NAME function from sw360chores's configuration.

# read options
my $timestamp = '';
my $config  = '1';
my $lookonly = '';
my $interactive = '';
my $save = "";
my $html = "";
my $debug      = '1';

# variables of compornents
my $sw360 = ''; # $sw360 = catalina / liferay
my $couchdb = '';
my $fossology = '';
my $postgresql = '';
my $nginx      = '';
my $csv_search = '';
#  path of logFiles.
my $logFolder     = '';
my $sw360_path = '';
my $couchdb_path = '';
my $fossology_path = '';
my $postgresql_path = '';
my $nginx_path      = '';
my $csv_search_path = '';

# target
my @targets = (); # compornent no of sw360chores
my @paths   = (); # path of logFile copied by this script.

##########################################################
{ # parse config and read command line arguments
  my $configFile = "../configuration/configuration.pl";
  if(-e $configFile) {
    my $config=do($configFile);
    die "Error parsing $configFile: $@" if $@;
    die "Error reading $configFile: $!" unless defined $config;
    $project_name = $config->{'projectName'} // $project_name;
    #$cveSearch = $config->{'cveSearch'} // $cveSearch;
  } 	
	
  my $targetFile = "./target.pl";
  # my $pathFile = "./path.pl";
  my $pathFile   = "./path.pl";

  if(-e $targetFile) {
    my $target=do($targetFile);
      die "Error parsing $targetFile: $@" if $@;
      die "Error reading $targetFile: $!" unless defined $target;

    if(!$interactive) {
      $sw360 = $target->{'sw360'} // $sw360;
      $couchdb = $target->{'couchdb'} // $couchdb;
      $fossology = $target->{'fossology'} // $fossology;
      $postgresql = $target->{'postgresql'} // $postgresql;
      $nginx = $target->{'nginx'} // $nginx;
      $csv_search = $target->{'csv_search'} // $csv_search;
    }
    $debug = $target->{'debug'} // $debug;
  }

  if (-e $pathFile){
    my $path=do($pathFile);
      die "Error parsing $pathFile: $@" if $@;
      die "Error reading $pathFile: $!" unless defined $pathFile;

    $logFolder  = $path->{'folder'} // $logFolder;
    $sw360_path = $path->{'sw360'} // $sw360_path;
    $couchdb_path = $path->{'couchdb'} // $couchdb_path;
    $fossology_path = $path->{'fossology'} // $fossology_path;
    $postgresql_path = $path->{'postgresql'} // $postgresql_path;
    $nginx_path = $path->{'nginx'} // $nginx;
    $csv_search_path = $path->{'csv_search'} // $csv_search_path;
  
    push(@paths, $logFolder . "/" . $sw360_path);
    push(@paths, $logFolder . "/" . $couchdb_path);
    push(@paths, $logFolder . "/" . $fossology_path);
    push(@paths, $logFolder . "/" . $postgresql_path);
    push(@paths, $logFolder . "/" . $nginx_path);
    push(@paths, $logFolder . "/" . $csv_search_path);
  }

  GetOptions (
    # handle imgaes
    'timestamp' => \$timestamp,
    'config' => \$config,
    'interactive' => \$interactive,
    'lookonly' => \$lookonly, 
    'save'     => \$save,
  ) or pod2usage();

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

if($debug) {
  say STDERR "  variables: ";
  if($interactive){
    if(!yesno("    sw360")){ $sw360 = 0;  }else {$sw360 = 1;}
    if(!yesno("    couchdb")){ $couchdb = 0;  }else {$couchdb = 1;}
    if(!yesno("    fossology")){ $fossology = 0;  }else {$fossology = 1;}
    if(!yesno("    postgresql")){ $postgresql = 0;  }else {$postgresql = 1;}
    if(!yesno("    nginx")){ $nginx = 0;  }else {$nginx = 1;}
    if(!yesno("    csv_search")){ $csv_search = 0;  } else {$csv_search = 1;}
  }
  say STDERR "    \$sw360      = $sw360";
  say STDERR "    \$couchdb    = $couchdb";
  say STDERR "    \$fossology  = $fossology";
  say STDERR "    \$postgresql = $postgresql";
  say STDERR "    \$nginx      = $nginx";
  say STDERR "    \$csv_search = $csv_search";
  say STDERR "    \$debug      = $debug";
  if ($sw360 == 1){ push(@targets, 0); } 
  if ($couchdb == 1){ push(@targets, 1); } 
  if ($fossology == 1){ push(@targets, 2); } 
  if ($postgresql == 1){ push(@targets, 3); } 
  if ($nginx == 1){ push(@targets, 4); } 
  if ($csv_search == 1){ push(@targets, 5); };

  # if default 
  #   say STDERR "  targetLog_path(default):
  # else 
  #   say STDERR "  target ~ (custum)
  say STDERR "  Log_path: ";
  say STDERR "    \$folder          = $logFolder";
  if ($sw360) { say STDERR "    \$sw360_path      = $sw360_path"; }
  if ($couchdb){say STDERR "    \$couchdb_path    = $couchdb_path";}
  if ($fossology){say STDERR "    \$fossology_path  = $fossology_path";}
  if ($postgresql){say STDERR "    \$postgresql_path = $postgresql_path";}
  if ($nginx){say STDERR "    \$nginx_path      = $nginx_path";}
  if ($csv_search){ say STDERR "    \$csv_search_path = $csv_search_path";}
  say STDERR ""; 

  my $isYes = yesno("are you ok ?");
  if(!$isYes){ exit }
}

{ # get_log(): get_log from @_(cname),
  # save()   : And save to @paths when user select --save option,
  # look()   : And look,  when user select --look option.
 
  # set ENV
  ## cmd
  my @cmd = ("docker", "logs");    
  my @toCall; push(@toCall, @cmd); # cmd and arguments
  ## compornent_name
  my $cname;                  
  my $cno;

  sub save{
    my $cno;
    my $path = '';
    ($cno, $path) = @_;
    
    # open
    open(my $fh, ">", $path)
      or die "Cannot open $path: $!";
    my $echos = `@toCall 2>&1`;
    # error hundler
    if ($echos =~ "^Error"){
      print "   [ERROR] $echos";
      exit;
    }
    # write
    print $fh `@toCall 2>&1`;
    # close and debug
    close($fh);
    say STDERR "   [INFO] path=$path, write COMPORNENT's log.";
  }

  sub look{
    open(my $fh, "| less")
      or die "Couldn't open less cmd : $!";
    print $fh `@toCall`;
    close($fh);
  }

  sub get_log{
    my $cno = -1;
    ($cno, $cname) = @_; 
    # error hundler
    if ($cno < 0 and 5 < $cno){ # NOTE: dokcer_compornent is not exist error
      say STDERR "error at line 141. get_log function";
      exit 
    } 
    # set toCall
    if ($timestamp){
      push (@toCall, "-t") if $timestamp;
    }
    push (@toCall, $cname);

    
    if($lookonly){
      say STDERR "   [INFO] @toCall | less ";
      look();
    }
    if($save){ 
      my $path = '';
      # set file_path
      $path = $paths[$cno] . ".log";
      
      say STDERR "   [INFO] @toCall > $path ";
      save($cno, $path);
=pod
      sysopen(my $fh, $file, O_WRONLY | O_CREAT) 
        or die "Couldn't open $file : $!";
      say STDERR "   [INFO] EXEC: @toCall > $file ";
      #my $echos = `@toCall`;
      # NOTE: ERROR HUNDLER > when `toCall` is missed
      print $fh `@toCall`;
      if (-z $fh){ 
       say STDERR "ERROR: toCall is missed!. exit";
      	close ($fh );
      	exit;
      }
      say STDERR "   [INFO] success. next cmd will be ready...";
      close( $fh );
=cut
    }
    pop(@toCall);
    return 1;
  }
}

sub get_compornent_name{
  my $cno;
  ($cno) = @_;
  my $cname;
  $cname = $project_name . "_sw360";

  if($cno == $FOSSOLOGY){
    say STDERR "  [ERROR] NOT_FURTURED!!  EXIT: get_fossology_cname(\$cno:$cno)";
    # get_fossology_cname
    exit;
  }
  if($cno != $SW360){
    $cname = $cname . $COMPORNENTS[$cno];
  }

  return "$cname";
  
}

# main -----------
sub main{ # exec ALL cmd, it is based on option.
  my $cname; # compornent_name # = $project_name . "_sw360";
  my $cno;   # compornent_no;
  
  say STDERR "------ [main] ------";
  foreach my $cno (@targets) {  
    $cname = get_compornent_name($cno);
    
    say STDERR " [COMORNENT]-$cname/[OPTION]-\@options";
    # say STDERR "    -ToCall     = @toCall";
    # say STDERR "    -FilePath   = $file";
    #print "yesorno()";
  
    if ($html){
      say STDERR "  ---[html]---";
      say STDERR "   exec:html_function()"; # modify_logine.pl. and generate_html.
      #html_modify_logfile();
    }
    if ($save || $lookonly){
      if ($save){
        say STDERR "  ---[save]---";
      }
      if ($lookonly){
        say STDERR "  ---[lookonly]---";
      }
      say STDERR "    exec:get_log(\$compornent=\"$cname\")"; # 
      get_log($cno, $cname);
    }
    say STDERR "   [INFO] CMD ok! \n";
  }
}


# main -----------
=pod
  foreach my $c_no (@targets) {  
  get_log($c_no);
  say STDERR "";
  }
=cut
main();
say STDERR "-----------  all ok!! ------------";


