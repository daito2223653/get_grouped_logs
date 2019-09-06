#!/usr/bin/env perl

#COMPORNENT_NO
my $SW360 = 0;
my $COUCHDB = 1;
my $FOSSOLOGY = 2;
my $POSTGRESQL = 3;
my $NGINX = 4;
my $CSV_SEARCH = 5;
my @COMPORNENTS = ("sw360", "couchdb", "fossology", "postgres", "nginx", "csv_search"); # $sw360 = catalina / liferay
my $projectName = "sw360_dev"; # NOTE: not furtured . get PROJECT NAME function from sw360chores's configuration.



my @cmd = ("docker", "logs");

sub main {
my @toCall; 
push(@toCall, @cmd);
my $target = $projectName . "_sw360";
my $c_no;
($c_no) = $ARGV[0];

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

say STDERR "  cno = $c_no [$COMPORNENTS[$c_no]] ---"; 
my $echos = `@toCall`;
return $echos;
 
    #my @toCall = "less";
    #push(@toCall, $echos);
    #0 == system(@toCall)
    # or die "failed...";
    # NOTE: ERROR HUNDLER > when `toCall` is missed
    #say STDERR "   [INFO] success. next cmd will be ready...";
}

main()
