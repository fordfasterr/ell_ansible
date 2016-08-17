#!/bin/sh

# ELLUCIAN Post-installation Script - RHEL6
# =========================================
# Last update 2015-01-16, 13:35EST by Karl Simpson, karl.simpson@ellucian.com

DATE=`date +%Y-%M-%d`
TIME=`date +%H:%M`
HOSTNAME=`hostname`
IP_ADDRESS=`ifconfig eth0|grep 'inet '|cut -d: -f 2|cut -d' ' -f 1`
EMAIL_ADDRESS=steve.arniella@ellucian.com
LOGFILE=/tmp/ellucian-post-install.log
ADMIN_PACKAGES="audiofile.i686 audiofile.x86_64 binutils dos2unix ksh logwatch nmap screen unix2dos yum-plugin* zsh"
ORACLE_PACKAGES="compat-libstdc++-33 compat-libstdc++-33.i686 elfutils-libelf elfutils-libelf-devel elfutils-libelf-devel-static gcc gcc-c++ glibc glibc-common glibc-devel glibc-devel.i686 glibc-headers glibc.i686 kernel-headers libaio libaio-devel libaio-devel.i686 libaio.i686 libgcc libgomp libstdc++ libstdc++.i686 libstdc++-devel libstdc++-devel.i686 libXext libXext.i686 libXtst libXtst.i686 make openmotif openmotif.i686 openmotif22 openmotif22.i686 sysstat unixODBC unixODBC-devel"


# New lines for /etc/security/limits.conf
declare -a Limits
Limits[1]="*           soft    nproc     2047"
Limits[2]="*           hard    nproc     16384"
Limits[3]="*           soft    nofile    1024"
Limits[4]="*           hard    nofile    65536"
Limits[5]="*           soft    stack     10240"
Limits[6]="*           hard    stack     10240"
Limits[7]=" "
Limits[8]="svc_oracle      soft    nproc     2047"
Limits[9]="svc_oracle      hard    nproc     16384"
Limits[10]="svc_oracle      soft    nofile    1024"
Limits[11]="svc_oracle      hard    nofile    65536"
Limits[12]="svc_oracle      soft    stack     10240"
Limits[13]="svc_oracle      hard    stack     10240"
Limits[14]=" "
Limits[15]="# End of file"

# New lines for /etc/sysctl.conf
declare -a SysCtl
SysCtl[1]=" "
SysCtl[2]="# Oracle requirments"
SysCtl[3]="kernel.msgmax = 65536"
SysCtl[4]="kernel.shmmax = 4294967295"
SysCtl[5]="kernel.shmall = 268435456"
SysCtl[6]="kernel.shmmni = 4096"
SysCtl[7]="kernel.sem = 250 32000 100 128"
SysCtl[8]="fs.file-max = 10240000"
SysCtl[9]="fs.aio-max-nr = 1048576"
SysCtl[10]="net.ipv4.ip_local_port_range = 9000 65500"
SysCtl[12]="net.core.rmem_default = 16777216"
SysCtl[13]="net.core.wmem_default = 16777216"
SysCtl[14]="net.core.rmem_max = 16777216"
SysCtl[15]="net.core.wmem_max = 16777216"

# BigFix installation
#declare -a BigFix
#BigFix[1]="mkdir /etc/opt/BESClient"
#BigFix[2]="wget http://bigfix.elluciancloud.com:52311/install.sh"
#BigFix[3]="chmod 555 install.sh"
#BigFix[4]="./install.sh"

# Package install and service account creation
declare -a SetupComment;                                        declare -a SetupCommand
SetupComment[1]="Install missing packages";     SetupCommand[1]="/usr/bin/yum -y install $ADMIN_PACKAGES $ORACLE_PACKAGES"
SetupComment[2]="Adding Banner group";          SetupCommand[2]="/usr/sbin/groupadd -g 3501 banner"
SetupComment[3]="Adding Oracle account";        SetupCommand[3]="/usr/sbin/adduser -g dba -u 3500 svc_oracle"
SetupComment[4]="Adding Banjobs account";       SetupCommand[4]="/usr/sbin/adduser -g banner -u 301 svc_banjobs"
SetupComment[5]="Adding Banner account";        SetupCommand[5]="/usr/sbin/adduser -g banner -u 3501 svc_banner"
SetupComment[6]="Oracle account password expiration";        SetupCommand[6]="/usr/bin/chage -I -1 -m 0 -M 99999 -E -1 svc_oracle"
SetupComment[7]="Banjobs accountpassword expiration";        SetupCommand[7]="/usr/bin/chage -I -1 -m 0 -M 99999 -E -1 svc_banjobs"
SetupComment[8]="Banner account password expiration";        SetupCommand[8]="/usr/bin/chage -I -1 -m 0 -M 99999 -E -1 svc_banner"
SetupLines=8



