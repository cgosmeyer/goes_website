#!/usr/bin/env perl
############################################################################
# gcst.pl
# This is the main perl script that hypnotoad uses to generate
# the Geometric Characterization Support Team website
############################################################################

use Mojolicious::Lite -signatures;
use Mojo::Headers;

# Defend against clickjacking (maybe)
my $headers = Mojo::Headers->new;
$headers->add('X-Frame-Options' => 'sameorigin');

get '/' => {template => 'index'};

# Trend Plotting Form:
get '/trend_plot_form' => {template => 'trend_plot_form'};

# News
get '/news' => {template => 'news'};

# Resources
get '/publications_goesr' => {template => 'publications_goesr'};
get '/publications_modis' => {template => 'publications_modis'};
get '/publications_viirs' => {template => 'publications_viirs'};

# About
get '/about' => {template => 'about'};

# Data
get '/data' => {template => 'data'};

# Software
get '/software' => {template => 'software'};

# Dashboard and Dashboard Form
get '/dashboard' => {template => 'dashboard'};
get '/dashboard_form' => {template => 'dashboard_form'};

# Interactive Plotting Form (decrepit)
get '/interactive_plots_form' => {template => 'interactive_plots_form'};
# Custom Plotting Form
get '/custom_plot_form' => {template => 'custom_plot_form'};

# Grab relevant variables from dashboard_form
# and stash so that dashboard can recieve them
post '/dashboard' => sub {
  my $c = shift;
  $c->stash(selected_date => $c->req->param('selected_date'));
  $c->stash(sat => $c->req->param('sat'));
  $c->render(template => 'dashboard');
};

# Grab relevant variables from dashboard
# and stash so that dashboard_plot can recieve them
post '/dshbd_plt' => sub {
  my $c = shift;
  $c->stash(year => $c->req->param('year'));
  $c->stash(dayofyear => $c->req->param('day'));
  $c->stash(sat => $c->req->param('sat'));
  $c->stash(metric => $c->req->param('metric'));
  $c->stash(chan1 => $c->req->param('chan1'));
  $c->stash(chan2 => $c->req->param('chan2'));
  $c->stash(dir => $c->req->param('dir'));
  $c->render(template => 'dashboard_plot');
};

# Grab relevant variables from dashboard_plot
# and stash so that dashboard_userdef_plot can recieve them
post '/dshbd_usrdf_plt' => sub {
  my $c = shift;
  $c->stash(filename => $c->req->param('filename'));
  $c->stash(year => $c->req->param('year'));
  $c->stash(dayofyear => $c->req->param('dayofyear'));
  $c->stash(sat => $c->req->param('sat'));
  $c->stash(metric => $c->req->param('metric'));
  $c->stash(chan1 => $c->req->param('chan1'));
  $c->stash(chan2 => $c->req->param('chan2'));
  $c->stash(dir => $c->req->param('dir'));
  $c->stash(yrange_min => $c->req->param('yrange_min'));
  $c->stash(yrange_max => $c->req->param('yrange_max'));
  $c->stash(overplot_min => $c->req->param('overplot_min'));
  $c->stash(overplot_max => $c->req->param('overplot_max'));
  $c->stash(sigma => $c->req->param('sigma'));
  $c->stash(plot_sd => $c->req->param('plot_sd'));
  $c->stash(yrange => $c->req->param('yrange'));
  $c->stash(agg => $c->req->param('agg'));
  $c->render(template => 'dashboard_userdef_plot');
};

# Grab relevant variables from trend_plot_form
# and stash so that trend_plot can recieve them
post '/trend_plot' => sub {
  my $c = shift;
  $c->stash(sat => $c->req->param('sat'));
  $c->stash(metric => $c->req->param('metric'));
  $c->stash(chan1 => $c->req->param('chan1'));
  $c->stash(chan2 => $c->req->param('chan2'));
  $c->render(template => 'trend_plot');
};

