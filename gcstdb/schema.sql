DROP TABLE g16_metricsfile, g17_metricsfile CASCADE;
DROP TABLE g16_ccr_ew, g17_ccr_ew CASCADE;
DROP TABLE g16_ccr_ns, g17_ccr_ns CASCADE;
DROP TABLE g16_ffr_ew, g17_ffr_ew CASCADE;
DROP TABLE g16_ffr_ns, g17_ffr_ns CASCADE;
DROP TABLE g16_nav_ew, g17_nav_ew CASCADE;
DROP TABLE g16_nav_ns, g17_nav_ns CASCADE;
DROP TABLE g16_ssr_ew, g17_ssr_ew CASCADE;
DROP TABLE g16_ssr_ns, g17_ssr_ns CASCADE;
DROP TABLE g16_wifr, g17_wifr CASCADE;
DROP TABLE req CASCADE;

CREATE TABLE req (
    ingest_date timestamp without time zone,
    ccr_vnir_1km real,
    ccr_vnir_2km real,
    ccr_mwir_lwir real,
    ccr_vnir_mwir_lwir real,
    ffr2km real,
    ffrlt2km real,
    nav real,
    ssr real,
    wifr real
);
CREATE TABLE g16_metricsfile (
    id serial unique,
    filename varchar not null primary key unique, 
    date date, 
    ingest_date timestamp without time zone
);
CREATE TABLE g16_ccr_ew (
    id serial primary key unique,
    datetime date,
    ingest_date timestamp without time zone,
    chan1 int,
    chan2 int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g16_metricsfile(filename) on delete cascade
);
CREATE TABLE g16_ccr_ns (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan1 int,
    chan2 int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g16_metricsfile(filename) on delete cascade
);
CREATE TABLE g16_ffr_ew (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g16_metricsfile(filename) on delete cascade
);
CREATE TABLE g16_ffr_ns (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g16_metricsfile(filename) on delete cascade
);
CREATE TABLE g16_nav_ew (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g16_metricsfile(filename) on delete cascade
);
CREATE TABLE g16_nav_ns (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g16_metricsfile(filename) on delete cascade
);
CREATE TABLE g16_ssr_ew (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g16_metricsfile(filename) on delete cascade
);
CREATE TABLE g16_ssr_ns (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g16_metricsfile(filename) on delete cascade
);
CREATE TABLE g16_wifr (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g16_metricsfile(filename) on delete cascade
);

CREATE TABLE g17_metricsfile (
    id serial unique,
    filename varchar not null primary key unique, 
    date date, 
    ingest_date timestamp without time zone
);
CREATE TABLE g17_ccr_ew (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan1 int,
    chan2 int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g17_metricsfile(filename) on delete cascade
);
CREATE TABLE g17_ccr_ns (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan1 int,
    chan2 int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g17_metricsfile(filename) on delete cascade
);
CREATE TABLE g17_ffr_ew (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g17_metricsfile(filename) on delete cascade
);
CREATE TABLE g17_ffr_ns (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g17_metricsfile(filename) on delete cascade
);
CREATE TABLE g17_nav_ew (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g17_metricsfile(filename) on delete cascade
);
CREATE TABLE g17_nav_ns (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g17_metricsfile(filename) on delete cascade
);
CREATE TABLE g17_ssr_ew (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g17_metricsfile(filename) on delete cascade
);
CREATE TABLE g17_ssr_ns (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    fsamples int,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g17_metricsfile(filename) on delete cascade
);
CREATE TABLE g17_wifr (
    id serial primary key unique,
    datetime date, 
    ingest_date timestamp without time zone,
    chan int,
    threesig real,
    mean real,
    max real,
    min real,
    metric real,
    nsamples int,
    reqmet int,
    filename varchar not null,
    foreign key (filename) 
        references g17_metricsfile(filename) on delete cascade
);
