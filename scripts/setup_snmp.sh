#!/bin/sh
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
#install snmp
yum -y install net-snmp net-snmp-utils
# set it as a service and to run by default
chkconfig snmpd on
# output snmpd configuration after backing up original
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf-orig
rm /etc/snmp/snmpd.conf
touch /etc/snmp/snmpd.conf
echo "rocommunity Master_XWu2QRNscL6vgFY3uX8U" >> /etc/snmp/snmpd.conf
echo "com2sec readonly default Master_XWu2QRNscL6vgFY3uX8U" >> /etc/snmp/snmpd.conf
# backup hosts.allow and make new configuration in its place
cp /etc/hosts.allow /etc/hosts.allow-orig
rm /etc/hosts.allow
touch /etc/hosts.allow
echo "ALL: 127.0.0.1" >> /etc/hosts.allow
echo "sshd:ALL" >> /etc/hosts.allow
echo "snmpd:ALL" >> /etc/hosts.allow
service snmpd start
echo "Done!"
