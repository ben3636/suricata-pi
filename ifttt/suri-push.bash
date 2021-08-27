#!/bin/bash

###---Define Functions---###
function push_notif(){
        message=$1
        v2=$2
        v3=$3
        curl -X POST -H "Content-Type: application/json" -d '{"value1":"'"$message"'","value2":"'"$v2"'","value3":"'"$v3"'"}' https://maker.ifttt.com/trigger/Pi-IDS/with/key/UntimRA5FlDbyVp5GRuNU
}

###---Parse Suricata Logs to 'suri-log.txt'---###
date=$(date -Idate | awk -F '-' ' { print $2"/"$3"/"$1 } ')
cat /var/log/suricata/fast.log | grep $date | awk ' { $1=""; $2=""; $3=""; print} ' | grep -v "Generic Protocol Command Decode" | sort | sed s/"..... ->"/" ->"/g | uniq > suri-log.txt
if [[ $(cat suri-log.txt) != '' ]]
then
        cat suri-log.txt | while read line
        do
                event=$(echo $line | grep -o .*[**] | sed s/'\[\*\*'//g)
                class=$(echo $line | grep -o "\[**\].*\[" | sed s/"\] \["//g)
                proto=$(echo $line | grep -o "{...}")
                src_addr=$(echo $line | grep -o "}.*" | sed s/}//g | sed s/:/' '/g | awk ' { print $1 } ')
                dst_addr=$(echo $line | grep -o "}.*" | sed s/}//g | sed s/:/' '/g | awk ' { print $3 } ')
                dst_port=$(echo $line | grep -o "}.*" | sed s/}//g | sed s/:/' '/g | awk ' { print $4 } ')
                echo "Date: $date"
                echo "Event: $event"
                echo "$class"
                echo "Protocol: $proto"
                echo "$src_addr ------> $dst_addr ($dst_port)"
                echo
                echo "-------------------------"
        done > suri-push.txt
fi

###---Clean Up 'suri-log.txt'---###
rm suri-log.txt

###---Populate Alert List & Get Name/Class/SRC/DST For Each---###
cat suri-push.txt | grep '(.*)' > suri-event-list.txt #Identify each event by the src-->dst(port)
cat suri-event-list.txt | while read line #Loop through this list and pull out additional data for each event from suri-push.txt
do
        src_dst=$line
        event=$(grep -B3 "$src_dst" suri-push.txt | grep -m1 Event)
        class=$(grep -B3 "$src_dst" suri-push.txt | grep -m1 Classification)
###---Determine If Notif Has Already Been Sent, Send If No, Abort If Yes---###
        past_notif="$event $class $src_dst"
        #echo "DEBUG: $past_notif"
        if [[ $(grep -F "$past_notif" non-dup-push.txt) == '' ]]
        then
                echo "Sending Notif for:      $past_notif"
                push_notif "$event" "$class" "$src_dst"
                echo "$event $class $src_dst" >> non-dup-push.txt
                echo
                echo
        else
                echo "Notif already sent for:      $past_notif"
                echo
                echo
        fi
done

###---Clean Up---###
rm suri-event-list.txt
rm suri-push.txt
