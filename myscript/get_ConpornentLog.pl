#!/usr/bin/env perl

use Pod::Usage;

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
my @COMPORNENTS = ("sw360", "couchdb", "fossology", "postgresql", "nginx", "csv_search"); # $sw360 = catalina / liferay


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
  my $configFile = "./configuration.pl";
  # my $pathFile = "./path.pl";
  my $targetLogFile = "./target.pl";

  if(-e $configFile) {
    my $config=do($configFile);
      die "Error parsing $configFile: $@" if $@;
      die "Error reading $configFile: $!" unless defined $config;

    # not still firture 
    $sw360 = $config->{'sw360'} // $sw360;
      if ($sw360 == 1){ push(@targets, 0); } #NOTE: $COMPORNENtS[$SW360]); not furtured  }  # // $sw360;
    $couchdb = $config->{'couchdb'} // $couchdb;
      if ($couchdb == 1){ push(@targets, 1); } 
    $fossology = $config->{'fossology'} // $fossology;
      if ($fossology == 1){ push(@targets, 2); } 
    $postgresql = $config->{'postgresql'} // $postgresql;
      if ($postgresql == 1){ push(@targets, 3); } 
    $nginx = $config->{'nginx'} // $nginx;
      if ($nginx == 1){ push(@targets, 4); } 
    $csv_search = $config->{'csv_search'} // $csv_search;
      if ($csv_search == 1){ push(@targets, 5); };
    $debug = $config->{'debug'} // $debug;
  }

  if (-e $targetLogFile){
    my $target=do($targetLogFile);
      die "Error parsing $targetLogFile: $@" if $@;
      die "Error reading $targetLogFile: $!" unless defined $targetLogFile;

    $logFolder  = $target->{'folder'} // $folder;
    $sw360_path = $target->{'sw360'} // $sw360_;
    $couchdb_path = $target->{'couchdb'} // $couchdb;
    $fossology_path = $target->{'fossology'} // $fossology;
    $postgresql_path = $target->{'postgresql'} // $postgresql;
    $nginx_path = $target->{'nginx'} // $nginx;
    $csv_search_path = $target->{'csv_search'} // $csv_search;
  
    push(@paths, $sw360_path);
    push(@paths, $couchdb_path);
    push(@paths, $fossology_path);
    push(@paths, $postgresql_path);
    push(@paths, $nginx_path);
    push(@paths, $csv_search_path);
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
}

{ # get log.
  my $cmd = ("docker");

  sub generate_toCall{
    
  }

  sub get_log{
    my @toCall; 
    push(@toCall, $cmd);
    my $target = $PROJECT_NAME . "_sw360";
    my $path = '';
    my $no;
    ($no) = @_;

    # error hundler
    if ($no < 0 and 5 < $no){
      say STDERR "error at line 141. get_log function";
      exit 
      #NOTE: target is ok? not featured.
      #NOTE: path   is ok? not featured.
    }

    # set target
    if ($no != $SW360){
      $target = $target . $COMPORNENTS[$no];
    }

    # set path
    $path = $logFolder . "/" . $paths[$no] . ".log";

    # set toCall
    push (@toCall, "logs");
    push (@toCall, $target);
    ##push (@toCall, ">");
    ##push (@toCall, $path);

    say STDERR "  $no(string is not futured)"; 
    say STDERR "    -toCall = @toCall";
    say STDERR "    -path   = $paths[$no]";
    # NOTE: ファイルがないときに作成する / 出力先をファイルに #####
    0 == system(@toCall)  #"docker logs sw360_dev_sw360")#@toCall)
      or die "failed...";
  }
}


# main -----------
foreach my $no (@targets) {
  get_log($no);
}

