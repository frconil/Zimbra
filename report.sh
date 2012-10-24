#!/bin/bash


#We need to get a list of users with their quota, quota used, and whether they're using SmartPhone sync for builling purposes

tmpFile=`mktemp`
echo "USER , PRO , QUOTA IN USE , QUOTA SET" > /tmp/report.csv

#get quota for non system accounts

zmprov gqu localhost |  egrep -v 'wiki|ham|spam|galsync|restored' > $tmpFile

#export data in human readable format
while read line ; do
	userReport=$line
	user=`echo $userReport | cut -f1 -d\ `
	max_quota=`echo $userReport | cut -f2 -d\ | \
	gawk 'END{sum=$1; hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**3; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break }}}'`
	used_quota=`echo $userReport | cut -f3 -d\ | \
	gawk 'END{sum=$1; hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**3; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break }}}'`
	zmprov -l -v ga $user  | grep  -q "zimbraFeatureMobileSyncEnabled: TRUE"
	if [ "$?" -eq "0" ]; then
		echo "$user , 1 , $used_quota , $max_quota" >> /tmp/report.csv
	else
		echo "$user , 0 , $used_quota , $max_quota" >> /tmp/report.csv
	fi
done <  $tmpFile

#mail file to accounts for billing
mutt -a /tmp/report.csv -s "VSPP report" accounts@domain.com < /dev/null
                                                                    
