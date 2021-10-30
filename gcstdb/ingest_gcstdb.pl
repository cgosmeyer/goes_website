#! /usr/local/bin/perl

#use Chart::Gnuplot;
use DateTime;
use DateTime::Format::Strptime qw( );
use Mojo::Pg;
use Mojo::Pg::Database;
use Text::CSV;
use Time::JulianDay;
use Time::Piece;

my $path_to_data = '';
my $db_name = 'postgresql://postgres@/gcstdb';

# Enter database
my $pg = Mojo::Pg->new($db_name);
# Get a database handle from the cache for multiple queries
my $db = $pg->db;
my $dbh = $db->dbh;    

# Read in requirements array
my @req_raw = $db->query("SELECT ccr_vnir_1km, ccr_vnir_2km, ccr_mwir_lwir, ccr_vnir_mwir_lwir, ffr2km, ffrlt2km, nav, ssr, wifr FROM req")->text;
my @req = split(' ', $req_raw[0]);


sub find_data {
    #
    # Search for metrics files.
    #
    my $mission = @_[0];
    my $inr = @_[1];
    my $start = @_[2]; #%Y-%m-%dT%H:%M:%S

    my $inr_temp;
    if ($inr eq 'ccr') {
        $inr_temp = 'bbr';
    } else {
        $inr_temp = $inr;
    }

    # End search at current datetime
    my $end = DateTime->now;

    my $format = '%Y-%m-%dT%H:%M:%S';

    # Convert start and end datetime strings to datetime objects that can be manipulated
    my $start_datetime = Time::Piece->strptime($start, $format);
    my $start_year = Time::Piece->strptime($start_datetime->year, '%Y');
    my $start_doy = 1 + POSIX::floor(($start_datetime - $start_year) / 86400.0);
    print "start day of year: $start_doy\n";
    my ($start_month, $start_day, $start_year) = ($start_datetime->month, $start_datetime->day, $start_datetime->year);
    print "start year: $start_year\n";

    my $end_datetime = Time::Piece->strptime($end, $format);
    my $end_year = Time::Piece->strptime($end_datetime->year, '%Y');
    my $end_doy = 1 + POSIX::floor(($end_datetime - $end_year) / 86400.0);
    print "end day of year: $end_doy\n";
    my ($end_month, $end_day, $end_year) = ($end_datetime->month, $end_datetime->day, $end_datetime->year);
    print "end year: $end_year\n";

    # Calculate start and end DOYs for each year 
    my @start_doys;
    my @end_doys;
    for ($year=$start_year; $year<=$end_year; $year=$year+1) {
        if ($year == $start_year) {
           push @start_doys, $start_doy;
        } else {
           push @start_doys, 0;
        }
        if ($year == $end_year) {
           push @end_doys, $end_doy;
        } else {
           push @end_doys, 366;
        } 
    } 

    # Get list of metrics files that match year, day of year, and INR metric
    my @mission_num = split("g", $mission);
    my $search_str;
    my @search_files;
    my $year;
    my $doy;
    my $count = 0;
    for ($year=$start_year; $year<=$end_year; $year=$year+1) {
        for ($doy=$start_doys[$count]; $doy<=$end_doys[$count]; $doy=$doy+1) {
            if (length($doy) == 1) {
                $doy = '00' . $doy;
            }
            if (length($doy) == 2) {
                $doy = '0' . $doy;
            }
            $search_str = $path_to_data . 'INR_result_' . $mission_num[-1] . '/' . uc($inr_temp) . '/' . uc($mission) . '_' . uc($inr_temp) . '_metrics_' . $year . '_' . $doy . '*csv';   
            print "$search_str\n";
            @search_file = glob($search_str);
            print "$search_file[0]\n";
            if ($search_file[0] ne '') {
                push @search_files, $search_file[0];
            } # End if
        } # End for
        $count = $count + 1;
    } # End for

    return @search_files;
}

