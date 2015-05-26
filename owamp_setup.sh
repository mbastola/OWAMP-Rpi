#! /bin/bash

echo "Initiating... "
cd /usr/local/src
echo "Downloading files... "
wget http://software.internet2.edu/sources/owamp/owamp-3.1.tar.gz
tar -xvzf owamp-3.1.tar.gz
cd owamp-3.1/conf
echo testports 8760-9960 >> owampd.conf
cd ..
echo "Configuring... "
./configure --sysconfdir=/usr/local/etc
make
echo "Installing... "
make install
mkdir -p /usr/local/etc/OWAMP
cd /usr/local/etc/OWAMP
cp /usr/local/src/owamp-3.1/conf/owampd.conf ./
cp /usr/local/src/owamp-3.1/conf/owampd.limits ./
chown -R tk:tk /usr/local/etc/OWAMP
chmod u+x owampd.conf
chmod u+x owampd.limits
mkdir -p /var/db/OWAMP
chown -R tk:tk /var/db/OWAMP
su -c 
cd /usr/local/bin/
touch owamp_launch.sh
FILE="/usr/local/bin/owamp_launch.sh"
/bin/cat <<EOM >$FILE
process ='ps -ef | grep owamp | grep -v grep'
if [ ! "$process" ]; then
   ntptime -N    #sync the clock
   mkdir /var/run/OWAMP
   chown -R tk:tk /var/run/OWAMP
   cd /var/run/OWAMP    
   /usr/local/src/owamp-3.1/owampd/owampd -U tk -G tk -c /usr/local/etc/OWAMP -R /var/run/OWAMP
fi
EOM
chmod u+x owamp_launch.sh
crontab -l | { cat; echo "* * * * * /usr/local/bin/owamp_launch.sh"; } | crontab -
touch owtest.sh
FILE="/usr/local/bin/owtest.sh"
/bin/cat <<EOM>$FILE
#!/bin/bash
# Performs owping test every 30 seconds for 24 hours.
# Saves result to the file. 
# Copies the file and sends it to perfSONAR box

FILEOUT="/home/tk/owlogs/$(/bin/date +'%m-%d-%y').log"
echo $FILEOUT
fileflag=0
if [ -e "$FILEOUT" ]; then
	fileflag=1
fi
TMPFILE="/home/tk/owlogs/data.txt"
/usr/local/bin/owping owping.nts.wustl.edu > $TMPFILE
wait
line1=5
if [ $fileflag == 0 ]; then
	echo "Date-Time" "LossFrom(%)" "LossTo(%)" "DelayFrom(ms)" "DelayMin(ms)" "DelayMax(ms)" "DelayTo(ms)" "DelayMin(ms)" "DelayMax(ms)" "JitterFrom(ms)" "JitterTo(ms)"  >> $FILEOUT
fi
ROW1=$(awk 'FNR == '${line1}' {print $'2'}' < $TMPFILE)
line1=$(($line1+2))
line2=$line1
ROW2=$(awk 'FNR == '${line1}' {print $'3'}' < $TMPFILE)
line1=$(($line1+1))
TMP=$(awk 'FNR == '${line1}' {print $'5'}' < $TMPFILE)
ROW4=$(echo $TMP | awk -F/ '{print $'2'}')
ROW5=$(echo $TMP | awk -F/ '{print $'1'}')
ROW6=$(echo $TMP | awk -F/ '{print $'3'}')
line1=$(($line1+1))
ROW10=$(awk 'FNR == '${line1}' {print $'4'}' < $TMPFILE)
line2=$(($line2+11))
ROW3=$(awk 'FNR == '${line2}' {print $'3'}' < $TMPFILE)
line2=$(($line2+1))
TMP2=$(awk 'FNR == '${line2}' {print $'5'}' < $TMPFILE)
ROW7=$(echo $TMP2 | awk -F/ '{print $'2'}')
ROW8=$(echo $TMP2 | awk -F/ '{print $'1'}')
ROW9=$(echo $TMP2 | awk -F/ '{print $'3'}')
line2=$(($line2+1))
ROW11=$(awk 'FNR == '${line2}' {print $'4'}' < $TMPFILE)
echo $ROW1 $ROW2 $ROW3 $ROW4 $ROW5 $ROW6 $ROW7 $ROW8 $ROW9 $ROW10 $ROW11 >> $FILEOUT
rsync -a /home/tk/owlogs/ owping.nts.wustl.edu:/var/log/owlogs/$(hostname)
EOM
touch owrem.sh
FILE="/usr/local/bin/owrem.sh"
/bin/cat <<EOM>$FILE
#!/bin/bash
# Removes local owping test logs every end of month.

cd /home/tk/owlogs/
rm $(date +'%m' -d 'last month')*
EOM
exit
su tk -c
crontab -l | { cat; echo "* * * * * /usr/local/bin/owtest.sh"; } | crontab -
crontab -l | { cat; echo "00 00 1 * * /usr/local/bin/owrem.sh"; } | crontab -
echo "Complete!"
