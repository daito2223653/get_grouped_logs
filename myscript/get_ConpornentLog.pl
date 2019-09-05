#!/usr/bin/env perl

use Pod::Usage;

use strict;
use warnings;

# symbol
use Fcntl;


######################################################################################
 # written by daito 
 # this script is to get logs from sw360chore's Container.

 # how to use---
 # ./get_conpornentlog.pl [compornent] [targetFile]  [option]
 # [conpornent]
 #   sw360=liferay=tomcat
 #   couchdb
 #   fossology
 #   postgresql
 #   nginx
 #   inconfig : コンフィグファイルを読んで, 作成する. 
 # [option]
 #   -t : include timestamp
 #   -a : all compornent. when you use this option 
 #   -f : target ilfe. NOTE: default is compornentName_[no].log written path.pl
 #   -n : 
 #   --inconfig : コンフィグファイルを読んで, 作成する. 
 #   
 # evironmental variables---
 # $COMPORNENT
 #   is the compornent name of the chores containers
 # $TARGET
 #   is the target file name of the $COMPORNENT's log. Default is $COMPORNET_{no}.log
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


# read options
# variables 
my $sw360 = ''; # $sw360 = catalina / liferay
my $couchdb = '';
my $fossology = '';
my $postgresql = '';
my $nginx      = '';
my $csv_search = '';
my $debug      = '';
# log's path  
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
# PROJECT NAME
my $PROJECT_NAME = "sw360_dev"; # NOTE: not furtured . get PROJECT NAME function from sw360chores's configuration.

##########################################################
#
{ # parse config and read command line arguments
  my $targetFile = "./target.pl";
  # my $pathFile = "./path.pl";
  my $pathFile   = "./path.pl";

  if(-e $targetFile) {
    my $target=do($targetFile);
      die "Error parsing $targetFile: $@" if $@;
      die "Error reading $targetFile: $!" unless defined $target;

    # not still firture 
    $sw360 = $target->{'sw360'} // $sw360;
      if ($sw360 == 1){ push(@targets, 0); } #NOTE: $COMPORNENtS[$SW360]); not furtured  }  # // $sw360;
    $couchdb = $target->{'couchdb'} // $couchdb;
      if ($couchdb == 1){ push(@targets, 1); } 
    $fossology = $target->{'fossology'} // $fossology;
      if ($fossology == 1){ push(@targets, 2); } 
    $postgresql = $target->{'postgresql'} // $postgresql;
      if ($postgresql == 1){ push(@targets, 3); } 
    $nginx = $target->{'nginx'} // $nginx;
      if ($nginx == 1){ push(@targets, 4); } 
    $csv_search = $target->{'csv_search'} // $csv_search;
      if ($csv_search == 1){ push(@targets, 5); };
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
}
 
 
if($debug) {
  say STDERR "  variables (custum):";
  say STDERR "    \$sw360      = $sw360";
  say STDERR "    \$couchdb    = $couchdb";
  say STDERR "    \$fossology  = $fossology";
  say STDERR "    \$postgresql = $postgresql";
  say STDERR "    \$nginx      = $nginx";
  say STDERR "    \$csv_search = $csv_search";
  say STDERR "    \$debug      = $debug";

  # if default 
  #   say STDERR "  targetLog_path(default):
  # else 
  #   say STDERR "  target ~ (custum)
  say STDERR "  targetLog_path (default):";
  if ($sw360) { say STDERR "    \$sw360_path      = $sw360_path"; }
  say STDERR "    \$folder          = $logFolder";
  say STDERR "    \$couchdb_path    = $couchdb_path";
  say STDERR "    \$fossology_path  = $fossology_path";
  say STDERR "    \$postgresql_path = $postgresql_path";
  say STDERR "    \$nginx_path      = $nginx_path";
  say STDERR "    \$csv_search_path = $csv_search_path";
  say STDERR "";

  say STDERR "  [targets: @targets]"; # NOTE: change string is not still gurtured.
  say STDERR "";
}

{ # get log.
  my $cmd = ("docker");

  sub set_toCall{
    
  }
  sub set_path{
  
  }
  sub set_target{
  
  }

  sub get_log{
    my @toCall; 
    push(@toCall, $cmd);
    my $target = $PROJECT_NAME . "_sw360";
    my $file = '';
    my $c_no;
    ($c_no) = @_;

    # error hundler
    if ($c_no < 0 and 5 < $c_no){
      say STDERR "error at line 141. get_log function";
      exit 
      #NOTE: target is ok? not featured.
      #NOTE: path   is ok? not featured.
    }

    # set target
    if ($c_no != $SW360){
      $target = $target . $COMPORNENTS[$c_no];
    }

    # set file_path
    $file = $paths[$c_no] . ".log";

    # set toCall
    push (@toCall, "logs");
    push (@toCall, $target);

    say STDERR "  [$c_no(string is not futured)] ---"; 
    say STDERR "    -ToCall     = @toCall";
    say STDERR "    -FilePath   = $file";
    # NOTE: ファイルがないときに作成する / 出力先をファイルに #####
    
    # if (-ne $file) { say STDERR "    [INFO]  create file named $file"; }
    sysopen(my $fh, $file, O_WRONLY | O_CREAT) 
      or die "Couldn't open $file : $!";
      say STDERR "   [INFO] EXEC: @toCall > $file ";
      my $echos = `@toCall`;
      # NOTE: ERROR HUNDLER > when `toCall` is missed
      if (-z $fh){ 
        say STDERR "ERROR: toCall is missed!. exit";
	exit;
      }
      print $fh "$echos";
      say STDERR "   [INFO] success. next cmd will be ready...";
    close( $fh );
  }
}


# main -----------
foreach my $c_no (@targets) {
  get_log($c_no);
  say STDERR "";
}
say STDERR "all ok!";


