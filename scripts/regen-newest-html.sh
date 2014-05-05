#!/bin/bash
# regen-newest-html.sh <irssi-logdir> <output-html-dir>
#
# A ridiculous bash script to regenerate HTML IRC log files.  This is really
# getting close to the wrongest way to run a public logging system.  I kinda
# like it because it's so terrible.
#
# This expects that header.html and footer.html are in
# output-html-dir/templates/ and those will be used to generate the header and
# footer.

echo "Content-type: text/html"
echo "";

cd ..; # Don't run in scripts/.
logdir='./logs/';
htmldir='.';
scriptdir='./scripts/';

if [ "a$logdir" = "a" ]; then
  echo "Must specify log directory as first parameter."
  exit
fi

if [ "a$htmldir" = "a" ]; then
  echo "Must specify html directory as second parameter."
  exit
fi

if [ "a$scriptdir" = "a" ]; then
  echo "Assuming that scriptdir is scripts/."
  scriptdir="scripts/";
fi

logfile=`ls -t $logdir | head -1`;

# Isn't this abomination of sed awesome?  We're taking the irssi logs and
# forcing them to be HTML.  If irssi ever changes log format, we're super
# fucked.  You'll know because the logs will display all funky and on one line,
# then you'll find your way here and go "dear fucking Jesus what is this shit?".
# Haha!  Sucks!  Have fun!

# Modify some unset information in the templates, after deriving what the day
# is.
filename=`basename $logfile .log | sed 's/#//'`;
date=`echo $filename | sed -E 's/.*([0-9]{4})([0-9]{2})([0-9]{2}).*/\1-\2-\3/'`;

# Print the header.
cat $htmldir/templates/header.html | sed -E 's/%%DAY%%/'$date'/g'

# Generate the calendar.
$scriptdir/create-stdout-calendar.sh $logfile $logdir;

# Turn the irssi log into something that's kind of like HTML.
cat $logdir/$logfile | sed -E 's/</\&lt;/g' |
                       sed -E 's/>/\&gt;/g' |
                       sed -E 's/$/<\/font><br>/' |
                       sed -E 's/-!-/<\/font><font color="#aaaaaa">-!-<\/font><font color="#666666">/' |
                       sed -E 's/(&lt; .*&gt;)/<\/font><font color="#eab72c">\1<\/font><font color="#aaaaaa">/'|
                       sed -E 's/^/<font color="#bb2222">/'

cat $htmldir/templates/footer.html