# Grab relevant variables from custom_plot_form
# and stash so that custom_plot can recieve them
post '/custom_plot' => sub {
  my $c = shift;
  $c->stash(date_start => $c->req->param('date_start'));
  $c->stash(date_end => $c->req->param('date_end'));
  $c->stash(sat => $c->req->param('sat'));
  $c->stash(metric => $c->req->param('metric'));
  $c->stash(chan1 => $c->req->param('chan1'));
  $c->stash(chan2 => $c->req->param('chan2'));
  $c->stash(sigma => $c->req->param('sigma'));
  $c->stash(plot_sd => $c->req->param('plot_sd'));
  $c->stash(yrange => $c->req->param('yrange'));
  $c->stash(yrange_min => $c->req->param('yrange_min'));
  $c->stash(yrange_max => $c->req->param('yrange_max'));
  $c->render(template => 'custom_plot');
};

# Start the website!
app->start;
    

__DATA__

<!-- Start the exception page -->
@@ layouts/exception.production.html.ep
<!DOCTYPE html>
<html>
  <head><title>Server error</title></head>
  <body>
    <h1>Exception</h1>
    <p><%= $exception->message %></p>
    <h1>Stash</h1>
    <pre><%= dumper $snapshot %></pre>
  </body>
</html>
<!-- End the exception page -->

<!-- Start the wrapper page -->
@@ layouts/wrapper.html.ep
<!DOCTYPE html>
<html>

<!-- Header -->
<head>
<meta charset="utf-8">
<link href="/stylesheet.css?rnd=132" rel="stylesheet" type="text/css">
<title><%= title %></title>
</head>

<body>

<!-- Menubar -->
<ul id="menubar">
  <li><a href=#top><img src="/NASA_logo.png" width="60" alt="NASA meatball"></a></li>
  <li>
    <table>
        <tr><td><div class="gcst_large"><a href="/about">GCST</a></div></td></tr>
        <tr><td><div class="gcst_small">Geometric Characterization Support Team</div></td></tr>
    </table>
  </li>
  <li><a href="/">Home</a></li>
  <li class="dropdown">
    <a href="javascript:void(0)" class="dropbtn">Monitoring</a>
    <div class="dropdown-content">
      Long-Term Trending
    <div class="dropdown-content-sub">
      <a href="/trend_plots_goes16">GOES-16</a>
      <a href="/trend_plots_goes17">GOES-17</a>
      <a href="/trend_plots_modis">MODIS</a>
      <a href="/trend_plots_viirs">VIIRS</a>
    </div>
      <hr></hr>
      <a href="/trend_plot_form">Long-Term Trending</a>    
      <hr></hr>
      <a href="/dashboard_form">Status Dashboard</a>
      <hr></hr>
      <a href="/custom_plot_form">Order a Custom Plot</a>
    </div>
  </li>
  <li><a href="/news">News</a></li>
  <li class="dropdown">
    <a href="javascript:void(0)" class="dropbtn">Resources</a>
    <div class="dropdown-content">
    <div class="dropdown-content-sub">
      <a href="/publications_goesr">GOES-R</a>
      <a href="/publications_modis">MODIS</a>
      <a href="/publications_viirs">VIIRS</a>
    </div>
    </div>
  </li>
  <li><a href="/software">Software</a></li>
  <li><a href="/data">Data</a></li>
</ul>

<!-- Main body -->
<%= content %>

<!-- Footer -->
<footer>
  <div class='row' style='margin-top: 0.5em;'>
    <div class="column_footer">
      <!-- External links -->
      <p>
        <a href="https://www.nasa.gov/about/highlights/HP_Privacy.html">Privacy</a> | 
        <a href="/about">About</a> | 
        <a href="mailto:gcst@nasa.gov">Contact</a> 
        <!-- | <a href="https://earthobservatory.nasa.gov/"> Earth Observatory</a> -->
      </p>
    </div>
    
    <div class="column_footer">
      <!-- <a href="https://www.goes-r.gov"><img src="/GOES-R_logo.png" width="100"></a> -->
    </div>
    
    <div class="column_footer">
      <!-- Page last updated -->
      <p>
      Last updated: <script type="text/javascript">document.write(document.lastModified);</script>
      </p>
    </div>
  </div>
</footer>

</body>
</html>
<!-- End the wrapper page -->