# Set up log file
touch $LOGFILE
echo "Date: $DATE, $TIME" 2>&1 | tee -a $LOGFILE
echo "Host: $HOSTNAME/$IP_ADDRESS" 2>&1 | tee -a $LOGFILE
echo "========================================================================" 2>&1 | tee -a $LOGFILE
echo " " 2>&1 | tee -a $LOGFILE

# Install snmp agent for monitoring components.. 
# Make sure only root can run our script 
#echo "Setting up snmp agent for monitoring" 2>&1 | tee -a $LOGFILE
#if [[ $EUID -ne 0 ]]; then
#   echo "This script must be run as root" 1>&2 | tee -a $LOGFILE
#   exit 1
#fi
#echo "install snmp" 2>&1 | tee -a $LOGFILE
#yum -y install net-snmp net-snmp-utils
#echo "set it as a service and to run by default" 2>&1 | tee -a $LOGFILE
#chkconfig snmpd on
#echo  "output snmpd configuration after backing up original" 2>&1 | tee -a $LOGFILE
#cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf-orig
#rm /etc/snmp/snmpd.conf
#touch /etc/snmp/snmpd.conf
#echo "rocommunity Master_XWu2QRNscL6vgFY3uX8U" >> /etc/snmp/snmpd.conf
#echo "com2sec readonly default Master_XWu2QRNscL6vgFY3uX8U" >> /etc/snmp/snmpd.conf
#echo "backup hosts.allow and make new configuration in its place" 2>&1 | tee -a $LOGFILE
#cp /etc/hosts.allow /etc/hosts.allow-orig
#rm /etc/hosts.allow
#touch /etc/hosts.allow
#echo "ALL: 127.0.0.1" >> /etc/hosts.allow
#echo "sshd:ALL" >> /etc/hosts.allow
#echo "snmpd:ALL" >> /etc/hosts.allow
#service snmpd start
#echo "Done!" 2>&1 | tee -a $LOGFILE


 Install packages and create service accounts
for ((i=1; i<=$SetupLines; i++))
do
        echo "${SetupComment[$i]}" 2>&1 | tee -a $LOGFILE
        ${SetupCommand[$i]} 2>&1 | tee -a $LOGFILE
done
echo "========================================================================" 2>&1 | tee -a $LOGFILE
echo " " 2>&1 | tee -a $LOGFILE


# Update /etc/security/limits.conf
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo "Updaing /etc/security/limits.conf" 2>&1 | tee -a $LOGFILE
#echo "Backing up the original..." 2>&1 | tee -a $LOGFILE
#/bin/cp -v /etc/security/limits.conf /etc/security/limits.conf.ellucian 2>&1 | tee -a $LOGFILE
#echo "Removing end-of-file comment" 2>&1 | tee -a $LOGFILE
#sed -i 's/# End of file//' /etc/security/limits.conf
#
#echo "Adding new lines" 2>&1 | tee -a $LOGFILE
#for i in "${Limits[@]}"
#do
#	echo "$i" >> /etc/security/limits.conf
#done
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo " " 2>&1 | tee -a $LOGFILE


# Update /etc/sysctl.conf
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo "Updaing /etc/sysctl.conf" 2>&1 | tee -a $LOGFILE
#echo "Backing up the original..." 2>&1 | tee -a $LOGFILE
#/bin/cp -v /etc/sysctl.conf /etc/sysctl.conf.ellucian 2>&1 | tee -a $LOGFILE
#for i in "${SysCtl[@]}"
#do
#        echo "$i" >> /etc/sysctl.conf
#done
#/sbin/sysctl -p /etc/sysctl.conf 2>&1 | tee -a $LOGFILE
#echo " " 2>&1 | tee -a $LOGFILE
#tail -n 14 /etc/sysctl.conf 2>&1 | tee -a $LOGFILE
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo " " 2>&1 | tee -a $LOGFILE


