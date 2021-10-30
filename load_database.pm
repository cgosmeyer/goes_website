package load_database;

use Mojo::Pg;
use Mojo::Pg::Database;

my $db_name = 'postgresql://postgres@/gcstdb';

sub proper_sat_name {
    ######
    # Return proper satellite name, e.g., GOES-16 from 'g16'
    ######
    my $sat = @_[0];
    my $satnum = substr $sat, 1, 2;
    return "GOES-" . $satnum;
}

sub query_ccr {
    ######
    # Query the CCR table
    ######
    $num_args = scalar(@_);
    my $dir = $_[0]; #direction
    my $sat = $_[1]; #satellite
    my $chan1 = $_[2];
    my $chan2 = $_[3];
    my $dt = $_[4]; #date in yyyy-mm-dd

    my $pg = Mojo::Pg->new($db_name);
    # Get a database handle from the cache for multiple queries
    my $db = $pg->db;
    my $dbh = $db->dbh;
    my $table = $sat . "_ccr_" . $dir;

    @results = $db->query("SELECT metric, mean, reqmet FROM $table WHERE chan1=$chan1 \
        and chan2=$chan2 and datetime='$dt'")->text; 
    print @results;

    my @Split = split(' ', $results[0]);

    if ($Split[0] == '') {
        $Split[0] = ' - ';
        $Split[1] = ' - ';
        $Split[3] = "grey";
    } 
    else {
        if ($Split[2] == '0') {
            $Split[3] = "green";
        }
        elsif ($Split[2] == '1') {
            $Split[3] = "red";
        }
    }

    print @Split;
    return @Split;
}

sub query_other {
    ######
    # Query other tables other than WIFR and CCR
    ######
    $num_args = scalar(@_);
    my $sat = $_[0]; #satellite
    my $inr = $_[1]; #INR metric
    my $dir = $_[2]; #direction
    my $chan = $_[3]; #channel
    my $dt = $_[4]; #date in yyyy-mm-dd

    my $pg = Mojo::Pg->new($db_name);
    # Get a database handle from the cache for multiple queries
    my $db = $pg->db;
    my $dbh = $db->dbh;
    my $table = $sat . "_" . $inr . "_" . $dir;

    @results = $db->query("SELECT metric, mean, reqmet FROM $table WHERE chan=$chan \
        and datetime='$dt'")->text; 
    my @Split = split(' ', $results[0]);

    if ($Split[0] == '') {
        $Split[0] = ' - ';
        $Split[1] = ' - ';
        $Split[3] = "grey";
    } 
    else {
        if ($Split[2] == '0') {
            $Split[3] = "green";
        }
        elsif ($Split[2] == '1') {
            $Split[3] = "red";
        }
    }
    return @Split;
}

sub query_req {
    ######
    # Query the requirements table
    ######

    my $pg = Mojo::Pg->new($db_name);
    # Get a database handle from the cache for multiple queries
    my $db = $pg->db;
    my $dbh = $db->dbh;

    @results = $db->query("SELECT ccr_vnir_1km, ccr_vnir_2km, ccr_mwir_lwir, \
        ccr_vnir_mwir_lwir, ffr2km, ffrlt2km, nav, ssr, wifr \
        FROM req")->text; 

    my @Split = split(' ', $results[0]);
    print @Split;
    return @Split;
}

sub query_wifr {
    ######
    # Query to WIFR table
    ######
    $num_args = scalar(@_);
    my $sat = $_[0]; #satellite
    my $inr = $_[1]; #INR metric
    my $chan = $_[2]; #channel
    my $dt = $_[3]; #date in yyyy-mm-dd

    my $pg = Mojo::Pg->new($db_name);
    # Get a database handle from the cache for multiple queries
    my $db = $pg->db;
    my $dbh = $db->dbh;
    my $table = $sat . "_" . $inr;

    @results = $db->query("SELECT metric, mean, reqmet FROM $table WHERE chan=$chan \
        and datetime='$dt'")->text; 

    my @Split = split(' ', $results[0]);

    if ($Split[0] == '') {
        $Split[0] = ' - ';
        $Split[1] = ' - ';
        $Split[3] = "grey";
    } 
    else {
        if ($Split[2] == '0') {
            $Split[3] = "green";
        }
        elsif ($Split[2] == '1') {
            $Split[3] = "red";
        }
    }
    return @Split;
}

sub return_today {
    ######
    # Query to WIFR table
    ######
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
    printf("%02d-%02d-%02d", $year+1900, $mday, $mon+1);
    return sprintf("%02d-%02d-%02d", $year+1900, $mon+1, $mday);
}

sub query_ccr_longterm {
    ######
    # Query the CCR table for the long-term trend plotting
    ######
    $num_args = scalar(@_);
    my $dir = $_[0]; #direction
    my $sat = $_[1]; #satellite
    my $chan1 = $_[2];
    my $chan2 = $_[3];
    my $dt_start = $_[4]; #date in yyyy-mm-dd
    my $dt_end = $_[5]; #date in yyyy-mm-dd

    my $pg = Mojo::Pg->new($db_name);
    # Get a database handle from the cache for multiple queries
    my $db = $pg->db;
    my $dbh = $db->dbh;
    my $table = $sat . "_ccr_" . $dir;

    @results = $db->query("SELECT mean, threesig, datetime FROM $table WHERE chan1=$chan1 \
        and chan2=$chan2 and datetime>'$dt_start' and datetime<='$dt_end'")->text; 
    print @results;

    my @Split = split(' ', $results[0]);

    print @Split;
    return @Split;
}

sub query_other_longterm {
    ######
    # Query other tables other than WIFR and CCR for long-term trend plotting
    ######
    $num_args = scalar(@_);
    my $sat = $_[0]; #satellite
    my $inr = $_[1]; #INR metric
    my $dir = $_[2]; #direction
    my $chan = $_[3]; #channel
    my $dt_start = $_[4]; #date in yyyy-mm-dd
    my $dt_end = $_[5]; #date in yyyy-mm-dd

    my $pg = Mojo::Pg->new($db_name);
    # Get a database handle from the cache for multiple queries
    my $db = $pg->db;
    my $dbh = $db->dbh;
    my $table = $sat . "_" . $inr . "_" . $dir;

    @results = $db->query("SELECT mean, threesig, datetime FROM $table WHERE chan=$chan \
        and datetime>'$dt_start' and datetime<='$dt_end'")->text; 
    print @results;

    my @Split = split(' ', $results[0]);

    print @Split;
    return @Split;
}

sub return_int {
    ######
    # Return the integer as a string with prepended 0 if needed
    ######
    my $dt = $_[0];

    my @dt_split = split('', $dt);
    if ($dt_split[0] eq '0') {
      return $dt_split[1];
    }
    else {
      return $dt;
    }
}

return 1;
