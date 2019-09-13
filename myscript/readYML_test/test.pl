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
### maked by ./setup.pl --------------------------------------------- 
     "--" . @と_から後ろを取り除いたもの.  foreach opts.
### maked by ./setup.pl --------------------------------------------- 
 # evironmental variables---
 ## $COMPORNENT
    is the compornent name of the chores containers
 ## $TARGET
    is the target file name of the $COMPORNENT's log. Default is $COMPORNET_{no}.log
=cut

############################################# maked./setup.sh time_stamp ################################################
### Enviromentation 

############################################# maked./setup.sh time_stamp ################################################
# target
my @targets = (); # compornent no of sw360chores

##########################################################
{ # parse config and read command line arguments
  my $targetFile = "./default_target.pl";

  if(-e $targetFile) {
    my $target=do($targetFile);
      die "Error parsing $targetFile: $@" if $@;
      die "Error reading $targetFile: $!" unless defined $target;

    if(!$interactive) {
### maked by ./setup.pl --------------------------------------------- 
      #"\$" . "@COMPORNENTS[$i] = \$target->{\'@COMPORNENTS[$i]\'} \/\/ @COMPORNENTS[$i];"
      $sw360 = $target->{'sw360'} // $sw360;
      $couchdb = $target->{'couchdb'} // $couchdb;
      $fossology = $target->{'fossology'} // $fossology;
      $postgresql = $target->{'postgresql'} // $postgresql;
      $nginx = $target->{'nginx'} // $nginx;
      $csv_search = $target->{'csv_search'} // $csv_search;
### maked by ./setup.pl ---------------------------------------------
    }
    $debug = $target->{'debug'} // $debug;
  }

  if (-e $pathFile){
    my $path=do($pathFile);
      die "Error parsing $pathFile: $@" if $@;
      die "Error reading $pathFile: $!" unless defined $pathFile;  
       $logFolder  = $path->{'folder'} // $logFolder;
  }

  GetOptions (
    # handle imgaes
    'timestamp' => \$timestamp,
    'config' => \$config,
    'interactive' => \$interactive,
    'lookonly' => \$lookonly 
### maked by ./setup.pl --------------------------------------------- 
 #'@と_から後ろを取り除く' . "=> \~"
### maked by ./setup.pl --------------------------------------------- 
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
### maked by ./setup.pl --------------------------------------------- 
    #"if(!yesno(\"    @COMPORNENTS[$i]\")){ @COMPORNENTS[$i] = 0;  }else {@COMPORNENTS[$i] = 1;}"
    if(!yesno("    sw360")){ $sw360 = 0;  }else {$sw360 = 1;}
    if(!yesno("    couchdb")){ $couchdb = 0;  }else {$couchdb = 1;}
    if(!yesno("    fossology")){ $fossology = 0;  }else {$fossology = 1;}
    if(!yesno("    postgresql")){ $postgresql = 0;  }else {$postgresql = 1;}
    if(!yesno("    nginx")){ $nginx = 0;  }else {$nginx = 1;}
    if(!yesno("    csv_search")){ $csv_search = 0;  } else {$csv_search = 1;}
### maked by ./setup.pl --------------------------------------------- 
  }
### maked by ./setup.pl --------------------------------------------- 
  # "say STDERR \"    \$@COMPORNENTS[$i]      = \$@COMPORNENTS[$i]\";"
  # if (@COMPORNENTS[$i] == 1){ push(@targets, 0); } 
  say STDERR "    \$sw360      = $sw360";
  if ($sw360 == 1){ push(@targets, 0); } 
  say STDERR "    \$couchdb    = $couchdb";
  if ($couchdb == 1){ push(@targets, 1); } 
  say STDERR "    \$fossology  = $fossology";
  if ($fossology == 1){ push(@targets, 2); } 
  say STDERR "    \$postgresql = $postgresql";
  if ($postgresql == 1){ push(@targets, 3); } 
  say STDERR "    \$nginx      = $nginx";
  if ($nginx == 1){ push(@targets, 4); } 
  say STDERR "    \$csv_search = $csv_search";
  if ($csv_search == 1){ push(@targets, 5); };
### maked by ./setup.pl --------------------------------------------- 
  say STDERR "    \$debug      = $debug";
  # if default 
  #   say STDERR "  targetLog_path(default):
  # else 
  #   say STDERR "  target ~ (custum)
  say STDERR "  Log_path: ";
  say STDERR "    \$folder          = $logFolder";
  say STDERR ""; 

  my $isYes = yesno("are you ok ?");
  if(!$isYes){ exit }
}

{ # get log.
  #! my @cmd = @cmd[@USING[$cno]]
  #my @cmd = ("docker", "logs");
  

  sub set_toCall{
    
  }
  sub set_path{
  
  }
  sub set_target{
  
  }

  sub look_log{
  
  }

  sub get_log{
    my @toCall; 
    push(@toCall, @cmd);
    #! $target = @COMPORNENTS[$cno]
    #my $target = $project_name . "_sw360";
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
### maked by ./setup.pl --------------------------------------------- 
    # "if (\@options_str[$i]){"
    #if(@options[$i][$j] != ""){  for $j < typeSum
    # "  if (\@USING[\$cno] == \$$TYPE[$j]) { push (\@toCall, \"@options[$i][$j]\"); }" 
    #}
    # 
    if ($timestamp){
      if(@USING[$cno] == $json) {  }
    }
#    if ($timestamp){
#      push (@toCall, "-t") if $timestamp;
#    }
    push (@toCall, $target);
### maked by ./setup.pl --------------------------------------------- 
    say STDERR "  [$COMPORNENTS[$c_no]] ---"; 
    say STDERR "    -ToCall     = @toCall";
    say STDERR "    -FilePath   = $file";
    # NOTE: ファイルがないときに作成する / 出力先をファイルに #####
   


    if (!(-e $file)) { say STDERR "    [INFO]  create file named $file"; }
    
    if($lookonly){
      open(my $fh, "| less")
        or die "Couldn't open less cmd : $!";
      say STDERR "   [INFO] EXEC: @toCall | less ";
      print $fh `@toCall`;
    }
    else{
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
    }
  }
}


# main -----------
foreach my $c_no (@targets) {  
  get_log($c_no);
  say STDERR "";
}
say STDERR "all ok!";


