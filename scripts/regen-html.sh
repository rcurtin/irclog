#!/bin/bash
# regen-html.sh <irssi-logdir> <output-html-dir>
#
# A ridiculous bash script to regenerate HTML IRC log files.  This is really
# getting close to the wrongest way to run a public logging system.  I kinda
# like it because it's so terrible.
#
# This expects that header.html and footer.html are in
# output-html-dir/templates/ and those will be used to generate the header and
# footer.

logdir=$1;
htmldir=$2;
scriptdir=$3;

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

for i in $logdir/*; do
  # Isn't this abomination of sed awesome?  We're taking the irssi logs and
  # forcing them to be HTML.  If irssi ever changes log format, we're super
  # fucked.  You'll know because the logs will display all funky and on one
  # line, then you'll find your way here and go "dear fucking Jesus what is this
  # shit?".  Haha!  Sucks!  Have fun!

  # Turn the irssi log into something that's kind of like HTML.

  filename=`basename $i .log | sed 's/#//'`;
  cat $i | sed -E 's/</\&lt;/g' |
           sed -E 's/>/\&gt;/g' |
           sed -E 's/$/<\/font><br>/' |
           sed -E 's/-!-/<\/font><font color="#aaaaaa">-!-<\/font><font color="#666666">/' |
           sed -E 's/(&lt;.*&gt;)/<\/font><font color="#eab72c">\1<\/font><font color="#aaaaaa">/'|
           sed -E 's/^/<font color="#bb2222">/' > $htmldir/$filename.tmp;

  # Generate the calendar.
  $scriptdir/create-calendar.sh $i $logdir $htmldir/cal.tmp;

  # Assemble the file.
  cat $htmldir/templates/header.html $htmldir/cal.tmp $htmldir/$filename.tmp $htmldir/templates/footer.html > $htmldir/$filename.html;
  chmod 644 $htmldir/$filename.html;

  rm $htmldir/cal.tmp;
  rm $htmldir/$filename.tmp;

  # Modify some unset information in the templates, after deriving what the day
  # is.
  date=`echo $filename | sed -E 's/.*([0-9]{4})([0-9]{2})([0-9]{2}).*/\1-\2-\3/'`;

  sed -i -E 's/%%DAY%%/'$date'/g' $htmldir/$filename.html;
done
