#!/usr/bin/env perl

use Pod::Usage;

use strict;
use warnings;

# symbol
use Fcntl;

use Getopt::Long qw(GetOptions);
use Pod::Usage;

# use for time stamp
use Time::Piece;

use File::Copy;

# targetGroupNo and name.
my $group_no;
my $group_name;

# group_info-files and folder
my $group_folder;
my $info_file;


# NOTE: get COMPORNENTS config
my @COMPORNENTS = ("sw360", "couchdb", "fossology", "postgres", "nginx", "csv_search");

# targets in tareget's groups.
my @targets = ();
# greps
my $greps;

sub get_group_info{ # parse argument. argument is groupNo.
  my $group_no;
  ($group_no) = @_;
  $group_folder = "./html_script/html_logs/group$group_no/";
  $info_file    = "$group_folder" . "info.pl"; 

  if (-e $info_file){
    my $info = do($info_file);
      die "Error parsing $info_file: $@" if $@;
      die "Error reading $info_file: $!" unless defined $info;
    $group_name = $info -> {'groupName'}   // $group_name;
    $greps      = $info -> {'greps'}         // $greps;
    my @ts = $info -> {'targetNos'};
    @targets = @ts;
  }else{
    say STDERR "    [ERROR]  not exist $info_file";
    exit;
  }
  say STDERR "    read info file from: $info_file";
  return ($group_name, $greps, @targets);
}

#main($ARGV[0]);