sub ingest_data {
    #
    # Wrapper to ingest data into all tables for given INR metric
    #

    my $mission = @_[0];
    my $inr = @_[1];
    my $start = @_[2];

    my @search_files = find_data($mission, $inr, $start);

    print "\n";
    print "mission: $mission\n";
    print "inr: $inr\n";

    # Generate the table names
    my $metricsfile_tab = $mission . '_metricsfile';

    # Retrieve today's date for ingest_date column
    my $today = DateTime->now;

    # Initialize for loop variables
    my @filename_split;
    my $filename;

    # Loop through each metrics file, check whether already in db, and ingest if not
    foreach $search_file (@search_files) {
        if ($search_file ne '') {
            @path_split = split("/", $search_file);
            $filename = $path_split[-1];

            # Check that file not already in metricsfile table
            @results = $db->query("SELECT id FROM $metricsfile_tab WHERE filename='$filename'")->text; 
            $id = $results[0];

            # If the file is not in the database, read the file and ingest it.
            if ($results[0] == '') {
                print "File " . $filename . " not found in database! Ingesting...\n";

                # Parse the filename and convert doy/year to YYYY-MM-DD
                @filename_split = split('_', $filename);
                @doy_split = split('\.', $filename_split[-1]);

                my $date_str = doy2date($doy_split[0], $filename_split[3]);
                my $date = Time::Piece->strptime($date_str, '%Y-%m-%d');

                # First ingest metricsfile table
                $db->insert($metricsfile_tab, {date=>$date, filename=>$filename, ingest_date=>$today});

                # Next ingest the ew and ns tables
                if (lc($inr) eq 'ccr') {
                    print "Ingesting ccr table...\n";
                    ingest_ccr($search_file, $filename, $mission, $inr);
                }
                elsif ((lc($inr) eq 'wifr')) {
                    print "Ingesting wifr table...\n";
                    ingest_wifr($search_file, $filename, $mission, $inr);
                } 
                else {
                    print "Ingesting $inr table...\n";
                    ingest_other($search_file, $filename, $mission, $inr);
                } #  End if

                # If any other table
            } else {
                print "File " . $filename . " already exists in database.\n"
            } # End if
        } # End if
    } # End foreach

    # Report on status
}


