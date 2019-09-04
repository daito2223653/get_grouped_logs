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

# read options
my $COMPORNENT = '';
my $TARGET ='';
# variables 
my $sw360 = ''; # $sw360 = catalina / liferay
my $couchdb = '';
my $fossology = '';
my $postgresql = '';
my $nginx      = '';
my $debug      = '';
# log's path  
my $sw360_path = '';
my $couchdb_path = '';
my $fossology_path = '';
my $postgresql_path = '';
my $nginx_path      = '';


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

    $sw360 = $config->{'sw360'} // $sw360;
    $couchdb = $config->{'couchdb'} // $couchdb;
    $fossology = $config->{'fossology'} // $fossology;
    $postgresql = $config->{'postgresql'} // $postgresql;
    $nginx = $config->{'nginx'} // $nginx;
    $debug = $config->{'debug'} // $debug;
  }

  if (-e $targetLogFile){
    my $target=do($targetLogFile);
      die "Error parsing $targetLogFile: $@" if $@;
      die "Error reading $targetLogFile: $!" unless defined $targetLogFile;

    $sw360_path = $target->{'sw360'} // $sw360_;
    $couchdb_path = $target->{'couchdb'} // $couchdb;
    $fossology_path = $target->{'fossology'} // $fossology;
    $postgresql_path = $target->{'postgresql'} // $postgresql;
    $nginx_path = $target->{'nginx'} // $nginx;
    $debug_path = $target->{'debug'} // $debug;
  }
}
 
 
   if($debug) {
    say STDERR "  variables (custum):";
    say STDERR "    \$sw360      = $sw360";
    say STDERR "    \$couchdb    = $couchdb";
    say STDERR "    \$fossology  = $fossology";
    say STDERR "    \$postgresql = $postgresql";
    say STDERR "    \$nginx      = $nginx";
    say STDERR "    \$debug      = $debug";   
    # if default 
    #   say STDERR "  targetLog_path(default):
    # else 
    #   say STDERR "  target ~ (custum)
    say STDERR "  targetLog_path (default):";
    if ($sw360) { say STDERR "    \$sw360_path      = $sw360_path"; }
    say STDERR "    \$couchdb_path    = $couchdb_path";
    say STDERR "    \$fossology_path  = $fossology_path";
    say STDERR "    \$postgresql_path = $postgresql_path";
    say STDERR "    \$nginx_path      = $nginx_path";
  }



