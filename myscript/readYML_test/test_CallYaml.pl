#!/usr/bin/env perl

use Pod::Usage;

use strict;
use warnings;

# symbol
use Fcntl;

use Getopt::Long qw(GetOptions);
use Pod::Usage;

use feature qw(say);

use YAML ();
use Data::Dumper ();

my $interactive;
my $update;

my $log_folder;

{ # parse config and read command line arguments

  GetOptions (
    # handle imgaes
    'interactive' => \$interactive,
    'update=i' => \$update,
  ) or pod2usage();

=pod
  sub grep_interactive(){
    foreach my $cno (@targets){
      say STDERR("    $COMPORNENTS[$cno]: ");
      say STDERR("    It is not still. EXIT!! ");
      # exit;      
    }  
  }

  sub get_grep_patturn{ # get grep-patturns, it is gived as this-> ./main.pl error warn network connect GET
    # --interactive : you can type grep_patturns each compornents. when greps gived as cmd_argument, all compornents target.
    my $grep = "";
    #if ($interactive){
      #say STDERR "greps interactive mode start [not still!!] ---";
      #$grep = grep_interactive();
      #exit;
      #}
    #else{     
    foreach my $arg (@ARGV){
  	  $grep = $grep . "$arg ";
    }
    push(@greps, $grep);
    #}
  }

=cut

  if(!$interactive) {
=pod
    $sw360 = $target->{'sw360'} // $sw360;
    $couchdb = $target->{'couchdb'} // $couchdb;
    $fossology = $target->{'fossology'} // $fossology;
    $postgresql = $target->{'postgresql'} // $postgresql;
    $nginx = $target->{'nginx'} // $nginx;
    $cvs_search = $target->{'cvs_search'} // $cvs_search;
=cut
  }
  $log_folder  ="logs/";

}



my @logStr = `get_log.pl sw360_dev_sw360 --setup`;

print "@logStr";