# Install BigFix
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo "Install BigFix" 2>&1 | tee -a $LOGFILE
#for i in "${BigFix[@]}"
#do
#        $i 2>&1 | tee -a $LOGFILE
#done
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo " " 2>&1 | tee -a $LOGFILE

# Install NX
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo "Install NX" 2>&1 | tee -a $LOGFILE
#mkdir -v /ellucian 2>&1 | tee -a $LOGFILE
#/bin/mount -v 10.52.4.35:/exports /ellucian 2>&1 | tee -a $LOGFILE
#/bin/rpm -ihv /ellucian/nx* 2>&1 | tee -a $LOGFILE
#/bin/umount -v /ellucian 2>&1 | tee -a $LOGFILE
#rm -rf /ellucian 2>&1 | tee -a $LOGFILE

#echo "Updating root's crontab" 2>&1 | tee -a $LOGFILE
#echo "# Clear NX user database" >> /var/spool/cron/root
#echo "0,10,20,30,40,50 * * * * cat /dev/null > /usr/NX/etc/users.db > /dev/null 2>&1" >> /var/spool/cron/root
#crontab -l 2>&1 | tee -a $LOGFILE
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo " " 2>&1 | tee -a $LOGFILE


# Install JDK
# ** Note: For now this section is tied to Oracle JDK 1.7 update 71 **
# ** Review this section carefully when installing later versions.
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo "Install JDK 1.7 u71" 2>&1 | tee -a $LOGFILE
#mkdir -v /ellucian 2>&1 | tee -a $LOGFILE
#/bin/mount -v 10.52.4.35:/exports /ellucian 2>&1 | tee -a $LOGFILE
#rpm -ihv /ellucian/jdk-7u71-linux-x64.rpm 2>&1 | tee -a $LOGFILE
#alternatives --install /usr/bin/java java /usr/java/jdk1.7.0_71/bin/java 120 --slave /usr/bin/keytool keytool /usr/java/jdk1.7.0_71/bin/keytool --slave /usr/bin/rmiregistry rmiregistry /usr/java/jdk1.7.0_71/jre/bin/rmiregistry 2>&1 | tee -a $LOGFILE
#alternatives --install /usr/bin/javac javac /usr/java/jdk1.7.0_71/bin/javac 120 --slave /usr/bin/jar  jar  /usr/java/jdk1.7.0_71/bin/jar --slave /usr/bin/rmic rmic /usr/java/jdk1.7.0_71/bin/rmic 2>&1 | tee -a $LOGFILE
#echo 3 | /usr/sbin/alternatives --config java 2>&1 | tee -a $LOGFILE
#/bin/umount -v /ellucian 2>&1 | tee -a $LOGFILE
#rm -rf /ellucian 2>&1 | tee -a $LOGFILE
#echo "Confirm JDK 1.7 is now the default via (alternatives --config java)" | tee -a $LOGFILE
#java -version
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo " " 2>&1 | tee -a $LOGFILE

# Fix umask settings
echo "************************************************************************" 2>&1 | tee -a $LOGFILE
echo "Changing umask from 077 to 022 to meet Oracle requirements" 2>&1 | tee -a $LOGFILE
echo "umask 022" >> ~svc_oracle/.bash_profile
echo "umask 022" >> ~svc_banner/.bash_profile
echo "umask 022" >> ~svc_banjobs/.bash_profile
echo "************************************************************************" 2>&1 | tee -a $LOGFILE
echo " " 2>&1 | tee -a $LOGFILE


# Install CopperEgg
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo "Installing CopperEgg" 2>&1 | tee -a $LOGFILE
#curl -svk http://uuyBsBNzG4xOQw0H@api.copperegg.com/rc.sh > installer.sh 2>&1 | tee -a $LOGFILE
#/bin/sh installer.sh 2>&1 | tee -a $LOGFILE
#echo "************************************************************************" 2>&1 | tee -a $LOGFILE
#echo " " 2>&1 | tee -a $LOGFILE
mailx -s "$HOSTNAME RHEL6 post-install log" $EMAIL_ADDRESS < $LOGFILE
echo "Tasks complete, please review log, $LOGFILE"
