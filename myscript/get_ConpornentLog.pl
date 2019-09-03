#!/usr/bin/env perl

use Pod::Usage;

######################################################################################
 # written by daito 
 # this script is to get logs from sw360chore's Container.

 # how to use---
 # ./get_conpornentlog.pl [-c compornent] [-f targetFile]  [option]
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
 #   
 # evironmental variables---
 # $COMPORNENT
 #   is the compornent name of the chores containers
 # $TARGET
 #   is the target file name of the $COMPORNENT's log. Default is $COMPORNET_{no}.log
######################################################################################


# read options
my $COMPORNENT = '';
my $TARGET ='';

my $sw360 = '';
my $couchdb = '';
my $fossology = '';
my $postgresql = '';


# error hundler
if(-ne $configFile) {
  echo "configFIle is not exist"
  # exit
}


{ # parse config and read command line arguments
  my $configFile = "./configuration.pl";
  my $pathFile = "./path.pl";
  # my $targetFile = "./target.pl";

  my $config=do($configFile);
    die "Error parsing $configFile: $@" if $@;
    die "Error reading $configFile: $!" unless defined $config;
        
  GetOptions (
    # handle imgaes 
    

