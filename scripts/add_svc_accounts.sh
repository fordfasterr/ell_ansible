#!/bin/sh 
#Create user accounts, assign groups, and set password to never expire.

# Service account creation
declare -a SetupComment;                                        declare -a SetupCommand
SetupComment[1]="Adding Banjobs account";       SetupCommand[1]="/usr/sbin/adduser -g banner -G dba,banjobs svc_dars"
SetupComment[2]="Adding Banner account";        SetupCommand[2]="/usr/sbin/adduser -g banner -G dba,banjobs svc_applyuc"
SetupComment[3]="Banjobs accountpassword expiration";        SetupCommand[3]="/usr/bin/chage -I -1 -m 0 -M 99999 -E -1 svc_dars"
SetupComment[4]="Banner account password expiration";        SetupCommand[4]="/usr/bin/chage -I -1 -m 0 -M 99999 -E -1 svc_applyuc"
SetupLines=4


# Install packages and create service accounts
for ((i=1; i<=$SetupLines; i++))
do
        echo "${SetupComment[$i]}"
        ${SetupCommand[$i]}
done
