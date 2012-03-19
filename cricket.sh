# runs as `watch -n 40 -t cricket.sh`

if [ "$1" != ""  ]; then 
	if [ "$1" == '-m' ] && [ "$2" != "" ]; then
		wget -q -O $2 http://www.espncricinfo.com/netstorage/$2.html
		awk "/statusText/ || /teamText/" $2 | sed 's/<[^>]*>//g'
		#	echo '\n'
		awk "/Recent overs/" $2 | sed 's/<[^>]*>//g'
		echo "Last Wicket : "
		awk '/Last Bat/ {for(i=1; i<=5; i++) {getline; print}}' $2 | sed 's/<[^>]*>//g'
		#	echo -e '\n----------------------------------------------------------------------\n'
		#	show only the title javascript part | cut the initial eqating part| cut the latter espn stuff | cut of the first 2 characters | and the last 1 character (ad more dots for more characters)
		awk -F = "/parent/ && /title/ && /ESPN/" $2 | cut -d \= -f 2 | cut -d \| -f 1 | sed 's/..\(.*\)/\1/' | sed 's/\(.*\)./\1/'
		#	sleep 40;
		#	getMatch $1
		rm $2;
	
	else
		echo -e 'Usage: \n cricket.sh \n cricket.sh -m matchid'
	fi
else
	# show the live scores if no match id seleted
	wget -q http://static.espncricinfo.com/rss/livescores.xml
	#match scores
	IFS=','
	scores=( `grep 'title' livescores.xml  | sed 's/<[^>]*>//g' | sed 's/$/,/' `  ) 
	unset scores[0]
	#match id
	matchids=( `awk '/guid/ && /html/' livescores.xml  | sed 's/<[^>]*>//g' | tr -d '. / : [:alpha:]' | sed 's/$/,/' ` )
	total=${#scores[*]}
	for (( i=0; i<=$(( $total)); i++ ))
	do
		echo -e "\E[36m ${scores[$i]} \E[31m ${matchids[$i]}";
	done
	rm livescores.xml
fi
tput sgr0
