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
 # this script is to check setting of port / proxy and so on of sw360chore's Container.

 # how to use---
 # ./check_conpornentlog.pl [mode]
 # [option]
 #   --port : 
 #   --proxy: 
 #   --all: 
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

# read options
my $intaractive = '';
my $less = '';

# variables 
my $sw360 = ''; # $sw360 = catalina / liferay
my $couchdb = '';
my $fossology = '';
my $postgresql = '';
my $nginx      = '';
my $csv_search = '';
my $debug      = '';

# target
my @targets = (); # compornent no of sw360chores


{ # parse config and read command line arguments 

  my $configFile = "../configuration/configuration.pl";
  if(-e $configFile) {
    my $config=do($configFile);
    die "Error parsing $configFile: $@" if $@;
    die "Error reading $configFile: $!" unless defined $config;
    $projectName = $config->{'projectName'} // $projectName;
    #$cveSearch = $config->{'cveSearch'} // $cveSearch;
  } 

  my $targetFile = "./target.pl";

  if(-e $targetFile) {
    my $target=do($targetFile);
      die "Error parsing $targetFile: $@" if $@;
      die "Error reading $targetFile: $!" unless defined $target;
    
    # not still.
    $sw360 = $target->{'sw360'} // $sw360;
    $couchdb = $target->{'couchdb'} // $couchdb;
    $fossology = $target->{'fossology'} // $fossology;
    $postgresql = $target->{'postgresql'} // $postgresql;
    $nginx = $target->{'nginx'} // $nginx;
    $csv_search = $target->{'csv_search'} // $csv_search;
    $debug = $target->{'debug'} // $debug;
  }
    
  GetOptions (
    # handle imgaes
    'intaractive' => \$intaractive,
   
  ) or pod2usage();
}
$ENV{COMPOSE_PROJECT_NAME} = $projectName;

sub yesno{
    my $comment = shift;
    my $default = shift;
    if($default){
        $comment .= " > ";
    }else{
        $comment .= " > ";
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


if(1) {
  my $isYes;
  say STDERR "  variables: ";
  if(!yesno("    sw360")){ $sw360 = 0;  }
  if(!yesno("    couchdb")){ $couchdb = 0;  }
  if(!yesno("    fossology")){ $fossology = 0;  }
  if(!yesno("    postgresql")){ $postgresql = 0;  }
  if(!yesno("    nginx")){ $nginx = 0;  }
  if(!yesno("    csv_search")){ $csv_search = 0;  }
  say STDERR "    \$csv_search = $csv_search";
  say STDERR "    \$sw360      = $sw360";
  say STDERR "    \$couchdb    = $couchdb";
  say STDERR "    \$fossology  = $fossology";
  say STDERR "    \$postgresql = $postgresql";
  say STDERR "    \$nginx      = $nginx";
  say STDERR "    \$debug      = $debug";
  if ($sw360 == 1){ push(@targets, 0); } #NOTE: $COMPORNENtS[$SW360]); not furtured  }  # // $sw360;
  if ($couchdb == 1){ push(@targets, 1); } 
  if ($fossology == 1){ push(@targets, 2); } 
  if ($postgresql == 1){ push(@targets, 3); } 
  if ($nginx == 1){ push(@targets, 4); } 
  if ($csv_search == 1){ push(@targets, 5); };

}

my @cmd = ("docker", "logs");

sub get_log{
  my @toCall; 
  push(@toCall, @cmd);
  my $target = $projectName . "_sw360";
  my $c_no;
  ($c_no) = @_;

    # docker compornent is not exist error:
    # get_target_status < 0

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

    # set toCall
    #if ($timestamp){
    #push (@toCall, "-t") if $timestamp;
    #}
    push (@toCall, $target);
    # | less 
    # push (@toCall, ("|", "less"));

    say STDERR "  [$COMPORNENTS[$c_no]] ---"; 
    my $echos = `@toCall`;
    my @toCall = "less";
    push(@toCall, $echos);
    0 == system(@toCall)
      or die "failed...";
    # NOTE: ERROR HUNDLER > when `toCall` is missed
    say STDERR "   [INFO] success. next cmd will be ready...";
}

# main -----------
foreach my $c_no (@targets) {
  get_log($c_no);
  say STDERR "";
}


say STDERR "all ok!";