sub ingest_ccr {
    #
    # Read CCR metrics file and ingest into CCR tables
    #
    my $file_path = @_[0];
    my $filename = @_[1];
    my $mission = @_[2];
    my $inr = @_[3];

    my $inr_tab_ew = $mission . '_' . $inr . '_ew';
    my $inr_tab_ns = $mission . '_' . $inr . '_ns';

    my $today = DateTime->now;

    # Open data from CSV file
    my $csv = Text::CSV->new({ sep_char => ',' });
    open(my $data, '<', $file_path) or die "Could not open '$filename' $!\n";

    # Initialze arrays
    my @filename;
    my @chan1;
    my @chan2;
    my @datetime;
    my @nsamples;
    my @mean_ew;
    my @threesig_ew;
    my @min_ew;
    my @max_ew;
    my @metric_ew;
    my @mean_ns;
    my @threesig_ns;
    my @min_ns;
    my @max_ns;
    my @metric_ns;
    my @fsamples;
    my @reqmet_ew;
    my @reqmet_ns;
    my @ingest_date;

    # Loop through lines in CSV
    while (my $line = <$data>) {
      chomp $line;
     
      if ($csv->parse($line)) {
     
          my @fields = $csv->fields();

          # Append elements in line to arrays
          push @chan1, $fields[2];
          push @chan2, $fields[3];
          push @datetime, $fields[4];
          push @nsamples, $fields[5];
          push @mean_ew, $fields[6];
          push @threesig_ew, $fields[7];
          push @min_ew, $fields[8];
          push @max_ew, $fields[9];
          push @metric_ew, $fields[10];          
          push @mean_ns, $fields[11];
          push @threesig_ns, $fields[12];
          push @min_ns, $fields[13];
          push @max_ns, $fields[14];
          push @metric_ns, $fields[15];
          push @fsamples, $fields[22];
          push @reqmet_ew, req_passfail($fields[10], $inr, $fields[2], $fields[3]);
          push @reqmet_ns, req_passfail($fields[15], $inr, $fields[2], $fields[3]);    

      } else {
          warn "Line could not be parsed: $line\n";
      } # End if
     
    } # End while

    # Count number of rows
    my $nrows = @chan1;

    # Insert each row into EW table
    for ($i=1; $i<$nrows; $i=$i+1) {
        eval {
            $db->insert($inr_tab_ew, {
                filename=>$filename, 
                chan1=>$chan1[$i], 
                chan2=>$chan2[$i],
                datetime=>Time::Piece->strptime($datetime[$i], '%Y-%m-%d %H.%M.%S'),
                nsamples=>$nsamples[$i],
                mean=>$mean_ew[$i],
                threesig=>$threesig_ew[$i],
                min=>$min_ew[$i],
                max=>$max_ew[$i],
                metric=>$metric_ew[$i],
                fsamples=>$fsamples[$i],
                reqmet=>$reqmet_ew[$i],
                ingest_date=>$today
            });
        } or do {
            my $error = $@ || 'Unknown failure';
            warn "Could not ingest line '$i' in file $filename - $error";
            print FH $filename; 
        };    
    } # End for

    # Insert each row into NS table
    for ($i=1; $i<$nrows; $i=$i+1) {
        eval {
            $db->insert($inr_tab_ns, {
                filename=>$filename, 
                chan1=>$chan1[$i], 
                chan2=>$chan2[$i],
                datetime=>Time::Piece->strptime($datetime[$i], '%Y-%m-%d %H.%M.%S'),
                nsamples=>$nsamples[$i],
                mean=>$mean_ns[$i],
                threesig=>$threesig_ns[$i],
                min=>$min_ns[$i],
                max=>$max_ns[$i],
                metric=>$metric_ns[$i],
                fsamples=>$fsamples[$i],
                reqmet=>$reqmet_ns[$i],
                ingest_date=>$today
            });
        } or do {
            my $error = $@ || 'Unknown failure';
            warn "Could not ingest line '$i' in file $filename - $error";
            print FH $filename; 
        };    
    } # End for
}


