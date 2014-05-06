#!/bin/bash
# build-page.sh $logfile
#
# A ridiculous bash script to regenerate HTML IRC log files.  This takes an
# irssi logfile as an argument and then outputs some escaped HTML.  Doesn't do
# anything with a header or footer, and is (in general) meant for use in other
# scripts.

logfile=$1;

if [ "a$logfile" = "a" ]; then
  echo "Must specify log file as first parameter."
  exit
fi

# Isn't this abomination of sed awesome?  We're taking the irssi logs and
# forcing them to be HTML.  If irssi ever changes log format, we're super
# fucked.  You'll know because the logs will display all funky and on one
# line, then you'll find your way here and go "dear fucking Jesus what is this
# shit?".  Haha!  Sucks!  Have fun!
cat $logfile | sed -E 's/</\&lt;/g' |
               sed -E 's/>/\&gt;/g' |
               sed -E 's/$/<\/font><br>/' |
               sed -E 's/-!-/<\/font><font color="#aaaaaa">-!-<\/font><font color="#666666">/' |
               sed -E 's/(&lt; .*&gt;)/<\/font><font color="#eab72c">\1<\/font><font color="#aaaaaa">/'|
               sed -E 's/^/<font color="#bb2222">/';
