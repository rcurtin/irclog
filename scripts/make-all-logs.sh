#!/bin/bash
# make-all-logs.sh
#
# Create the file all-logs.html, which lists links to all of the individual log
# days.

logdir=$1;
htmldir=$2;

if [ "a$logdir" = "a" ]; then
  echo "First parameter must be the log directory.";
  exit
fi

if [ "a$htmldir" = "a" ]; then
  echo "Second parameter must be output html directory.";
  exit
fi

# For each log entry, make a link.
for i in $logdir/#mlpack.*.log;
do
  filename=`basename $i .log | sed 's/#//'`;
  date=`echo $filename | sed 's/mlpack\.//'`;
  displaydate=`date --date=${date} '+%B %d, %Y (%A)'`;
  lines=`grep '^[0-9][0-9]:[0-9][0-9] < ' $i | wc -l`;

  echo "<a href=\"${filename}.html\">$displaydate</a> " >> $htmldir/all-logs.tmp;
  if [ "$lines" -gt "10" ]; then
    echo "<font class=\"irclotsoflines\">" >> $htmldir/all-logs.tmp;
  fi
  echo "[$lines lines of chat]" >> $htmldir/all-logs.tmp;
  if [ "$lines" -gt "10" ]; then
    echo "</font>" >> $htmldir/all-logs.tmp;
  fi
  echo "<br>" >> $htmldir/all-logs.tmp;
done

cat $htmldir/templates/header-all.html $htmldir/all-logs.tmp $htmldir/templates/footer.html > $htmldir/all-logs.html;

rm -f $htmldir/all-logs.tmp;

# Now generate mlpack.log, which has every bit of log in it.
cat $logdir/#mlpack.*.log > $htmldir/mlpack.log