sub ingest_other {
    #
    # Read other (ffr,nav,ssr) metrics file and ingest into other tables
    #
    my $file_path = @_[0];
    my $filename = @_[1];
    my $mission = @_[2];
    my $inr = @_[3];

    my $inr_tab_ew = $mission . '_' . $inr . '_ew';
    my $inr_tab_ns = $mission . '_' . $inr . '_ns';

    my $today = DateTime->now;

    # Open data from CSV file
    my $csv = Text::CSV->new({ sep_char => ',' });
    open(my $data, '<', $file_path) or die "Could not open '$file' $!\n";

    # Initialze arrays
    my @filename;
    my @chan;
    my @datetime;
    my @nsamples;
    my @mean_ew;
    my @threesig_ew;
    my @min_ew;
    my @max_ew;
    my @metric_ew;
    my @mean_ns;
    my @threesig_ns;
    my @min_ns;
    my @max_ns;
    my @metric_ns;
    my @fsamples;
    my @reqmet_ew;
    my @reqmet_ns;
    my @ingest_date;

    # Loop through lines in CSV
    while (my $line = <$data>) {
      chomp $line;
     
      if ($csv->parse($line)) {
     
          my @fields = $csv->fields();

          # Append elements in line to arrays
          push @chan, $fields[2];
          push @datetime, $fields[3];
          push @nsamples, $fields[4];
          push @mean_ew, $fields[5];
          push @threesig_ew, $fields[6];
          push @min_ew, $fields[7];
          push @max_ew, $fields[8];
          push @metric_ew, $fields[9];          
          push @mean_ns, $fields[10];
          push @threesig_ns, $fields[11];
          push @min_ns, $fields[12];
          push @max_ns, $fields[13];
          push @metric_ns, $fields[14];
          push @fsamples, $fields[21];
          push @reqmet_ew, req_passfail($fields[9], $inr, $fields[2]);
          push @reqmet_ns, req_passfail($fields[14], $inr, $fields[2]); 

      } else {
          warn "Line could not be parsed: $line\n";
      } # End if
     
    } # End while

    # Count number of rows
    my $nrows = @chan;

    # Insert each row into EW table
    for ($i=1; $i<$nrows; $i=$i+1) {
        eval {
            $db->insert($inr_tab_ew, {
                filename=>$filename, 
                chan=>$chan[$i], 
                datetime=>Time::Piece->strptime($datetime[$i], '%Y-%m-%d %H.%M.%S'),
                nsamples=>$nsamples[$i],
                mean=>$mean_ew[$i],
                threesig=>$threesig_ew[$i],
                min=>$min_ew[$i],
                max=>$max_ew[$i],
                metric=>$metric_ew[$i],
                fsamples=>$fsamples[$i],
                reqmet=>$reqmet_ew[$i],
                ingest_date=>$today
            });
        } or do {
            my $error = $@ || 'Unknown failure';
            warn "Could not ingest line '$i' in file $filename - $error";
            print FH $filename;
        };    
    } # End for

    # Insert each row into NS table
    for ($i=1; $i<$nrows; $i=$i+1) {
        eval {
            $db->insert($inr_tab_ns, {
                filename=>$filename, 
                chan=>$chan[$i], 
                datetime=>Time::Piece->strptime($datetime[$i], '%Y-%m-%d %H.%M.%S'),
                nsamples=>$nsamples[$i],
                mean=>$mean_ns[$i],
                threesig=>$threesig_ns[$i],
                min=>$min_ns[$i],
                max=>$max_ns[$i],
                metric=>$metric_ns[$i],
                fsamples=>$fsamples[$i],
                reqmet=>$reqmet_ns[$i],
                ingest_date=>$today
            });
        } or do {
            my $error = $@ || 'Unknown failure';
            warn "Could not ingest line '$i' in file $filename - $error";
            print FH $filename;
        };
    } # End for
}


sub ingest_wifr {
    #
    # Read WIFR metrics file and ingest into WIFR table
    #
    my $file_path = @_[0];
    my $filename = @_[1];
    my $mission = @_[2];
    my $inr = @_[3];

    my $inr_tab = $mission . '_' . $inr;

    my $today = DateTime->now;

    # Open data from CSV file
    my $csv = Text::CSV->new({ sep_char => ',' });
    open(my $data, '<', $file_path) or die "Could not open '$file' $!\n";

    # Initialze arrays
    my @filename;
    my @chan;
    my @datetime;
    my @nsamples;
    my @mean;
    my @threesig;
    my @min;
    my @max;
    my @metric;
    my @reqmet;
    my @ingest_date;

    # Loop through lines in CSV
    while (my $line = <$data>) {
      chomp $line;
     
      if ($csv->parse($line)) {
     
          my @fields = $csv->fields();

          # Append elements in line to arrays
          push @chan, $fields[2];
          push @datetime, $fields[3];
          push @nsamples, $fields[4];
          push @mean, $fields[5];
          push @threesig, $fields[6];
          push @min, $fields[7];
          push @max, $fields[8];
          push @metric, $fields[9];          
          push @reqmet, req_passfail($fields[9], $inr, $fields[2]); 

      } else {
          warn "Line could not be parsed: $line\n";
      } # End if
     
    } # End while

    # Count number of rows
    my $nrows = @chan;

    # Insert each row into EW table
    for ($i=1; $i<$nrows; $i=$i+1) {
        eval {
            $db->insert($inr_tab, {
                filename=>$filename, 
                chan=>$chan[$i], 
                datetime=>Time::Piece->strptime($datetime[$i], '%Y-%m-%d %H.%M.%S'),
                nsamples=>$nsamples[$i],
                mean=>$mean[$i],
                threesig=>$threesig[$i],
                min=>$min[$i],
                max=>$max[$i],
                metric=>$metric[$i],
                reqmet=>$reqmet[$i],
                ingest_date=>$today
            });
        } or do {
            my $error = $@ || 'Unknown failure';
            warn "Could not ingest line '$i' in file $filename - $error";
            print FH $filename;
        };    
    } # End for
}


