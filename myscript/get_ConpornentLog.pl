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
    'lookonly' => \$lookonly 
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

{ # get log.
  my @cmd = ("docker", "logs");

  sub set_toCall{
    
  }
  sub set_path{
  
  }
  sub set_target{
  
  }

  sub get_target_status{
    my @cmd = ("docker", "stats");
    my $target = $project_name . "_sw360";
    my $c_no;
    ($c_no) = @_;
    my @_toCall;
  }

  sub get_log{
    my @toCall; 
    push(@toCall, @cmd);
    my $target = $project_name . "_sw360";
    my $file = '';
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

    # set file_path
    $file = $paths[$c_no] . ".log";

    # set toCall
    if ($timestamp){
      push (@toCall, "-t") if $timestamp;
    }
    push (@toCall, $target);

    say STDERR "  [$COMPORNENTS[$c_no]] ---"; 
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
	close ($fh );
	exit;
      }
      print $fh "$echos";
      say STDERR "   [INFO] success. next cmd will be ready...";
    close( $fh );
  }
}


# main -----------
foreach my $c_no (@targets) {
  if($lookonly){
    say STDERR "lookonly option is not still." 
  }
  else{
    get_log($c_no);
  }
  say STDERR "";
}
say STDERR "all ok!";


