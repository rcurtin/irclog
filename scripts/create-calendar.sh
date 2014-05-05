#!/bin/bash
# create-calendar.sh
#
# Generate the HTML for the calendar.  This assumes that links to the other
# mlpack log files will work.

# Name of the log file to generate the calendar from.  We only use the date in
# the filename.
logfile=$1;

# Directory containing other logs.
logdir=$2;

# File to output calendar into.
outfile=$3;

if [ "a$logfile" = "a" ]; then
  echo "Must specify log file as first parameter."
  exit
fi

if [ "a$logdir" = "a" ]; then
  echo "Must specify logs directory as second parameter."
  exit
fi

if [ "a$outfile" = "a" ]; then
  echo "Must specify output file as third parameter."
  exit
fi

# What month is it?  $date is in YYYYMMDD format.
date=`basename $logfile .log | sed 's/^\#mlpack.//'`;

# Split the date apart.
year=`echo $date | sed -E 's/^([0-9]{4})[0-9]*/\1/'`;
month=`echo $date | sed -E 's/^[0-9]{4}([0-9]{2})[0-9]*/\1/'`;
day=`echo $date | sed -E 's/^[0-9]{6}([0-9]{2})/\1/'`;

# Get the weekday corresponding to the first day of the month.
daynames=('Sun' 'Mon' 'Tue' 'Wed' 'Thu' 'Fri' 'Sat');
dow=`date --date="${year}${month}01" '+%w'`;
monthname=`date --date="$date" '+%B'`;
daysinmonth=`cal $month $year | grep '[^ ]' | tail -1 | awk -F' ' '{ print $NF }'`;

# Generate the first row of the calendar table for this month.  We'll use divs
# because divs are the future and HTML table tags make people cringe.  This is
# probably the only non-cringeworthy decision I've made in this entire system.

# Create the calendar itself, with links to last month and next month.
echo "<div class=\"irccal\"><div class=\"irccaltop\">" > $outfile;
lastyear=$year;
lastmonth=$(($month - 1));
if [ "$lastmonth" -eq "0" ]; then
  lastyear=$(($year - 1));
  lastmonth="12";
fi
if [ "$lastmonth" -lt "10" ]; then
  lastmonth="0$lastmonth";
fi

# Does anything from last month exist?
if [ -a "$logdir/#mlpack.${lastyear}${lastmonth}${day}.log" ]; then
  linkto="#mlpack.${lastyear}${lastmonth}${day}.html";
else
  list=`ls $logdir/#mlpack.${lastyear}${lastmonth}*.log 2>/dev/null | wc -l`;
  if [ "a$list" = "a0" ]; then
    # Nothing exists.  No link.
    linkto="";
  else
    # Link to oldest.
    linkto=`ls -t $logdir/#mlpack.${lastyear}${lastmonth}*.log | sed 's/#//' | tail -1`;
    linkto=`basename $linkto .log`;
    linkto="${linkto}.html"
  fi
fi

if [ "a$linkto" = "a" ]; then
  echo "<div class=\"irccalnavleft\">&lt;</div>" >> $outfile;
else
  echo "<div class=\"irccalnavleft\"><a href=\"${linkto}\">&lt;</a></div>" >> $outfile;
fi

# Does anything from next month exist?
nextyear=$year;
nextmonth=$(($month + 1));
if [ "$nextmonth" -eq "13" ]; then
  nextyear=$(($year + 1));
  nextmonth=1;
fi
if [ "$nextmonth" -lt "10" ]; then
  nextmonth="0$nextmonth";
fi

if [ -a "$logdir/#mlpack.${nextyear}${nextmonth}${day}.log" ]; then
  linkto="#mlpack.${nextyear}${nextmonth}${day}.html";
else
  list=`ls $logdir/#mlpack.${nextyear}${nextmonth}*.log 2>/dev/null | wc -l`;
  if [ "a$list" = "a0" ]; then
    linkto="";
  else
    # Link to newest.
    linkto=`ls -t $logdir/#mlpack.${nextyear}${nextmonth}*.log | sed 's/#//' | head -1`;
    linkto=`basename $linkto .log`;
    linkto="${linkto}.html";
  fi
fi

if [ "a$linkto" = "a" ]; then
  echo "<div class=\"irccalnavright\">&gt;</div>" >> $outfile;
else
  echo "<div class=\"irccalnavright\"><a href=\"$linkto\">&gt;</a></div>" >> $outfile;
fi

echo "<div class=\"irccalmonth\">$monthname $year</div>" >> $outfile;

# The header row.
echo "</div><div class=\"irccalheaderrow\">" >> $outfile;
echo "<div class=\"irccalheadercell\">Sun</div>" >> $outfile;
echo "<div class=\"irccalheadercell\">Mon</div>" >> $outfile;
echo "<div class=\"irccalheadercell\">Tue</div>" >> $outfile;
echo "<div class=\"irccalheadercell\">Wed</div>" >> $outfile;
echo "<div class=\"irccalheadercell\">Thu</div>" >> $outfile;
echo "<div class=\"irccalheadercell\">Fri</div>" >> $outfile;
echo "<div class=\"irccalheadercell\">Sat</div>" >> $outfile;

echo "</div>" >> $outfile;

# Now the first row.
echo "<div class=\"irccalrow\">" >> $outfile;

# Fill in spaces where there isn't a day.
cellid=0;
for i in `seq 0 $((dow - 1))`;
do
  echo "<div class=\"irccalinvalidcell\">&nbsp;</div>" >> $outfile;
  cellid=$((cellid + 1)); # Not possible for this to be more than 6.
done

# Now fill in all the days from the first of the month to the current day of the
# month minus one.
for i in `seq 1 $((day - 1))`;
do
  # Do we need a new row?
  cellid=$((cellid + 1));
  if [ "$cellid" -eq "7" ]; then
    cellid=0;
    # Set up new row.
    echo "</div><div class=\"irccalrow\">" >> $outfile;
  fi

  # The cell we are putting information into.
  echo "<div class=\"irccalcell\">" >> $outfile;

  # We want the day number, with a hyperlink to that day's log.
  # This path is hardcoded...
  if [ "$i" -lt "10" ]; then
    # Does this log day exist?
    if [ -a "$logdir/#mlpack.${year}${month}0${i}.log" ]; then
      echo "<a href=\"mlpack.${year}${month}0${i}.html\">$i</a>" >> $outfile;
    else
      echo "$i" >> $outfile;
    fi
  else
    if [ -a "$logdir/#mlpack.${year}${month}${i}.log" ]; then
      echo "<a href=\"mlpack.${year}${month}${i}.html\">$i</a>" >> $outfile;
    else
      echo "$i" >> $outfile;
    fi
  fi

  # Close the cell.
  echo "</div>" >> $outfile;
done

# Today's link.
cellid=$((cellid + 1));
if [ "$cellid" -eq "7" ]; then
  cellid=0;
  echo "</div><div class=\"irccalrow\">" >> $outfile;
fi
adjday=`echo $day | sed 's/^[0]*//'`;
echo "<div class=\"irccalactivecell\">$adjday</div>" >> $outfile;

# The rest of the days in the month.
for i in `seq $((day + 1)) $daysinmonth`;
do
  # Do we need a new row?
  cellid=$((cellid + 1));
  if [ "$cellid" -eq "7" ]; then
    cellid=0;
    echo "</div><div class=\"irccalrow\">" >> $outfile;
  fi

  # The cell we are putting information into.
  echo "<div class=\"irccalcell\">" >> $outfile;
  if [ "$i" -lt "10" ]; then
    if [ -a "$logdir/#mlpack.${year}${month}0${i}.log" ]; then
      echo "<a href=\"mlpack.${year}${month}0${i}.html\">$i</a>" >> $outfile;
    else
      echo "$i" >> $outfile;
    fi
  else
    if [ -a "$logdir/#mlpack.${year}${month}${i}.log" ]; then
      echo "<a href=\"mlpack.${year}${month}${i}.html\">$i</a>" >> $outfile;
    else
      echo "$i" >> $outfile;
    fi
  fi
  echo "</div>" >> $outfile;
done


# Close the calendar.
echo "</div><div class=\"separator\"></div>" >> $outfile;
echo "<div class=\"irccalallnav\"><a href=\"logs-all.html\">list of all logs</a></div></div>" >> $outfile;