sub doy2date {
    #
    # Convert day of year to date YYYY-MM-DD
    #
    my $doy = @_[0];
    my $year = @_[1];

    my $julian = julian_day($year, 1, 1) + $doy - 1;
    my @date = (inverse_julian_day($julian))[0, 1, 2]; 
    my $month = $date[1];
    my $day = $date[2];

    if (length($month) == 1) {
        $month = '0' . $month;
    }

    if (length($day) == 1) {
        $day = '0' . $day;
    }

    return $year . '-' . $month . '-' . $day;
}


sub req_passfail {
    #
    # Determine first whether the channels count as either 
    #    lt2km/gt2m or VNIR/LWIR/MWIR. Then, select the appropriate requirement 
    #    to compare the metric (abs mean * 3sigma) to. Finally return whether 
    #    under requirement (0/pass) or over requirement (1/fail).
    #
    my $metric = @_[0];
    my $inr = @_[1];
    my $chan1 = @_[2];
    my $chan2 = @_[3];

    # Initialize as pass (0)
    my $passfail = 0;

    if ($inr eq 'nav') {
        if ($metric >= $req[6]) {
            $passfail = 1;
        }
    }

    elsif ($inr eq 'ssr') {
        if ($metric >= $req[7]) {
            $passfail = 1;
        }
    }

    elsif ($inr eq 'wifr') {
        if ($metric >= $req[8]) {
            $passfail = 1;
        }
    }

    elsif ($inr eq 'ffr') {
        my @chanslt2km = [1,2,3,5];
        my @chansgt2km = [4,6,7,8,9,10,11,12,13,14,15,16];        
        # For channels with less than 2 km resolution
        if ($chan1 ~~ @chanslt2km and $metric >= $req[5]) {
            $passfail = 1;
        }
        # For all other channels with 2 km resolution
        elsif ($chan1 ~~ @chansgt2km and $metric >= $req[4]) {
            $passfail = 1;
        }
    }

    elsif ($inr eq 'ccr') {
        my @chans1km = [1,2,3,5];
        my @chans2km = [1,2,3,4,5,6];
        my @chans46 = [4,6];
        my @chansmwir = [7,8,9,10,11,12,13,14,15,16];
        # For channels within VNIR 1km (chan1 or chan2 = 1-3 & 5 so long
        # as other channel also 1-3 or 5).
        if ($chan1 ~~ @chans1km and $chan2 ~~ @chans1km and $metric >= $req[0]) {
            $passfail = 1;
        }

        # For channels within VNIR 2km (chan1 or chan2 = 4 or 6 as long as
        # other channel less than 6).
        if ($chan1 ~~ @chans46 and $chan2 ~~ @chans2km and $metric >= $req[1]) {
            $passfail = 1;
        }

        # For channels within MWIR/LWIR (chan1 or chan2 = 7-16 as long as
        # other channel also 7-16).
        if ($chan1 ~~ @chansmwir and $chan2 ~~ @chansmwir and $metric >= $req[2]) {
            $passfail = 1;
        }

        # For channels VNIR - MWIR/LWIR (chan1 = 1-6 and chan2 = 7-16).
        if ($chan1 ~~ @chansmwir and $chan2 ~~ @chans2km and $metric >= $req[3]) {
            $passfail = 1;
        }
    }

    return $passfail;
}

#
# Main control
#

my @missions = ('g16', 'g17');
my @inrs = ('ccr', 'ffr', 'nav', 'ssr', 'wifr');

my $start;

foreach my $mission (@missions) {
   if ($mission eq 'g16') {
        $start = '2016-11-19';
   } elsif ($mission eq 'g17') {
        $start = '2018-03-01';
   }

   foreach my $inr (@inrs) {
      ingest_data($mission, $inr, $start);
   }
}

