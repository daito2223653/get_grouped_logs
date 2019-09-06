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
 # written by daito 
 # this script is to check logs of sw360chore's Container.

 # how to use---
 # ./check_conpornentlog.pl [mode]
 # [option]
 #   --intaractive: intaractive mode.
 #   --less: use less cmd. 
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
my $projectName; # NOTE: not furtured . get PROJECT NAME function from sw360chores's configuration.

my $c_no;
($c_no) = $ARGV[0];


say STDERR "$c_no is target no";

{ # parse config and read command line arguments

  my $configFile = "../configuration/configuration.pl";
  if(-e $configFile) {
    my $config=do($configFile);
    die "Error parsing $configFile: $@" if $@;
    die "Error reading $configFile: $!" unless defined $config;
    $projectName = $config->{'projectName'} // $projectName;
    #$cveSearch = $config->{'cveSearch'} // $cveSearch;
  }
}

my $target;

sub check_stat{
  if ($c_no !~ /^[0-5]$/){
    return -1;
  }
  if ($c_no == $FOSSOLOGY || $c_no == $POSTGRESQL){
    say STDOUT "test : fossology and postgresql";
    return 0;
  }
  $target = $projectName . "_sw360";

  if ($c_no != $SW360){
    $target = $target . $COMPORNENTS[$c_no];
  }

  my $echos = `docker ps`; 
  say STDERR "$echos";
  if($echos =~ /$target/){
    say STDERR "test is ok";
  }
}

check_stat();


