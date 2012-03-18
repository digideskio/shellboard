# runs as `watch -n 40 -t cricket.sh`

if [ $1 == "none" ]; then
	# show the live scores if no match id seleted
	wget -q http://static.espncricinfo.com/rss/livescores.xml
	#match scores
	grep 'title' livescores.xml  | sed 's/<[^>]*>//g'
	#match id
	awk '/guid/ && /html/' livescores.xml  | sed 's/<[^>]*>//g' | tr -d '. / : [:alpha:]'
	rm livescores.xml
else
	wget -q -O $1 http://www.espncricinfo.com/netstorage/$1.html
	awk "/statusText/ || /teamText/" $1 | sed 's/<[^>]*>//g'
	#	echo '\n'
	awk "/Recent overs/" $1 | sed 's/<[^>]*>//g'
	echo "Last Wicket : "
	awk '/Last Bat/ {for(i=1; i<=5; i++) {getline; print}}' $1 | sed 's/<[^>]*>//g'
	#	echo -e '\n----------------------------------------------------------------------\n'
	#	show only the title javascript part | cut the initial eqating part| cut the latter espn stuff | cut of the first 2 characters | and the last 1 character (ad more dots for more characters)
	awk -F = "/parent/ && /title/ && /ESPN/" $1 | cut -d \= -f 2 | cut -d \| -f 1 | sed 's/..\(.*\)/\1/' | sed 's/\(.*\)./\1/'
	#	sleep 40;
	#	getMatch $1
	rm $1;
fi
