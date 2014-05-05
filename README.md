The scripts contained in this directory are meant to manage IRC logs for
mlpack (#mlpack on freenode).  Instead of using PHP or some pre-existing
solution, we can use a hacked-together mess of bullshit cron jobs and shell
scripts that works only for this particular setup and will fall over
catastrophically in other situations.  Seriously, using a cron job to update an
HTML page with a calendar on it?  What the hell?  Why?

Our situation is this:

 naywhayare logs #mlpack using irssi into
 /home/ryan/irclogs/freenode/mlpack/#mlpack.%Y%m%d.log and irssi automatically
 rotates this.  It is in UTC.  Commands for making irssi use UTC time and
 automatically logging:

   /script exec ENV{'TZ'}='UTC';
   /log open -targets #mlpack ~/irclogs/freenode/mlpack/#mlpack.%Y%m%d.log

 We want to display all of these logs on www.mlpack.org/irc/logs.html (and
 related pages), and also make them available for download.

----

First things first, let's get the actual logs in the right place.  We want all
logs to be available in /var/www/www.mlpack.org/irc/logs/#mlpack.%Y%m%d.log.
This is simple enough:

  ln -s /home/ryan/irclogs/freenode/mlpack /var/www/www.mlpack.org/logs/

----

Now, we need to regenerate the HTML files to display logs on certain days.  The
results of this will be in /var/www/www.mlpack.org/irc/ but we will also
provide the following:

  /var/www/www.mlpack.org/irc/mlpack.${DATE}.html (current day's logs)
  /var/www/www.mlpack.org/irc/all-logs.html (all of the logs in one file, and a
      link to download them all)

We'll do this with a cron job that runs every hour to check if it's 00:01 UTC,
and if so, it regenerates all the pages.  This cron job will run some scripts:

  scripts/regen-html.sh $logdir $outputdir $scriptdir
  scripts/make-all-logs.sh $logdir $outputdir

That script will parse all of the log files and build .html files for every log
file.  Templates for the header and footer are found in

  /var/www/www.mlpack.org/irc/templates/header.html
  /var/www/www.mlpack.org/irc/templates/footer.html

And there is also a different header for all-logs.html:

  /var/www/www.mlpack.org/irc/templates/header-all.html

Our crontab entry looks like this:

  5 * * * * /var/www/www.mlpack.org/irc/scripts/check-utc-new-day.sh /var/www/www.mlpack.org/irc/scripts/regen-html.sh /var/www/www.mlpack.org/irc/logs/ /var/www/www.mlpack.org/irc/ /var/www/www.mlpack.org/irc/scripts/

check-utc-new-day.sh is just a script that checks whether or not it is between
12am and 1am UTC, and runs the given command if that is true.

----

Lastly, we want to have logs auto-generated for the current day when a user
requests a page.  This can be done with CGI (...it could be done with PHP, too,
but hey, CGI is cool).  We can do this by modifying our Apache configuration for
the site to allow CGI for mlpack.org/irc/.  Once mod_cgi is enabled, we can add
this to the site configuration:

   ScriptAlias /cgi-bin/ /var/www/www.mlpack.org/irc/cgi-bin/
   <Directory "/var/www/www.mlpack.org/irc/cgi-bin/">
     Options +ExecCGI
     AddHandler cgi-script .cgi .sh
   </Directory>

And then we can create the directory /var/www/www.mlpack.org/irc/cgi-bin/ and
link the script /var/www/www.mlpack.org/irc/scripts/regen-newest-html.sh to that
directory.  regen-newest-html.sh has some hardcoded parameters that will need to
be changed for a different site.

Then, we need to create the main, dynamically generated site using Apache
server-side includes.  This implies a site configuration bit that looks a little
like this:

   <Directory "/var/www/www.mlpack.org/irc/">
      AllowOverride All
      Options +Includes
      XBitHack on
      Order Deny,Allow
      Allow From All;
   </Directory>

(the Options +Includes is the important part here)

The file logs.html just includes the most recent log, and the header and footer,
using Apache SSIs.  It must be marked executable so that Apache processes it
(due to XBitHack being set to 'on').

Also, probably a good idea to link logs.html to index.html so that users who go
to site/irc/ get to the right place.

----

This should do it!  Adapting the system to a different site should basically
mean:

 * Getting the logs to log to the correct place with the correct timestamps.
 * Making sure irssi is always logging.
 * Modifying the header/footer templates.
 * Modifying your Apache configuration to allow CGI and SSI.
 * Setting a cron job to regenerate the logs each day.

Maybe that will work, and if you're lucky you'll have a system that generates
entirely static HTML logs that are auto-updating!

Please don't mail me bombs or other incendiary devices for this abomination.
I'll take PRs if you have an improvement, though...

