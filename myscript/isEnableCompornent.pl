#!/usr/bin/env perl

# COMPORNENT_NO
my $SW360 = 0;
my $COUCHDB = 1;
my $FOSSOLOGY = 2;
my $POSTGRESQL = 3;
my $NGINX = 4;
my $CSV_SEARCH = 5;

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



sub main{
if(yesno("    @_")){ 
	return 1;
  } else{
    return 0;
  }
}

main("$ARGV[0]")

