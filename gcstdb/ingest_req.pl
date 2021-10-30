#! /usr/local/bin/perl

use DateTime;
use DateTime::Format::Strptime qw( );
use Mojo::Pg;
use Mojo::Pg::Database;
use Text::CSV;
use Time::JulianDay;
use Time::Piece;

my $db_name = 'postgresql://postgres@/gcstdb';

# Enter database
my $pg = Mojo::Pg->new($db_name);
# Get a database handle from the cache for multiple queries
my $db = $pg->db;
my $dbh = $db->dbh;

sub ingest_req {
    #
    # Ingest the requirements table
    #

    my $file_path = '../data/requirements/g17.csv';

    my $today = DateTime->now;

    # Open data from CSV file
    my $csv = Text::CSV->new({ sep_char => ',' });
    open(my $data, '<', $file_path) or die "Could not open '$file' $!\n";

    # Initialze arrays
    my @nav;
    my @wifr;
    my @ffrlt2km;
    my @ffr2km;
    my @ssr;
    my @ccr_vnir_1km;
    my @ccr_vnir_2km;
    my @ccr_mwir_lwir;
    my @ccr_vnir_mwir_lwir;

    # Loop through lines in CSV
    while (my $line = <$data>) {
      chomp $line;
     
      if ($csv->parse($line)) {
     
          my @fields = $csv->fields();

          # Append elements in line to arrays
          push @nav, $fields[0];
          push @wifr, $fields[1];
          push @ffrlt2km, $fields[2];
          push @ffr2km, $fields[3];
          push @ssr, $fields[4];
          push @ccr_vnir_1km, $fields[5];
          push @ccr_vnir_2km, $fields[6];
          push @ccr_mwir_lwir, $fields[7];          
          push @ccr_vnir_mwir_lwir, $fields[8];    

      } else {
          warn "Line could not be parsed: $line\n";
      } # End if
     
    } # End while

    print "Finished reading the requirements file.\n";

    # Ingest the data into requirements table
    $db->insert('req', {
        nav=>$nav[1],
        wifr=>$wifr[1], 
        ffrlt2km=>$ffrlt2km[1],
        ffr2km=>$ffr2km[1],
        ssr=>$ssr[1],
        ccr_vnir_1km=>$ccr_vnir_1km[1],
        ccr_vnir_2km=>$ccr_vnir_2km[1],
        ccr_mwir_lwir=>$ccr_mwir_lwir[1],
        ccr_vnir_mwir_lwir=>$ccr_vnir_mwir_lwir[1],
        ingest_date=>$today
    });

    print "Finished ingesting the requirements table.\n";
}

ingest_req();
