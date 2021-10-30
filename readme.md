# README

## Introduction

Level-1B geolocation website for users of NASA/NOAA's remote sensing instruments MODIS, VIIRS, and GOES-R ABI and GLM. Our goal is to facilitate simple storage, delivery, and exploration of geolocation characterization results. 

This is a dummy version of the website. Not all of the code is here. The website is not yet public but some version will be someday. Thank you, beauracracy. 

## Setup

### 1. Set up Perl environment:

Make sure you are able to find the following Perl modules.

```
Chart::Gnuplot
Date::Calc
DateTime
List::Util
Mojo::Pg
Mojo::Pg::Database
Mojolicious::Lite
Mojo::Headers
Text::CSV
Time::JulianDay
Time::Piece
```

### 2. Fill the database:

If the database tables do not exist, run the SQL script

`psql < schema.sql`

Then run the following Perl scripts to fill the tables.

`gcstdb_perl/ingest_req.pl`

`gcstdb_perl/ingest_gcstdb.pl`

This should take no more than an hour.

You should see the following tables when you enter PostgreSQL.

```
gcstdb=> \dt
              List of relations
 Schema |      Name       | Type  |  Owner   
--------+-----------------+-------+----------
 public | g16_ccr_ew      | table | gcstdb
 public | g16_ccr_ns      | table | gcstdb
 public | g16_ffr_ew      | table | gcstdb
 public | g16_ffr_ns      | table | gcstdb
 public | g16_metricsfile | table | gcstdb
 public | g16_nav_ew      | table | gcstdb
 public | g16_nav_ns      | table | gcstdb
 public | g16_ssr_ew      | table | gcstdb
 public | g16_ssr_ns      | table | gcstdb
 public | g16_wifr        | table | gcstdb
 public | g17_ccr_ew      | table | gcstdb
 public | g17_ccr_ns      | table | gcstdb
 public | g17_ffr_ew      | table | gcstdb
 public | g17_ffr_ns      | table | gcstdb
 public | g17_metricsfile | table | gcstdb
 public | g17_nav_ew      | table | gcstdb
 public | g17_nav_ns      | table | gcstdb
 public | g17_ssr_ew      | table | gcstdb
 public | g17_ssr_ns      | table | gcstdb
 public | g17_wifr        | table | gcstdb
 public | req             | table | gcstdb
 ```

### 3. Start Morbo to host the dev website on your local machine:

`>>> morbo gcst.pl`

This will assign a port 3000. To stop Morbo, you need to Control+C in the running terminal. 

### 4. Start Hypnotoad to host the deployed website:

`>> hypnotoad gcst.pl`

This will assign a port, defaulting to 8080. It can be different, but for rest of document we will assume 8080. 

#### 4a. Tunnel the port: (via PuTTY)

In your PuTTY Configuration window, go to Connection->SSH->Tunnels and fill
in the following
Source port: 8080
Destination: modgoesr:8080

#### 4b. Tunnel the port: (via Unix)

Type the command, replacing NASAID with your id and MODBSTX with one of the bastion servers
ssh -L 8080:modgoesr:8080 NASAID@MODBSTX 

#### 4c. View the website:

In any web browser, go to localhost:8080/

#### 4d. Stop Hypnotoad:

`>> hypnotoad -s gcst.pl`

To test any changes you made to the code while in hypnotoad mode, you will need to stop and restart the hypnotaod session.

## Screenshots

Main Page:

Dashboard Form:

Dashboard:

Dashboard Plot:

GOES-R Publications:


