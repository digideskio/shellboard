#!/bin/bash

# runs as `watch -n 40 -t cricket.sh`

if [ "$1" != ""  ]; then 
	if [ "$1" == '-m' ] && [ "$2" != "" ]; then
		# download the page for the respective match
		wget -q -O $2 http://www.espncricinfo.com/netstorage/$2.html

		# display the intial basic scorecard
		awk "/statusText/ || /teamText/" $2 | sed 's/<[^>]*>//g'

		# show the recent 5 overs scores 
		awk "/Recent overs/" $2 | sed 's/<[^>]*>//g'

		# who was out last
		echo "Last Wicket : "
		awk '/Last Bat/ {for(i=1; i<=5; i++) {getline; print}}' $2 | sed 's/<[^>]*>//g'

		# The page title has some sweet information 
		# awk it set the field speerator value as '=' since it is sperated by this 
		# cut the `title =` part 
		# cut the latter espn title 
		# cut of the first 2 characters 
		# and the last 1 character for sanity sake
		awk -F = "/parent/ && /title/ && /ESPN/" $2 | cut -d \= -f 2 | cut -d \| -f 1 | sed 's/..\(.*\)/\1/' | sed 's/\(.*\)./\1/'

		# and delete the file
		rm $2;
	else
		echo -e 'Usage: \n cricket.sh \n cricket.sh -m matchid'
	fi
else
	# show the live scores if no match id seleted, the rss has some decent information on the mathch scores and also holds matchid for indepth following
	wget -q http://static.espncricinfo.com/rss/livescores.xml

	IFS=','	# set the internal file sperator as ',' for usage in the array 

	# save the scores as an array for later display, add a comma to the end for seperating them as arrays
	scores=( `grep 'title' livescores.xml  | sed 's/<[^>]*>//g' | sed 's/$/,/'` ) 

	# the matchids of better information
	matchids=( `awk '/guid/ && /html/' livescores.xml  | sed 's/<[^>]*>//g' | tr -d '. / : [:alpha:]' | sed 's/$/,/'` )

	# find the total number of matches, just count the number of values in scores array
	total=${#scores[*]}

	# display them
	for (( i=0; i<=$total; i++ ))
	do
		# the first score is actually badly awk-ed and stores some unwanted stuff, hence the +1
		# display them in columns with scores and matchids side by side, adding colours breaks the output 
		( echo "${scores[$i+1]}" ; echo "${matchids[$i]}" ) | column -x ;
	done
	rm livescores.xml
fi
tput sgr0 # reset the colours, not needed anymore though
