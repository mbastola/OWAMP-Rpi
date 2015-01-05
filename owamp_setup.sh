#! /bin/bash
# Installs OWAMP(One Way Ping) to the raspbian Raspberry Pi
# Takes argument the user under which OWAMP can be reverse tunneled

#Install
echo "Initiating... "
cd /usr/local/src
echo "Downloading files... "
wget http://software.internet2.edu/sources/owamp/owamp-3.1.tar.gz
tar -xvzf owamp-3.1.tar.gz
cd owamp-3.1
echo "Configuring... "
./configure --sysconfdir=/usr/local/etc
make
echo "Installing... "
make install
mkdir -p /usr/local/etc/OWAMP
cd /usr/local/etc/OWAMP
cp /usr/local/src/owamp-3.1/conf/owampd.conf ./
cp /usr/local/src/owamp-3.1/conf/owampd.limits ./
chown -R $1:$1 /usr/local/etc/OWAMP
chmod u+x owampd.conf
chmod u+x owampd.limits
mkdir -p /var/db/OWAMP
chown -R $1:$1 /var/db/OWAMP

# Run OWAMP. Create a script to build the tunnel so that OWAMP runs at default everytime.
su -c
cd /usr/local/bin/
touch owamp_launch.sh
FILE="/usr/local/bin/owamp_launch.sh"
/bin/cat <<EOM >$FILE
process ='ps -ef | grep owamp | grep -v grep'
if [ ! "$process" ]; then
   ntptime -N    #sync the clock
   mkdir /var/run/OWAMP
   chown -R $1:$1 /var/run/OWAMP
   cd /var/run/OWAMP    
   /usr/local/src/owamp-3.1/owampd/owampd -U $1 -G $1 -c /usr/local/etc/OWAMP -R /var/run/OWAMP
fi
EOM
chmod u+x owamp_launch.sh

# Add to root's cron job
crontab -l | { cat; echo "* * * * * /usr/local/bin/owamp_launch.sh"; } | crontab -
echo "Complete!"
