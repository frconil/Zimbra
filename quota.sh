#!/bin/bash

#normal quota messages do not show up in shared folders/are ignored by users/do not follow forward settings
#helpdesk needs to know when folders are almost full

warn_percentage=95

tmpFile=`mktemp`

#project folders are <project number>@domain.com
zmprov gqu localhost |  grep "[0-9]*@domain.com" > $tmpFile

while read line ; do

    userReport=$line
    user=`echo $userReport | cut -f1 -d\ `
    max_quota=`echo $userReport | cut -f2 -d\ `
    used_quota=`echo $userReport | cut -f3 -d\ `
           
    if [ $max_quota -ne 0 ] ; then
       quota_percentage=`echo "scale=1; (($used_quota * 100)/ $max_quota)" | bc`
                            
       if [ `echo "$quota_percentage >= $warn_percentage" | bc` -eq 1 ] ; then
          max_quota_megs=`echo "scale=1; ($max_quota / 1048576)" | bc`
          echo "You are currently using $quota_percentage% of your mailbox quota of $max_quota_megs megabytes." | mail -s \"Quota Warning - $quota_percentage%\" helpdesk@domain.com
       fi
    fi
done < $tmpFile
                                                                        
rm -f tmpFile
                                                                        
